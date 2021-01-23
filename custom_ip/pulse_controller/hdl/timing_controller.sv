/**
 * timing_controller: precise timing FIFO to control experiments
 *
 * The FIFO is attached to an AXI bus for writing.  The timing controller reads
 * words from the FIFO in a precisely timed manner for digital control in a
 * laboratory. The controller can output TTL words for a variable number of
 * clock cycles, and write to a bank of attached DDS modules (AD9858 and AD9914).
 * A flag can be set to count photons (# of rising edges on an input).
 * The phase of the photon arrival times with respect to a sync clock can be
 * tracked.
 *
 * SPI communications can be performed as part of the pulse sequence.
 *
 * DDS, photon counts, and SPI results can be read back via a second read FIFO.
 *
 * Underflow of the write FIFO (timing failure) can be detected.
 *
 * This is implemented as a finite state machine (FSM) with attached
 * DDS control
 *
 * bits 63...60, instruction
 *
 * Current instructions:
 *
 * 0 TIMED_OUTPUT (6 cycles minimum, 2^24 - 1 = 16,777,215 maximum)
 *   bits 55...32 = duration (in clock cycles, must be at least 6)
 *   bits 31...0  = output word
 *
 * 1 DDS_CONTROL (50 cycles, purposely slowed because the external DDS bus is
 *   not so fast)
 *   bits 47...32 = DDS opcode (read and write freq/phase/amplitude/registers)
 *   bits 31...0  = DDS operand (phase/frequency/amplitude/register value)
 *
 * 2 WAIT (pulse output remains unchanged)
 *   bits 55...32 = duration (in clock cycles, must be at least 6)
 *
 * 3 CLEAR_UNDERFLOW (5 cycles)
 *
 * 4 PUSH_DATA (variable # cycles)
 *   bits 55...32 = duration (in clock cycles)
 *   push bits 31...0 onto rFIFO for loop-back testing
 *
 * 5 ENABLE CLOCK OUT
 *   period - 1 = bits 7...0. disabled when bits 7...0 = 255
 *
 * 6 SPI COMMAND
 *   bits 55...48 = duration (x4, in clock cycles, up to 4 x 2.55us)
 *   bits 47...32 = SPI opcode (see spi_controller.v)
 *   bits 31... 0 = SPI output data (bit 31 is emitted first)
 *
 * bit 59, disable underflow flag.  Prevents underflow from going high.
 *
 * Post-PAR timing for Zynq ZC702 speed -1:
 * Minimum period:   4.916ns{1}   (Maximum frequency: 203.417MHz)
 */

module clock_out_controller(input clock, input reset, input [7:0] div,
                            output reg out);
   reg [7:0] counter;
   always @(posedge clock, posedge reset) begin
      if (reset | div == 255) begin
         // reset
         out <= 0;
         counter <= 0;
      end else begin
         // emit divided clock with period 2 x (div + 1)
         if (counter == div) begin
            counter <= 0;
            out <= ~out;
         end else begin
            counter <= counter + 1;
         end
      end
   end
endmodule

