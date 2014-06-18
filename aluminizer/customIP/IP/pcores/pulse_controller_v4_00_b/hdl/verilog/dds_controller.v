`timescale 1ns / 1ps

//opcode[0:3] 0=set_freq, 1=set_phase, 2=set_byte, 3=get_byte, 4=reset, 15=set_two_words
//opcode[DDS_ID_A:DDS_ID_B] DDS number (0...31)
//opcode[DDS_REG_A:DDS_REG_B] DDS memory address

//All DDS commands require (MAX_CYCLES+1)*(CLK_DIV+1)=28 cycles (280 ns)

module dds_controller(clock, reset, write_enable, opcode, operand, 
               dds_addr, dds_data_I, dds_data_O, dds_data_T, dds_control, 
               dds_addr2, dds_data2_I, dds_data2_O, dds_data2_T, dds_control2, dds_cs,
               result_data, result_WrReq);

// synthesis attribute iostandard of dds_bus is LVCMOS33;

parameter N_DDS = 22;
parameter DDS_BANK_SIZE     = 11;
parameter U_DDS_DATA_WIDTH  = 16;
parameter U_DDS_ADDR_WIDTH  = 7;
parameter U_DDS_CTRL_WIDTH  = 4;
parameter DDS_OPCODE_WIDTH  = 16;
parameter DDS_OPERAND_WIDTH = 32;
parameter RESULT_WIDTH      = 32;

parameter MAX_CYCLES = 6;
parameter CLK_DIV = 3;

//first and last bit of DDS id in opcode
parameter DDS_ID_A = 4;
parameter DDS_ID_B = DDS_ID_A + 5 - 1;

//first and last bit of DDS memory register in opcode
parameter DDS_REG_A = DDS_ID_B+1;
parameter DDS_REG_B = DDS_REG_A + U_DDS_ADDR_WIDTH - 1;

input  clock;
input  reset;
input  write_enable;
input  [(DDS_OPCODE_WIDTH-1):0]  opcode;
input  [(DDS_OPERAND_WIDTH-1):0] operand;

//external signals for DDS bank
output [(U_DDS_ADDR_WIDTH-1):0] dds_addr;

//tri-state for dds_data to allow read & write
output [(U_DDS_DATA_WIDTH-1):0] dds_data_O;
input  [(U_DDS_DATA_WIDTH-1):0] dds_data_I;
output dds_data_T; //dds_data_T = 0 means output, dds_data_T = 1 means high-Z

output [(U_DDS_CTRL_WIDTH-1):0] dds_control;

//external signals for 2nd DDS bank
output [(U_DDS_ADDR_WIDTH-1):0] dds_addr2;

//tri-state for dds_data to allow read & write
output [(U_DDS_DATA_WIDTH-1):0] dds_data2_O;
input  [(U_DDS_DATA_WIDTH-1):0] dds_data2_I;
output dds_data2_T; //dds_data_T = 0 means output, dds_data_T = 1 means high-Z

output [(U_DDS_CTRL_WIDTH-1):0] dds_control2;

output [(N_DDS-1):0] dds_cs;

reg [(U_DDS_ADDR_WIDTH-1):0] dds_addr_reg;
reg [(U_DDS_DATA_WIDTH-1):0] dds_data_reg;
reg dds_data_T_reg;

reg dds_w_strobe_n;
reg dds_r_strobe_n;
wire dds_FUD; // FUD = IO_UPDATE on DDS boards can be raised on posedge of clock.
              // It will return to 0 on negedge of clock.
              // This short pulse (5 ns or so) allows alignment of DDS SYNC_CLK
              // and SYNC_IN/OUT with FUD. The signal idles high.

reg dds_reset;
reg [(N_DDS-1):0] dds_cs_reg;

reg [1:0] active_dds_bank;

assign dds_addr    = active_dds_bank[0] ? dds_addr_reg   : 0;
assign dds_data_O  = active_dds_bank[0] ? dds_data_reg   : 0;
assign dds_data_T  = active_dds_bank[0] ? dds_data_T_reg : 0;

assign dds_addr2   = active_dds_bank[1] ? dds_addr_reg   : 0;
assign dds_data2_O = active_dds_bank[1] ? dds_data_reg   : 0;
assign dds_data2_T = active_dds_bank[1] ? dds_data_T_reg : 0;

assign dds_control  = active_dds_bank[0] ? {dds_reset, dds_FUD, dds_r_strobe_n, dds_w_strobe_n} : {0, 1, 1, 1};
assign dds_control2 = active_dds_bank[1] ? {dds_reset, dds_FUD, dds_r_strobe_n, dds_w_strobe_n} : {0, 1, 1, 1};

assign dds_cs = dds_cs_reg;

output [(RESULT_WIDTH-1):0] result_data;
output result_WrReq;

reg [(DDS_OPERAND_WIDTH-1):0] operand_reg;
reg [(DDS_OPCODE_WIDTH-1):0]  opcode_reg;

reg result_WrReq_reg;
reg [(RESULT_WIDTH-1):0] result_reg;

assign result_WrReq = result_WrReq_reg;
assign result_data = result_reg;

reg [3:0]  cycle;
reg [1:0]  sub_cycle;

reg [(N_DDS-1):0] dds_sel_mask; // set active DDS via separate command

// Setup dds_FUD as DDR signal (goes low for a half-period of clock

reg dds_FUD0, dds_FUD1, dds_FUD2; //aux signals for dds_FUD DDR signal
                                  //dds_FUD0 will be low for 1 clock cycle
                                  
// ODDR: Output Double Data Rate Output Register with Set, Reset
// and Clock Enable.
// 7 Series
// Xilinx HDL Libraries Guide, version 14.3
ODDR #(
.DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
.INIT(1'b1), // Initial value of Q: 1'b0 or 1'b1
.SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC"
) ODDR_inst (
.Q(dds_FUD), // 1-bit DDR output
.C(clock), // 1-bit clock input
.CE(1), // 1-bit clock enable input
.D1(dds_FUD0), // 1-bit data input (positive edge)
.D2(1), // 1-bit data input (negative edge)
.R(reset), // 1-bit reset
.S(0) // 1-bit set
);
// End of ODDR_inst instantiation

always @(posedge clock or posedge reset)
begin
  if(reset)
  begin
    cycle <= 0;
    sub_cycle <= 0;
    
    operand_reg <= 0;
    opcode_reg <= 0;
  
    dds_w_strobe_n  <= 1;
    dds_r_strobe_n  <= 1;
    dds_reset <= 0;
    
    dds_cs_reg <= ~0; //all ones
    
    dds_addr_reg  <= 0;
    dds_data_reg  <= 0;
    dds_data_T_reg  <= 1;
    
    result_WrReq_reg <= 0;
    dds_FUD1 <= 1;
    dds_FUD2 <= 1;
  end
  else
  begin 
    if(dds_FUD1 == 1 && dds_FUD2 == 0) begin
      dds_FUD1 <= 0;
      dds_FUD0 <= 0;
    end else
      dds_FUD0 <= 1;
    
    if(cycle == 0)  begin
      dds_w_strobe_n  <= 1;
      dds_r_strobe_n  <= 1;
      dds_reset <= 0;
      
      dds_addr_reg  <= 0;
      dds_data_reg  <= 0;
      dds_data_T_reg <= 0;
      
      result_WrReq_reg <= 0;
      result_reg <= 0;
      
      sub_cycle <= 0;
      dds_sel_mask <= 0;
      
      dds_FUD1 <= 1;
      dds_FUD2 <= 1; 
            
      //wait for write_enable to start
      if(write_enable) begin
        //chip select
        
        if(dds_sel_mask == 0) begin
          dds_cs_reg <= ~(1 << opcode[DDS_ID_B:DDS_ID_A]);
          
          active_dds_bank[0] = opcode[DDS_ID_B:DDS_ID_A]  < DDS_BANK_SIZE;
          active_dds_bank[1] = opcode[DDS_ID_B:DDS_ID_A] >= DDS_BANK_SIZE;
        end else begin
          dds_cs_reg <= ~dds_sel_mask;
          active_dds_bank[0] = 1;
          active_dds_bank[1] = 1;
        end
        
        //latch in operand and opcode
        operand_reg   <= operand;
        opcode_reg    <= opcode;
        
        cycle <= 1;
      end else begin 
        dds_cs_reg <= ~0; //all ones
      end
    end else begin
      case (opcode_reg[3:0])
      0 : begin // set frequency for profile 0
          case(cycle)
          1 : begin dds_addr_reg <= 6'h2F; end
          2 : begin dds_data_reg <= operand_reg[31:16]; dds_w_strobe_n <= 0; end
          3 : begin dds_addr_reg <= 6'h2D; dds_w_strobe_n <= 1; end
          4 : begin dds_data_reg <= operand_reg[15:0]; dds_w_strobe_n <= 0; end
          5 : dds_w_strobe_n <= 1;
          6 : dds_FUD2 <= 0; 
          endcase
          end
          
      1 : begin // set phase (two high bytes), amplitude (two low bytes) for profile 0
          case(cycle)
          1 : begin dds_addr_reg <= 6'h31; end
          2 : begin dds_data_reg <= operand_reg[31:16]; dds_w_strobe_n <= 0; end
          3 : begin dds_addr_reg <= 6'h33; dds_w_strobe_n <= 1; end
          4 : begin dds_data_reg <= operand_reg[15:0]; dds_w_strobe_n <= 0; end
          5 : dds_w_strobe_n <= 1;
          6 : dds_FUD2 <= 0; 
          endcase
          end
          
      2 : begin // set memory word (two bytes) from addr-1 to addr
          case(cycle)
          1 : begin dds_addr_reg <= opcode_reg[DDS_REG_B:DDS_REG_A]; end
          2 : begin dds_data_reg <= operand_reg[15:0]; dds_w_strobe_n <= 0; end
          3 : dds_w_strobe_n <= 1;
          6 : dds_FUD2 <= 0; 
          endcase
          end
          
      3 : begin // get memory word (two bytes) from addr-1 to addr
          case(cycle)
          1 : begin dds_addr_reg <= opcode_reg[DDS_REG_B:DDS_REG_A]; dds_data_T_reg <= 1; result_reg <= 0; end
          3 : dds_r_strobe_n <= 0;
          5 : result_reg[15:0] <= active_dds_bank[0] ? dds_data_I : dds_data2_I; 
          6 : begin dds_r_strobe_n <= 1; result_WrReq_reg <= 1; end
          endcase
          end
          
      4 : begin // DDS reset (should be low for about 10 ns minimum)
          case(cycle)
          1 : dds_reset <= 0;
          5 : dds_reset <= 1;
          endcase
          end
          
      5 : begin // DDS reset (boards selected by operand)
          case(cycle)
          1 : dds_cs_reg <= operand_reg[(N_DDS-1):0];
          3 : dds_reset <= 1;
          6 : dds_reset <= 0;
          endcase
          end
          
      6 : begin // Set active DDS (boards selected by operand).
                // Allows phase synchronization between chips.
                // Don't forget to set dds_sel_mask = 0 when done.
          case(cycle)
          1 : dds_sel_mask <= operand_reg[(N_DDS-1):0];
          endcase
          end
          
      14 : begin // get two memory words (four bytes) from addr-1 to addr+2
          case(cycle)
          1 : begin dds_addr_reg <= opcode_reg[DDS_REG_B:DDS_REG_A]; dds_data_T_reg <= 1; result_reg <= 0; end
          2 : dds_r_strobe_n <= 0; //initiate first read from DDS
          3 : begin // get data on bus
                result_reg[15:0] <= active_dds_bank[0] ? dds_data_I : dds_data2_I; 
                dds_r_strobe_n <= 1; 
                result_WrReq_reg <= 1; //write request to result buffer
                dds_addr_reg <= opcode_reg[DDS_REG_B:DDS_REG_A]+2; //advance address
              end
          //initiate second read from DDS
          4 : begin dds_r_strobe_n <= 0; result_WrReq_reg <= 0; end 
          5 : begin // get data on bus
                result_reg[31:16] <= active_dds_bank[0] ? dds_data_I : dds_data2_I; 
                dds_r_strobe_n <= 1; 
                result_WrReq_reg <= 1; //write request to result buffer
              end
          6 : result_WrReq_reg <= 0;
          endcase
          end
          
      15 : begin // set two memory words (four bytes) from addr-1 to addr+2
          case(cycle)
          1 : begin dds_addr_reg <= opcode_reg[DDS_REG_B:DDS_REG_A]+2; end
          2 : begin dds_data_reg <= operand_reg[31:16]; dds_w_strobe_n <= 0; end
          3 : begin dds_addr_reg <= opcode_reg[DDS_REG_B:DDS_REG_A]; dds_w_strobe_n <= 1; end
          4 : begin dds_data_reg <= operand_reg[15:0]; dds_w_strobe_n <= 0; end
          5 : dds_w_strobe_n <= 1;
          6 : dds_FUD2 <= 0; 
          endcase
          end
      endcase
      
      if(cycle == MAX_CYCLES) cycle <= 0; //All DDS commands require 4*7=28 cycles (280 ns)
      else begin
        sub_cycle <= sub_cycle + 1;
        if(sub_cycle == 2'b11) //divide clock rate by 4 for DDS programming
          cycle <= cycle + 1;
      end
    end
  end
end
  
    
endmodule
