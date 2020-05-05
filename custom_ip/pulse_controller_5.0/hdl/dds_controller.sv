`timescale 1ns / 1ps

/*
 * dds_controller is a module to communicate with multiple DDS boards.
 * The current configuration (June, 2014) consists of two banks of 11 boards each.
 * Reads/writes to the boards occur via a bus backplane that has
 * 16 data bits, 7 addr bits, and 4 or 5 control bits.
 *
 * dds_controller is instantiated in timing_controller, to generate precisely
 * timed RF pulses.
 *
 * The DDS chips are AD9914, and the data sheet contains many details about
 * device operation and programming.
 *
 * All DDS commands require (MAX_CYCLES + 1)*(CLK_DIV + 1) + 1 cycles.
 *
 * The signals clock, reset, write_enable, opcode, operand come from the timing
 * controller. A new opcode & operand are loaded upon write_enable going high.
 * When data is read from a DDS, it goes to result_data, and result_WrReq
 * signals data availability.
 *
 * External signals connecting to the DDS boards:
 * dds_addr, dds_data, dds_control,
 * dds_addr2, dds_data2, dds_control2,
 * dds_cs, dds_FUD
 *
 * opcode[3:0] DDS command
 *
 *  0 = set freq.  ftw = operand[31:0]
 *  1 = set phase. ptw = operand[15:0]
 *  2 = set word (two bytes). operand[15:0]
 *  3 = get word (two bytes)
 *  4 = reset one DDS specified by DDS number
 *  5 = Reset several DDS synchronously. Selected DDS are the high bits of
 *      operand.
 *  6 = Select several DDS boards (via dds_cs) until they are deselected.
 *      Allows synchronous programming of frequencies.  Overrides DDS number.
 *      Selected DDS are the high bits of operand
 *  14 = get two words (4 bytes)
 *  15 = set two words (4 bytes) operand[31:0]
 *
 * opcode[8:4] DDS number (0...31).  Specify target DDS for command.
 *             Overridden by if DDS are selected via opcode 6
 *
 * opcode[15:9] DDS memory address for get / set word commands.
 *              One word operations use addr and addr-1.
 * Two word operations use addr + 2...addr - 1. (this seems inconvenient)
 *
 * ___
 *  |R
 *
 * Work in progress: align DDS SYNC_CLK with FPGA clock
 */

module dds_controller
  #(parameter N_DDS = 22,
    parameter U_DDS_DATA_WIDTH = 16,
    parameter U_DDS_ADDR_WIDTH = 7,
    parameter U_DDS_CTRL_WIDTH = 3,
    parameter DDS_OPCODE_WIDTH = 16,
    parameter DDS_OPERAND_WIDTH = 32,

    localparam RESULT_WIDTH = 32)
   (input clock,
    input reset,
    input write_enable,
    input [(DDS_OPCODE_WIDTH - 1):0] opcode,
    input [(DDS_OPERAND_WIDTH - 1):0] operand,
    // external signals for DDS bank
    output [(U_DDS_ADDR_WIDTH - 1):0] dds_addr,
    // tri-state for dds_data to allow read & write
    inout [(U_DDS_DATA_WIDTH - 1):0] dds_data,
    output [(U_DDS_CTRL_WIDTH - 1):0] dds_control,
    // external signals for 2nd DDS bank
    output [(U_DDS_ADDR_WIDTH - 1):0] dds_addr2,
    // tri-state for dds_data to allow read & write
    inout [(U_DDS_DATA_WIDTH - 1):0] dds_data2,
    output [(U_DDS_CTRL_WIDTH - 1):0] dds_control2,
    output reg [(N_DDS - 1):0] dds_cs,
    // FUD = IO_UPDATE on DDS boards can be lowered on posedge of clock.
    // It will return to 1 on negedge of clock.
    // This short pulse (5 ns or so) allows alignment of DDS SYNC_CLK
    // and SYNC_IN/OUT with FUD. The signal idles high.
    output [1:0] dds_FUD,
    output reg [(RESULT_WIDTH - 1):0] result_data,
    output reg result_WrReq);

   // delay dds_addr by 1 cycle (10 ns)
   // to meet timing for AD9914 (tASU)
   reg [(U_DDS_ADDR_WIDTH - 1):0] dds_addr_reg;
   reg [(U_DDS_ADDR_WIDTH - 1):0] dds_addr_reg_next;

   reg [(U_DDS_DATA_WIDTH - 1):0] dds_data_reg;
   reg dds_data_T_reg;

   reg dds_w_strobe_n;
   reg dds_r_strobe_n;

   reg dds_reset;

   reg [1:0] active_dds_bank;
   // DDS signal translation
   wire dds_data_T = active_dds_bank[0] ? dds_data_T_reg : 1'b0;
   wire [(U_DDS_DATA_WIDTH - 1):0] dds_data_O = active_dds_bank[0] ? dds_data_reg : 1'b0;
   wire [(U_DDS_DATA_WIDTH - 1):0] dds_data_I;
   wire dds_data2_T = active_dds_bank[1] ? dds_data_T_reg : 1'b0;
   wire [(U_DDS_DATA_WIDTH - 1):0] dds_data2_O = active_dds_bank[1] ? dds_data_reg : 1'b0;
   wire [(U_DDS_DATA_WIDTH - 1):0] dds_data2_I;

   genvar i;
   generate
      for (i = 0; i < U_DDS_DATA_WIDTH; i++) begin
         IOBUF IOBUF_inst(.O(dds_data_I[i]),
                          .IO(dds_data[i]),
                          .I(dds_data_O[i]),
                          .T(dds_data_T) // 3-state enable input, high=input, low=output
                          );
         IOBUF IOBUF_inst2(.O(dds_data2_I[i]),
                           .IO(dds_data2[i]),
                           .I(dds_data2_O[i]),
                           .T(dds_data2_T) // 3-state enable input, high=input, low=output
                           );
      end
   endgenerate

   assign dds_addr = active_dds_bank[0] ? dds_addr_reg : 1'b0;
   assign dds_addr2 = active_dds_bank[1] ? dds_addr_reg : 1'b0;

   assign dds_control = (active_dds_bank[0] ?
                         {dds_reset, dds_r_strobe_n, dds_w_strobe_n} :
                         {1'b0, 1'b1, 1'b1});
   assign dds_control2 = (active_dds_bank[1] ?
                          {dds_reset, dds_r_strobe_n, dds_w_strobe_n} :
                          {1'b0, 1'b1, 1'b1});

   reg [(DDS_OPERAND_WIDTH - 1):0] operand_reg;
   reg [(DDS_OPCODE_WIDTH - 1):0] opcode_reg;

   reg [3:0] cycle;
   reg [1:0] sub_cycle;
   // reg sub_cycle;

   reg [(N_DDS - 1):0] dds_sel_mask; // set active DDS via separate command

   reg dds_FUDx; // aux signal for dds_FUD DDR signal
   // dds_FUDx will be low for 1 clock cycle

   // reg ddr_reset;

   localparam FUD_DDR_MODE = 0;
   generate
      if (FUD_DDR_MODE == 0) begin
         // FUD idles low. transition to high transfers registers into DDS core
         assign dds_FUD[0] = active_dds_bank[0] ? dds_FUDx : 1'b0;
         assign dds_FUD[1] = active_dds_bank[1] ? dds_FUDx : 1'b0;
      end else begin
         // Setup dds_FUD as DDR signal (goes high for only a half-period of
         // clock)
         // ODDR: Output Double Data Rate Output Register with Set, Reset
         // and Clock Enable.
         // 7 Series
         // Xilinx HDL Libraries Guide, version 14.3
         // ODDR#(.DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
         //       .INIT(1'b0), // Initial value of Q: 1'b0 or 1'b1
         //       .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC"
         //       ) sODDR_inst1(.Q(dds_FUD[0]), // 1-bit DDR output
         //                     .C(clock), // 1-bit clock input
         //                     .CE(1'b1), // 1-bit clock enable input
         //                     .D1(dds_FUDx), // 1-bit data input (positive edge)
         //                     .D2(1'b0), // 1-bit data input (negative edge)
         //                     .R(ddr_reset), // 1-bit reset
         //                     .S(1'b0) // 1-bit set
         //                     );

         // ODDR#(.DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
         //       .INIT(1'b0), // Initial value of Q: 1'b0 or 1'b1
         //       .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC"
         //       ) ODDR_inst2(.Q(dds_FUD[1]), // 1-bit DDR output
         //                    .C(clock), // 1-bit clock input
         //                    .CE(1'b1), // 1-bit clock enable input
         //                    .D1(dds_FUDx), // 1-bit data input (positive edge)
         //                    .D2(1'b0), // 1-bit data input (negative edge)
         //                    .R(ddr_reset), // 1-bit reset
         //                    .S(1'b0) // 1-bit set
         //                    );
         // End of ODDR_inst instantiation
      end
   endgenerate

   localparam DDS_BANK_SIZE = 11;
   localparam MAX_CYCLES = 7;
   localparam CLK_DIV = 3;

   // first and last bit of DDS id in opcode
   localparam DDS_ID_A = 4;
   localparam DDS_ID_B = DDS_ID_A + 5 - 1;

   // first and last bit of DDS memory register in opcode
   localparam DDS_REG_A = DDS_ID_B + 1;
   localparam DDS_REG_B = DDS_REG_A + U_DDS_ADDR_WIDTH - 1;
   always @(posedge clock) begin
      if (reset) begin
         cycle <= 0;
         sub_cycle <= 0;

         operand_reg <= 0;
         opcode_reg <= 0;

         dds_w_strobe_n  <= 1;
         dds_r_strobe_n  <= 1;
         dds_reset <= 0;

         dds_cs <= ~0; // all ones

         dds_addr_reg  <= 0;
         dds_addr_reg_next <= 0;
         dds_data_reg  <= 0;
         dds_data_T_reg  <= 1;

         result_WrReq <= 0;
         dds_FUDx <= 0;
         // ddr_reset <= 1;
      end else begin
         // ddr_reset <= 0;
         dds_addr_reg <= dds_addr_reg_next;

         if (cycle == 0) begin
            dds_w_strobe_n <= 1;
            dds_r_strobe_n <= 1;
            dds_reset <= 0;

            dds_addr_reg_next <= 0;
            dds_data_reg <= 0;
            dds_data_T_reg <= 0;

            result_WrReq <= 0;
            result_data <= 0;

            sub_cycle <= 0;
            dds_sel_mask <= 0;

            dds_FUDx <= 0;

            // wait for write_enable to start
            if (write_enable) begin
               // chip select

               if (dds_sel_mask == 0) begin
                  dds_cs <= ~(1 << opcode[DDS_ID_B:DDS_ID_A]);

                  active_dds_bank[0] = opcode[DDS_ID_B:DDS_ID_A] < DDS_BANK_SIZE;
                  active_dds_bank[1] = opcode[DDS_ID_B:DDS_ID_A] >= DDS_BANK_SIZE;
               end else begin
                  dds_cs <= ~dds_sel_mask;
                  active_dds_bank[0] = 1;
                  active_dds_bank[1] = 1;
               end

               // latch in operand and opcode
               operand_reg <= operand;
               opcode_reg <= opcode;

               cycle <= 1;
            end else begin
               dds_cs <= ~0; //all ones
            end
         end else begin
            case (opcode_reg[3:0])
              0 : begin // set frequency for profile 0
                 case (cycle)
                   1 : dds_addr_reg_next <= 6'h2F;
                   2 : begin
                      dds_data_reg <= operand_reg[31:16];
                      dds_w_strobe_n <= 0;
                   end
                   3 : begin
                      dds_addr_reg_next <= 6'h2D;
                      dds_w_strobe_n <= 1;
                   end
                   4 : begin
                      dds_data_reg <= operand_reg[15:0];
                      dds_w_strobe_n <= 0;
                   end
                   5 : dds_w_strobe_n <= 1;
                   6 : dds_FUDx <= 1;
                 endcase
              end

              1 : begin
                 // set phase (two high bytes), amplitude (two low bytes)
                 // for profile 0
                 case (cycle)
                   1 : dds_addr_reg_next <= 6'h31;
                   2 : begin
                      dds_data_reg <= operand_reg[31:16];
                      dds_w_strobe_n <= 0;
                   end
                   3 : begin
                      dds_addr_reg_next <= 6'h33;
                      dds_w_strobe_n <= 1;
                   end
                   4 : begin
                      dds_data_reg <= operand_reg[15:0];
                      dds_w_strobe_n <= 0;
                   end
                   5 : dds_w_strobe_n <= 1;
                   6 : dds_FUDx <= 1;
                 endcase
              end

              2 : begin // set memory word (two bytes) from addr - 1 to addr
                 case (cycle)
                   1 : dds_addr_reg_next <= opcode_reg[DDS_REG_B:DDS_REG_A];
                   2 : begin
                      dds_data_reg <= operand_reg[15:0];
                      dds_w_strobe_n <= 0;
                   end
                   3 : dds_w_strobe_n <= 1;
                   6 : dds_FUDx <= 1;
                 endcase
              end

              3 : begin // get memory word (two bytes) from addr - 1 to addr
                 case(cycle)
                   1 : begin
                      dds_addr_reg_next <= opcode_reg[DDS_REG_B:DDS_REG_A];
                      dds_data_T_reg <= 1;
                      result_data <= 0;
                   end
                   3 : dds_r_strobe_n <= 0;
                   5 : result_data[15:0] <= active_dds_bank[0] ? dds_data_I : dds_data2_I;
                   6 : begin
                      dds_r_strobe_n <= 1;
                      result_WrReq <= 1;
                   end
                 endcase
              end

              4 : begin // DDS reset (should be low for about 10 ns minimum)
                 case(cycle)
                   6 : dds_reset <= 1;
                 endcase
              end

              5 : begin // DDS reset (boards selected by operand)
                 case (cycle)
                   1 : dds_cs <= operand_reg[(N_DDS - 1):0];
                   6 : dds_reset <= 1;
                 endcase
              end

              6 : begin
                 // Set active DDS (boards selected by operand).
                 // Allows phase synchronization between chips.
                 // Don't forget to set dds_sel_mask = 0 when done.
                 case(cycle)
                   1 : dds_sel_mask <= operand_reg[(N_DDS - 1):0];
                 endcase
              end

              14 : begin
                 // get two memory words (four bytes) from addr - 1 to addr + 2
                 case (cycle)
                   1 : begin
                      dds_addr_reg_next <= opcode_reg[DDS_REG_B:DDS_REG_A];
                      dds_data_T_reg <= 1;
                      result_data <= 0;
                   end
                   2 : dds_r_strobe_n <= 0; //initiate first read from DDS
                   3 : begin // get data on bus
                      result_data[15:0] <= active_dds_bank[0] ? dds_data_I : dds_data2_I;
                      dds_r_strobe_n <= 1;
                      //advance address
                      dds_addr_reg_next <= opcode_reg[DDS_REG_B:DDS_REG_A] + 2'b10;
                   end
                   //initiate second read from DDS
                   4 : begin
                      dds_r_strobe_n <= 0;
                      result_WrReq <= 0;
                   end
                   5 : begin // get data on bus
                      result_data[31:16] <= active_dds_bank[0] ? dds_data_I : dds_data2_I;
                      dds_r_strobe_n <= 1;
                   end
                   6 : result_WrReq <= 1;
                 endcase
              end

              15 : begin // set two memory words (four bytes) from addr - 1 to addr + 2
                 case(cycle)
                   1 : dds_addr_reg_next <= opcode_reg[DDS_REG_B:DDS_REG_A] + 2'b10;
                   2 : begin
                      dds_data_reg <= operand_reg[31:16];
                      dds_w_strobe_n <= 0;
                   end
                   3 : begin
                      dds_addr_reg_next <= opcode_reg[DDS_REG_B:DDS_REG_A];
                      dds_w_strobe_n <= 1;
                   end
                   4 : begin
                      dds_data_reg <= operand_reg[15:0];
                      dds_w_strobe_n <= 0;
                   end
                   5 : dds_w_strobe_n <= 1;
                   6 : dds_FUDx <= 1;
                 endcase
              end
            endcase

            // All DDS commands require 1 + 4 * (MAX_CYCLES + 1) cycles
            if (cycle == MAX_CYCLES) begin
               cycle <= 0;
            end else begin
               sub_cycle <= sub_cycle + 1'b1;
               if (sub_cycle == 2'b11)
                 // divide clock rate by 4 for DDS programming
                 // if (sub_cycle == 1'b1)
                 // divide clock rate by 2 for DDS programming
                 cycle <= cycle + 1'b1;
            end
         end
      end
   end
endmodule