module timing_controller
  #(parameter N_DDS = 8,
    parameter U_DDS_DATA_WIDTH = 16,
    parameter U_DDS_ADDR_WIDTH = 7,
    parameter U_DDS_CTRL_WIDTH = 3,

    parameter N_SPI = 1,

    parameter BUS_DATA_WIDTH = 32,
    parameter RESULT_WIDTH = 32,

    localparam TTL_WIDTH = 32)
   (input clock,
    input resetn,
    input [(BUS_DATA_WIDTH - 1):0] bus_data,
    input bus_data_valid,
    output bus_data_ready,

    output [(RESULT_WIDTH - 1):0] rFIFO_data,
    output rFIFO_WrReq,

    // dds_data*: tri-state for dds_data to allow read & write.
    output [(U_DDS_ADDR_WIDTH - 1):0] dds_addr,
    inout [(U_DDS_DATA_WIDTH - 1):0] dds_data,
    output [(U_DDS_CTRL_WIDTH - 1):0] dds_control,
    output [(U_DDS_ADDR_WIDTH - 1):0] dds_addr2,
    inout [(U_DDS_DATA_WIDTH - 1):0] dds_data2,
    output [(U_DDS_CTRL_WIDTH - 1):0] dds_control2,

    output [(N_DDS - 1):0] dds_cs,
    output [1:0] dds_FUD,

    output reg [(TTL_WIDTH - 1):0] ttl_out,
    output reg underflow,

    output [(N_SPI - 1):0] spi_cs,
    output spi_mosi,
    input spi_miso,
    output spi_clk,

    output reg pulses_finished,
    // pulses wait until this goes low
    input pulse_controller_hold,
    // init is like reset, but hold the current TTL outputs toggle this at
    // the start of the sequence.
    input init,
    output clock_out,
    output reg [7:0] clock_out_div,

    input inst_fifo_empty,
    input inst_fifo_almost_empty, // unused
    input [63:0] inst_fifo_rd_data,
    output inst_fifo_rd_en,
    input inst_fifo_full,
    input inst_fifo_almost_full, // unused
    output [31:0] inst_fifo_wr_data,
    output inst_fifo_wr_en,

    output reg [(BUS_DATA_WIDTH - 1):0] dbg_regs [0:31]
    );

   wire reset = ~resetn;

   clock_out_controller clock_out_ctrl(.clock(clock),
                                       .reset(reset),
                                       .out(clock_out),
                                       .div(clock_out_div));

   localparam DDS_OPCODE_WIDTH = 16;
   localparam DDS_OPERAND_WIDTH = 32;
   reg dds_we;
   reg [(DDS_OPCODE_WIDTH - 1):0] dds_opcode;
   reg [(DDS_OPERAND_WIDTH - 1):0] dds_operand;
   wire dds_WrReq;
   wire [31:0] dds_result;

   dds_controller#(.N_DDS(N_DDS),
                   .DDS_OPCODE_WIDTH(DDS_OPCODE_WIDTH),
                   .DDS_OPERAND_WIDTH(DDS_OPERAND_WIDTH),
                   .U_DDS_DATA_WIDTH(U_DDS_DATA_WIDTH),
                   .U_DDS_ADDR_WIDTH(U_DDS_ADDR_WIDTH),
                   .U_DDS_CTRL_WIDTH(U_DDS_CTRL_WIDTH))
   dds_controller_inst(.clock(clock),
                       .reset(reset),
                       .write_enable(dds_we),
                       .opcode(dds_opcode),
                       .operand(dds_operand),
                       .dds_addr(dds_addr),
                       .dds_data(dds_data),
                       .dds_control(dds_control),
                       .dds_addr2(dds_addr2),
                       .dds_data2(dds_data2),
                       .dds_control2(dds_control2),
                       .dds_cs(dds_cs),
                       .dds_FUD(dds_FUD),
                       .result_data(dds_result),
                       .result_WrReq(dds_WrReq));

   reg [31:0] loopback_data;
   reg loopback_WrReq;
   // allow DDS_controller or loop back to write into the rFIFO
   // Write one word on rising edge of rFIFO_WrReq.
   // Data should be valid for one cycle after rising edge.
   assign rFIFO_WrReq = dds_WrReq | loopback_WrReq;
   assign rFIFO_data = dds_result | loopback_data;

   localparam INSTRUCTION_BITA = 63;
   localparam INSTRUCTION_BITB = 60;
   localparam ENABLE_TIMING_CHECK_BIT = 63 - 4; // 0x08000000
   localparam TIMER_WIDTH = 24;
   localparam TIMER_BITA = 63 - 8;
   localparam TIMER_BITB = TIMER_BITA - TIMER_WIDTH + 1;
   localparam TTL_BITA = 31;
   localparam TTL_BITB = 0;

   reg [(TIMER_WIDTH - 1):0] timer;
   reg [2:0] state;
   reg timing_check;
   reg [63:0] instruction;
   // goes high when inst_fifo_full is true.  also goes low at last pulse;
   reg force_release;
   // pulses_hold will be released if FIFO is full or pulse_controller_hold is
   // low once released, the controller runs until it is done
   wire pulses_hold = pulse_controller_hold & ~force_release;
   assign inst_fifo_wr_data = bus_data;
   assign inst_fifo_wr_en = ~init & ~reset & bus_data_valid;
   wire inst_fifo_wr_ready = ~inst_fifo_full;
   // The following condition must be consistent with how the fifo is read below.
   assign inst_fifo_rd_en = ~init & ~reset & state == 0 & ~pulses_hold;
   // Signal the AXI controller that we've read the data
   assign bus_data_ready = inst_fifo_wr_ready;

   localparam SPI_OPCODE_WIDTH = 16;
   localparam SPI_OPERAND_WIDTH = 18;
   reg spi_we;
   reg [(SPI_OPCODE_WIDTH - 1):0] spi_opcode;
   reg [(SPI_OPERAND_WIDTH - 1):0] spi_operand;
   wire spi_WrReq;
   wire [31:0] spi_result;

   spi_controller#(.N_SPI(N_SPI),
                   .SPI_OPCODE_WIDTH(SPI_OPCODE_WIDTH),
                   .SPI_OPERAND_WIDTH(SPI_OPERAND_WIDTH))
   spi_controller_inst(.clock(clock),
                       .reset(reset),
                       .write_enable(spi_we),
                       .opcode(spi_opcode),
                       .operand(spi_operand),
                       .spi_cs(spi_cs),
                       .spi_mosi(spi_mosi),
                       .spi_miso(spi_miso),
                       .spi_clk(spi_clk),
                       .result_data(spi_result),
                       .result_WrReq(spi_WrReq));

   // Aliases for debug register IDs
   localparam DBG_INST_WORD_COUNT = 0;
   localparam DBG_INST_COUNT = 1;
   localparam DBG_TTL_COUNT = 2;
   localparam DBG_DDS_COUNT = 3;
   localparam DBG_WAIT_COUNT = 4;
   localparam DBG_CLEAR_COUNT = 5;
   localparam DBG_LOOPBACK_COUNT = 6;
   localparam DBG_CLOCK_COUNT = 7;
   localparam DBG_SPI_COUNT = 8;
   localparam DBG_UNDERFLOW_CYCLE = 9;

   always @(posedge clock, posedge reset) begin
      if (reset | init) begin
         if (reset) begin
            ttl_out <= 0;
         end

         state <= 0;
         timer <= 0;
         dds_we <= 0;
         timing_check <= 0;
         underflow <= 0;
         pulses_finished <= 1;
         loopback_data <= 0;
         loopback_WrReq <= 0;
         clock_out_div <= 255;
         force_release <= 0;

         for (int i = 0; i < 32; i = i + 1)
           dbg_regs[i] <= 0;
      end else begin
         if (inst_fifo_wr_ready & inst_fifo_wr_en) begin
            dbg_regs[DBG_INST_WORD_COUNT] = dbg_regs[DBG_INST_WORD_COUNT] + 1;
         end

         force_release <= force_release | inst_fifo_full;

         //finite state machine
         // 0 -- try to pull next instruction from FIFO
         //      if available & not holding, go to state 1
         //      else, set flags (underflow & pulses_finished)
         // 1 -- decode instruction and setup pulse timer, go to state 2.
         // 2 -- count down the pulse timer, then go to state 0
         case (state)
           // If there are no more instructions, set underflow high.
           0: begin
              loopback_WrReq <= 0;
              loopback_data <= 0;

              if (~inst_fifo_empty & ~pulses_hold) begin
                 state <= 1;
                 pulses_finished <= 0;
                 // Swap the word order since the FIFO generater
                 // fills the MSB first whereas we want the LSB first.
                 instruction <= {inst_fifo_rd_data[31:0], inst_fifo_rd_data[63:32]};
                 dbg_regs[DBG_INST_COUNT] = dbg_regs[DBG_INST_COUNT] + 1;
              end else begin
                 pulses_finished <= 1;
                 if (timing_check)
                   dbg_regs[DBG_UNDERFLOW_CYCLE] <= dbg_regs[DBG_UNDERFLOW_CYCLE] + 1;
                 // underflow bit is sticky
                 underflow <= (underflow | timing_check);
              end
           end

           // New data
           1: begin
              state <= 2;
              timing_check <= instruction[ENABLE_TIMING_CHECK_BIT];

              case (instruction[INSTRUCTION_BITA:INSTRUCTION_BITB])
                0 : begin // set digital output for given duration
                   dbg_regs[DBG_TTL_COUNT] = dbg_regs[DBG_TTL_COUNT] + 1;
                   timer <= instruction[TIMER_BITA:TIMER_BITB];
                   ttl_out <= instruction[TTL_BITA:TTL_BITB];
                end

                1 : begin // DDS instruction
                   dbg_regs[DBG_DDS_COUNT] = dbg_regs[DBG_DDS_COUNT] + 1;
                   dds_opcode <= instruction[47:32];
                   dds_operand <= instruction[31:0];
                   dds_we <= 1; // write to DDS
                   timer <= 50; // instruction takes 320 ns. Allocate 500 ns.
                end

                2 : begin // wait
                   dbg_regs[DBG_WAIT_COUNT] = dbg_regs[DBG_WAIT_COUNT] + 1;
                   timer <= instruction[TIMER_BITA:TIMER_BITB];
                end

                3 : begin // clear underflow
                   dbg_regs[DBG_CLEAR_COUNT] = dbg_regs[DBG_CLEAR_COUNT] + 1;
                   underflow <= 0;
                   dbg_regs[DBG_UNDERFLOW_CYCLE] <= 0;
                   timer <= 5;
                end

                4 : begin // loop-back data
                   dbg_regs[DBG_LOOPBACK_COUNT] = dbg_regs[DBG_LOOPBACK_COUNT] + 1;
                   loopback_data <= instruction[31:0];
                   loopback_WrReq <= 1;
                   timer <= 5;
                end

                5 : begin // enable/disable clock_out
                   dbg_regs[DBG_CLOCK_COUNT] = dbg_regs[DBG_CLOCK_COUNT] + 1;
                   clock_out_div <= instruction[7:0];
                   timer <= 5;
                end

                // SPI communication.
                6 : begin
                   dbg_regs[DBG_SPI_COUNT] = dbg_regs[DBG_SPI_COUNT] + 1;
                   spi_opcode <= instruction[47:32];
                   spi_operand <= instruction[(SPI_OPERAND_WIDTH - 1):0];
                   spi_we <= 1; // write to SPI
                   timer <= 45;
                end

                default : timer <= 1000;
              endcase
           end

           2 : begin // decrement timer until it equals the minimum pulse time
              dds_we <= 0;
              spi_we <= 0;

              // timer < 3 is possible for TTL pulses, swallow this timing error
              // for now.
              if (timer <= 3) begin
                 state <= 0;  // minimum pulse time is 3 cycles
              end else begin
                 timer <= timer + 24'hFFFFFF; // decrement timer
              end
           end
         endcase
      end
   end
endmodule