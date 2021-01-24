/**
 * SPI commands
 *
 * spi_we goes high for 1 cycle to start a new SPI command
 * opcode and operand must be valid when spi_we is high
 *
 * operand[31:0] = SPI output data.  Bit 31 is emitted first.
 *
 * opcode[7:0] = N (0...255) clock divider for SPI output clock
 * spi_sclk = clock / (2*(N+1))
 *
 * opcode[9:8] = N.  N+1 is the number bytes to transmit.
 * opcode[10]  = 1: save SPI input data to result FIFO. 0: don't save
 * opcode[12:11] = ID of active SPI for spi_cs (0...3)
 *
 * opcode[13] = clock phase (see XILINX xps_spi data sheet DS570)
 * 0: Data is valid on first SPI_SCLK edge
 * 1: Data is valid on second SPI_SCLK edge
 *
 * opcode[14] = clock polarity (see XILINX xps_spi data sheet DS570)
 * 0: SPI_SCLK idles low (when spi_cs is idle)
 * 1: SPI_SCLK idles high (when spi_cs is idle)
 *
 * Data is valid on the rising  edge of SPI_SCLK when (clk_pha^clk_pol) == 0.
 * Data is valid on the falling edge of SPI_SCLK when (clk_pha^clk_pol) == 1.
 *
 * Examples:
 * The AD5360  chip has clock phase = 0, clock polarity = 1
 * The DAC8814 chip has clock phase = 0, clock polarity = 0
 * ___
 *  |R
 */

module spi_controller
  #(parameter N_SPI = 1,
    parameter SPI_OPCODE_WIDTH = 16,
    parameter SPI_OPERAND_WIDTH = 18,
    localparam RESULT_WIDTH = 32)
   (input clock,
    input reset,
    input write_enable,
    output busy,
    input [(SPI_OPCODE_WIDTH - 1):0] opcode,
    input [(SPI_OPERAND_WIDTH - 1):0] operand,
    output [(N_SPI - 1):0] spi_cs,
    // begin: external signals for SPI
    output spi_mosi,
    input spi_miso,
    output reg spi_sclk,
    // end: external signals for SPI
    output reg [(RESULT_WIDTH - 1):0] result_data,
    output reg result_WrReq);

   reg [(SPI_OPCODE_WIDTH - 1):0] opcode_reg;
   reg [(SPI_OPERAND_WIDTH - 1):0] operand_reg;

   reg [1:0] nbytes_minus_one;

   reg [(N_SPI - 1):0] spi_cs_reg;

   reg clk_pha, clk_pol;

   reg [7:0] clk_div;
   reg [7:0] div_cycle;

   assign spi_mosi = operand_reg[(SPI_OPERAND_WIDTH - 1)];

   reg idle; // running SPI command or idle
   assign busy = ~idle;

   reg [6:0] spi_sclk_edges;

   assign spi_cs = ~spi_cs_reg;

   always @(posedge clock) begin
      if (reset) begin
         spi_sclk_edges <= 0;
         div_cycle <= 0;
         clk_div <= 0;
         spi_cs_reg <= 0;
         result_WrReq <= 0;
         idle <= 1;
         spi_sclk <= 1;
         operand_reg <= 0;
      end else if (write_enable && idle) begin //latch in opcode and operand
         //wait for write_enable to start
         opcode_reg <= opcode;
         operand_reg <= operand;
         spi_sclk_edges <= 0;
         idle <= 0;
         div_cycle <= 0;
         clk_div <= 0;
         result_WrReq <= 0;
         result_data <= 0;
      end else if (idle) begin
         spi_cs_reg <= 0;
         operand_reg <= 0;
         result_WrReq <= 0;
      end else if (div_cycle != clk_div) begin
         div_cycle <= div_cycle + 1'b1;
      end else begin
         div_cycle <= 0;
         spi_sclk_edges <= spi_sclk_edges + 1'b1;

         if (spi_sclk_edges == 0) begin //assert cs
            clk_pha <= opcode_reg[13];
            clk_pol <= opcode_reg[14];
            spi_sclk <= opcode_reg[14];

            clk_div <= opcode_reg[7:0];
            spi_cs_reg <= (1 << opcode_reg[12:11]);
         end else if (spi_sclk_edges == (2 * SPI_OPERAND_WIDTH + 1)) begin
            idle <= 1;// signal idle
            if (opcode_reg[10]) begin
               result_WrReq <= 1;
            end
         end else begin
            spi_sclk <= ~spi_sclk;

            // spi_sclk = 0 means this is a rising edge
            // spi_sclk = 1 means this is a falling edge
            // (clk_pha^clk_pol) == 0 means data is valid on rising clock edges
            // (clk_pha^clk_pol) == 1 means data is valid on falling clock edges
            // Update spi_mosi.  Data is valid on next clock edge.
            if (spi_sclk != clk_pha^clk_pol) begin
               operand_reg <= operand_reg << 1;
            end else begin //read in data when it is valid
               result_data <= (result_data << 1) | spi_miso;
            end
         end
      end
   end
endmodule
