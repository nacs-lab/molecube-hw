//----------------------------------------------------------------------------
// user_logic.v - module
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// Filename:          user_logic.v
// Version:           4.00.b
// Description:       User logic module.
// Date:              Sat Jul 14 14:34:09 2012 (by Create and Import Peripheral Wizard)
// Verilog Standard:  Verilog-2001
//----------------------------------------------------------------------------
// Naming Conventions:
//   active low signals:                    "*_n"
//   clock signals:                         "clk", "clk_div#", "clk_#x"
//   reset signals:                         "rst", "rst_n"
//   generics:                              "C_*"
//   user defined types:                    "*_TYPE"
//   state machine next state:              "*_ns"
//   state machine current state:           "*_cs"
//   combinatorial signals:                 "*_com"
//   pipelined or register delay signals:   "*_d#"
//   counter signals:                       "*cnt*"
//   clock enable signals:                  "*_ce"
//   internal version of output port:       "*_i"
//   device pins:                           "*_pin"
//   ports:                                 "- Names begin with Uppercase"
//   processes:                             "*_PROCESS"
//   component instantiations:              "<ENTITY_>I_<#|FUNC>"
//----------------------------------------------------------------------------

`uselib lib=unisims_ver
`uselib lib=proc_common_v3_00_a

module user_logic
(
  // -- ADD USER PORTS BELOW THIS LINE ---------------
  // --USER ports added here
  pulse_io,
  dds_addr, dds_data_I, dds_data_O, dds_data_T, dds_control, dds_cs,
  dds_addr2, dds_data2_I, dds_data2_O, dds_data2_T, dds_control2,
  counter_in, sync_in, clock_out,
  // -- ADD USER PORTS ABOVE THIS LINE ---------------

  // -- DO NOT EDIT BELOW THIS LINE ------------------
  // -- Bus protocol ports, do not add to or delete 
  Bus2IP_Clk,                     // Bus to IP clock
  Bus2IP_Resetn,                  // Bus to IP reset
  Bus2IP_Data,                    // Bus to IP data bus
  Bus2IP_Addr,
  Bus2IP_RNW,
  Bus2IP_CS,
  Bus2IP_BE,                      // Bus to IP byte enables
  Bus2IP_RdCE,                    // Bus to IP read chip enable
  Bus2IP_WrCE,                    // Bus to IP write chip enable
  IP2Bus_Data,                    // IP to Bus data bus
  IP2Bus_RdAck,                   // IP to Bus read transfer acknowledgement
  IP2Bus_WrAck,                   // IP to Bus write transfer acknowledgement
  IP2Bus_Error                    // IP to Bus error response
  // -- DO NOT EDIT ABOVE THIS LINE ------------------
); // user_logic

// -- ADD USER PARAMETERS BELOW THIS LINE ------------
// --USER parameters added here
parameter U_PULSE_WIDTH	    = 32;
parameter U_DDS_DATA_WIDTH	= 16;
parameter U_DDS_ADDR_WIDTH	= 7;
parameter U_DDS_CTRL_WIDTH	= 4;
parameter N_DDS = 8;
parameter N_COUNTER = 1;
parameter N_CORR_BINS = 16;
parameter N_CORR_BITS = 8; 
// -- ADD USER PARAMETERS ABOVE THIS LINE ------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol parameters, do not add to or delete
parameter C_NUM_REG                      = 32;
parameter C_SLV_DWIDTH                   = 32;
parameter C_SLV_AWIDTH                   = 32;
parameter C_SLV_CSWIDTH                   = 2;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

// -- ADD USER PORTS BELOW THIS LINE -----------------
// --USER ports added here 
output [0:(U_PULSE_WIDTH-1)] pulse_io;

//DDS ports
output [0:(U_DDS_ADDR_WIDTH-1)] dds_addr;
output [0:(U_DDS_ADDR_WIDTH-1)] dds_addr2;

//tri-state for dds_data to allow read & write
output [0:(U_DDS_DATA_WIDTH-1)] dds_data_O;
input  [0:(U_DDS_DATA_WIDTH-1)] dds_data_I;
output [0:(U_DDS_DATA_WIDTH-1)] dds_data2_O;
input  [0:(U_DDS_DATA_WIDTH-1)] dds_data2_I;
output dds_data_T, dds_data2_T;

output [0:(U_DDS_CTRL_WIDTH-1)] dds_control;
output [0:(U_DDS_CTRL_WIDTH-1)] dds_control2;

output [0:(N_DDS-1)] dds_cs;

input [0:(N_COUNTER-1)] counter_in;
input sync_in;

output clock_out;


// -- ADD USER PORTS ABOVE THIS LINE -----------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol ports, do not add to or delete
input                                     Bus2IP_Clk;
input                                     Bus2IP_Resetn;
input      [C_SLV_DWIDTH-1 : 0]           Bus2IP_Data;
input      [C_SLV_DWIDTH/8-1 : 0]         Bus2IP_BE;
input      [C_NUM_REG-1 : 0]              Bus2IP_RdCE;
input      [C_NUM_REG-1 : 0]              Bus2IP_WrCE;
output     [C_SLV_DWIDTH-1 : 0]           IP2Bus_Data;
input      [C_SLV_AWIDTH-1 : 0]           Bus2IP_Addr;
input                                     Bus2IP_RNW;
input	     [C_SLV_CSWIDTH-1 : 0]          Bus2IP_CS;
output                                    IP2Bus_RdAck;
output                                    IP2Bus_WrAck;
output                                    IP2Bus_Error;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

//----------------------------------------------------------------------------
// Implementation
//----------------------------------------------------------------------------

  // --USER nets declarations added here, as needed for user logic
wire [0:(C_SLV_DWIDTH-1)] result;
wire underflow_out;
wire correlation_data_ready;
wire pulses_finished_out;
wire [(N_CORR_BINS*N_CORR_BITS-1):0] correlation_data_out;

  // Nets for user logic slave model s/w accessible register example
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg0;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg1;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg2;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg3;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg4;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg5;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg6;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg7;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg8;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg9;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg10;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg11;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg12;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg13;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg14;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg15;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg16;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg17;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg18;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg19;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg20;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg21;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg22;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg23;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg24;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg25;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg26;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg27;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg28;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg29;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg30;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_reg31;
  wire       [31 : 0]                       slv_reg_write_sel;
  wire       [31 : 0]                       slv_reg_read_sel;
  reg        [C_SLV_DWIDTH-1 : 0]           slv_ip2bus_data;
  wire                                      slv_read_ack;
  reg                                       slv_write_ack;
  integer                                   byte_index, bit_index;

// USER logic implementation added here

//rFIFO = results FIFO.  Access by reading slave register 31
//If using register 31, must check that there is a value in the FIFO to read.  Otherwise things will get messed up.
//Register 2 contains rFIFO occupancy.  There is no overflow protection, so don't stuff more than rFIFO_DEPTH results

parameter rFIFO_DEPTH = 32;
parameter rFIFO_ADDR_BITS = 5;
reg [31:0] rFIFO [0:(rFIFO_DEPTH-1)];
reg [(rFIFO_ADDR_BITS-1):0]  rFIFO_write_addr;
reg [(rFIFO_ADDR_BITS-1):0]  rFIFO_read_addr;
reg [(rFIFO_ADDR_BITS-1):0]  rFIFO_fill;

//acknowledge read-requests immediately
//data will be available on IP2Bus_Data
    
  assign
    slv_reg_write_sel = Bus2IP_WrCE[31:0],
    slv_reg_read_sel  = Bus2IP_RdCE[31:0],
    slv_read_ack      = Bus2IP_RdCE[0] || Bus2IP_RdCE[1] || Bus2IP_RdCE[2] || Bus2IP_RdCE[3] || Bus2IP_RdCE[4] || Bus2IP_RdCE[5] || Bus2IP_RdCE[6] || Bus2IP_RdCE[7] || Bus2IP_RdCE[8] || Bus2IP_RdCE[9] || Bus2IP_RdCE[10] || Bus2IP_RdCE[11] || Bus2IP_RdCE[12] || Bus2IP_RdCE[13] || Bus2IP_RdCE[14] || Bus2IP_RdCE[15] || Bus2IP_RdCE[16] || Bus2IP_RdCE[17] || Bus2IP_RdCE[18] || Bus2IP_RdCE[19] || Bus2IP_RdCE[20] || Bus2IP_RdCE[21] || Bus2IP_RdCE[22] || Bus2IP_RdCE[23] || Bus2IP_RdCE[24] || Bus2IP_RdCE[25] || Bus2IP_RdCE[26] || Bus2IP_RdCE[27] || Bus2IP_RdCE[28] || Bus2IP_RdCE[29] || Bus2IP_RdCE[30] || Bus2IP_RdCE[31];

  // implement slave model register(s)
  always @( posedge Bus2IP_Clk )
    begin

      if ( Bus2IP_Resetn == 1'b0 )
             begin
		  slv_reg0 <= 0;
		  slv_reg1 <= 0;
		  slv_reg2 <= 0;
		  slv_reg3 <= 0;
		  slv_reg4 <= 0;
		  slv_reg5 <= 0;
		  slv_reg6 <= 0;
		  slv_reg7 <= 0;
		  slv_reg8 <= 0;
		  slv_reg9 <= 0;
		  slv_reg10 <= 0;
		  slv_reg11 <= 0;
		  slv_reg12 <= 0;
		  slv_reg13 <= 0;
		  slv_reg14 <= 0;
		  slv_reg15 <= 0;
		  slv_reg16 <= 0;
		  slv_reg17 <= 0;
		  slv_reg18 <= 0;
		  slv_reg19 <= 0;
		  slv_reg20 <= 0;
		  slv_reg21 <= 0;
		  slv_reg22 <= 0;
		  slv_reg23 <= 0;
		  slv_reg24 <= 0;
		  slv_reg25 <= 0;
		  slv_reg26 <= 0;
		  slv_reg27 <= 0;
		  slv_reg28 <= 0;
		  slv_reg29 <= 0;
		  slv_reg30 <= 0;
		  slv_reg31 <= 0;
		end
      else
      
	  if(slv_write_ack == 1) 
	  	slv_write_ack <= 0; 
	  else begin
	  	case ( slv_reg_write_sel )
		32'b10000000000000000000000000000000 : begin slv_reg0 <= Bus2IP_Data; slv_write_ack <= 1; end
		32'b01000000000000000000000000000000 : begin slv_reg1 <= Bus2IP_Data; slv_write_ack <= 1; end
		32'b00010000000000000000000000000000 : begin slv_reg3 <= Bus2IP_Data; slv_write_ack <= 1; end
		default:
			begin //this came from Xilinx.  Don't know what it does.
			    slv_reg0 <= slv_reg0;
			    slv_reg1 <= slv_reg1;
			    slv_reg2 <= slv_reg2;
			    slv_reg3 <= slv_reg3;
			    slv_reg4 <= slv_reg4;
			    slv_reg5 <= slv_reg5;
			    slv_reg6 <= slv_reg6;
			    slv_reg7 <= slv_reg7;
			    slv_reg8 <= slv_reg8;
			    slv_reg9 <= slv_reg9;
			    slv_reg10 <= slv_reg10;
			    slv_reg11 <= slv_reg11;
			    slv_reg12 <= slv_reg12;
			    slv_reg13 <= slv_reg13;
			    slv_reg14 <= slv_reg14;
			    slv_reg15 <= slv_reg15;
			    slv_reg16 <= slv_reg16;
			    slv_reg17 <= slv_reg17;
			    slv_reg18 <= slv_reg18;
			    slv_reg19 <= slv_reg19;
			    slv_reg20 <= slv_reg20;
			    slv_reg21 <= slv_reg21;
			    slv_reg22 <= slv_reg22;
			    slv_reg23 <= slv_reg23;
			    slv_reg24 <= slv_reg24;
			    slv_reg25 <= slv_reg25;
			    slv_reg26 <= slv_reg26;
			    slv_reg27 <= slv_reg27;
			    slv_reg28 <= slv_reg28;
			    slv_reg29 <= slv_reg29;
			    slv_reg30 <= slv_reg30;
			    slv_reg31 <= slv_reg31;
			end
	  endcase
      
  	   	  
	  slv_reg2[0] <= underflow_out;
	  slv_reg2[1] <= correlation_data_ready;
	  slv_reg2[2] <= pulses_finished_out;
	  slv_reg2[(rFIFO_ADDR_BITS+3):4] <= rFIFO_fill;
	 
	  slv_reg4 <= correlation_data_out[31:0];
	  slv_reg5 <= correlation_data_out[63:32];
	  slv_reg6 <= correlation_data_out[95:64];
	  slv_reg7 <= correlation_data_out[127:96];

	end
end // SLAVE_REG_WRITE_PROC

  // implement slave model register read mux
//  always @( posedge Bus2IP_Clk )
//    begin 
//		if(Bus2IP_RNW && (Bus2IP_CS[0]) ) begin
//			case ( Bus2IP_Addr[4:0] )
//			  0 : slv_ip2bus_data <= slv_reg0;
//			  1 : slv_ip2bus_data <= slv_reg1;
//			  2 : slv_ip2bus_data <= slv_reg2;
//			  3 : slv_ip2bus_data <= slv_reg3;
//			  4 : slv_ip2bus_data <= slv_reg4;
//			  5 : slv_ip2bus_data <= slv_reg5;
//			  6 : slv_ip2bus_data <= slv_reg6;
//			  7 : slv_ip2bus_data <= slv_reg7;
//			  31 : slv_ip2bus_data <= rFIFO[rFIFO_read_addr];
//			  default : slv_ip2bus_data <= 0;
//			endcase
//		end
  //  end // SLAVE_REG_READ_PROC

always @( slv_reg_read_sel or slv_reg0 or slv_reg1 or slv_reg2 or slv_reg3 or slv_reg4 or slv_reg5 or slv_reg6 or slv_reg7 or slv_reg8 or slv_reg9 or slv_reg10 or slv_reg11 or slv_reg12 or slv_reg13 or slv_reg14 or slv_reg15 or slv_reg16 or slv_reg17 or slv_reg18 or slv_reg19 or slv_reg20 or slv_reg21 or slv_reg22 or slv_reg23 or slv_reg24 or slv_reg25 or slv_reg26 or slv_reg27 or slv_reg28 or slv_reg29 or slv_reg30 or slv_reg31 )
    begin 

      case ( slv_reg_read_sel )
        32'b10000000000000000000000000000000 : slv_ip2bus_data <= slv_reg0;
        32'b01000000000000000000000000000000 : slv_ip2bus_data <= slv_reg1;
        32'b00100000000000000000000000000000 : slv_ip2bus_data <= slv_reg2;
        32'b00010000000000000000000000000000 : slv_ip2bus_data <= slv_reg3;
        32'b00001000000000000000000000000000 : slv_ip2bus_data <= slv_reg4;
        32'b00000100000000000000000000000000 : slv_ip2bus_data <= slv_reg5;
        32'b00000010000000000000000000000000 : slv_ip2bus_data <= slv_reg6;
        32'b00000001000000000000000000000000 : slv_ip2bus_data <= slv_reg7;
        32'b00000000100000000000000000000000 : slv_ip2bus_data <= slv_reg8;
        32'b00000000010000000000000000000000 : slv_ip2bus_data <= slv_reg9;
        32'b00000000001000000000000000000000 : slv_ip2bus_data <= slv_reg10;
        32'b00000000000100000000000000000000 : slv_ip2bus_data <= slv_reg11;
        32'b00000000000010000000000000000000 : slv_ip2bus_data <= slv_reg12;
        32'b00000000000001000000000000000000 : slv_ip2bus_data <= slv_reg13;
        32'b00000000000000100000000000000000 : slv_ip2bus_data <= slv_reg14;
        32'b00000000000000010000000000000000 : slv_ip2bus_data <= slv_reg15;
        32'b00000000000000001000000000000000 : slv_ip2bus_data <= slv_reg16;
        32'b00000000000000000100000000000000 : slv_ip2bus_data <= slv_reg17;
        32'b00000000000000000010000000000000 : slv_ip2bus_data <= slv_reg18;
        32'b00000000000000000001000000000000 : slv_ip2bus_data <= slv_reg19;
        32'b00000000000000000000100000000000 : slv_ip2bus_data <= slv_reg20;
        32'b00000000000000000000010000000000 : slv_ip2bus_data <= slv_reg21;
        32'b00000000000000000000001000000000 : slv_ip2bus_data <= slv_reg22;
        32'b00000000000000000000000100000000 : slv_ip2bus_data <= slv_reg23;
        32'b00000000000000000000000010000000 : slv_ip2bus_data <= slv_reg24;
        32'b00000000000000000000000001000000 : slv_ip2bus_data <= slv_reg25;
        32'b00000000000000000000000000100000 : slv_ip2bus_data <= slv_reg26;
        32'b00000000000000000000000000010000 : slv_ip2bus_data <= slv_reg27;
        32'b00000000000000000000000000001000 : slv_ip2bus_data <= slv_reg28;
        32'b00000000000000000000000000000100 : slv_ip2bus_data <= slv_reg29;
        32'b00000000000000000000000000000010 : slv_ip2bus_data <= slv_reg30;
        32'b00000000000000000000000000000001 : slv_ip2bus_data <= rFIFO[rFIFO_read_addr];
        default : slv_ip2bus_data <= 0;
      endcase

    end // SLAVE_REG_READ_PROC
// Register map. 
//   write means CPU writes to this register
//   read means CPU reads this register
// slv_reg0 -- ttl high mask (write)
// slv_reg1 -- ttl low mask (write)
//   pulse_io = (ttl_out | slv_reg0) & (~slv_reg1)
//
// slv_reg2 -- status (read)
//   slv_reg2[0] <= underflow_out;
//   slv_reg2[1] <= correlation_data_ready;
//   slv_reg2[2] <= pulses_finished_out;
//   slv_reg2[(rFIFO_ADDR_BITS+3):4] <= rFIFO_fill;
//
// slv_reg3 -- control (write)
//   slv_reg3[0] => correlation_reset
//   slv_reg3[7] => pulse_controller_hold.  nothing happens when this is high
//   slv_reg3[8] => init.  toggle at start of sequence for reset

// slv_reg4 <= correlation_data_out[31:0];
// slv_reg5 <= correlation_data_out[63:32];
// slv_reg6 <= correlation_data_out[95:64];
// slv_reg7 <= correlation_data_out[127:96];
//
// slv_reg31 -- output of result FIFO (read)

  // ------------------------------------------------------------
  // Drive IP to Bus signals
  // ------------------------------------------------------------

  assign IP2Bus_Data = (slv_read_ack == 1'b1) ? slv_ip2bus_data :  0 ;
  assign IP2Bus_WrAck = tc_write_ack || slv_write_ack;
  assign IP2Bus_RdAck = slv_read_ack;
  assign IP2Bus_Error = 0;

// push a word onto rFIFO on rising edges of rFIFO_WrReq
wire rFIFO_WrReq;
wire rFIFO_WrReqPosEdge;
reg rFIFO_WrReqPrev;
assign rFIFO_WrReqPosEdge = rFIFO_WrReq & ~rFIFO_WrReqPrev;

//increment rFIFO_read_addr on falling edges of rFIFO_RdReq
wire rFIFO_RdReq;
reg rFIFO_RdReqPrev;
wire rFIFO_RdReqNegEdge;
assign rFIFO_RdReq = (slv_reg_read_sel == 32'b00000000000000000000000000000001);
assign rFIFO_RdReqNegEdge = ~rFIFO_RdReq & rFIFO_RdReqPrev;

always @( posedge Bus2IP_Clk)
begin
   if(~Bus2IP_Resetn) begin
	   rFIFO_fill <= 0;
	   rFIFO_read_addr <= 0;
	   rFIFO_write_addr <= 0;
	   rFIFO_WrReqPrev <= 0;
	   rFIFO_RdReqPrev <= 0;
	end else begin
	    rFIFO_WrReqPrev <= rFIFO_WrReq;
	    rFIFO_RdReqPrev <= rFIFO_RdReq;
	    
		if(rFIFO_WrReqPosEdge) begin
			rFIFO[rFIFO_write_addr] <= result; 
         	rFIFO_write_addr <= rFIFO_write_addr+1; 
		end
		
		if(rFIFO_RdReq) //rFIFO_RdReq should de-assert after one cycle.
		    rFIFO_read_addr <= rFIFO_read_addr+1;
		
		if(rFIFO_WrReqPosEdge & !rFIFO_RdReq)
		    rFIFO_fill <= rFIFO_fill+1;
		    
		if(!rFIFO_WrReqPosEdge & rFIFO_RdReq)
		    rFIFO_fill <= rFIFO_fill+31;
	end
end

wire tc_write_ack;
wire [(U_PULSE_WIDTH-1):0] ttl_out;

//assume slave register width == pulse width
assign pulse_io = (ttl_out | slv_reg0) & (~slv_reg1);

//Writing to register 31 sends data to timing controller
wire tc_instruction_ready = (slv_reg_write_sel ==  32'b00000000000000000000000000000001 );

timing_controller 
  #(.N_CORR_BINS(N_CORR_BINS), 
    .N_CORR_BITS(N_CORR_BITS), 
    .N_DDS(N_DDS), 
    .U_DDS_DATA_WIDTH(U_DDS_DATA_WIDTH), 
    .U_DDS_ADDR_WIDTH(U_DDS_ADDR_WIDTH), 
    .U_DDS_CTRL_WIDTH(U_DDS_CTRL_WIDTH), 
    .N_COUNTER(N_COUNTER), 
    .BUS_DATA_WIDTH(C_SLV_DWIDTH), 
    .RESULT_WIDTH(C_SLV_DWIDTH))
  tc(
  .clock(Bus2IP_Clk), 
  .resetn(Bus2IP_Resetn), 
	.bus_data(Bus2IP_Data), 
  .bus_data_ready(tc_instruction_ready), 
  .bus_data_ack(tc_write_ack), 
  .rFIFO_data(result), 
  .rFIFO_WrReq(rFIFO_WrReq),
  .dds_addr(dds_addr), 
	.dds_data_I(dds_data_I), 
  .dds_data_O(dds_data_O), 
	.dds_data_T(dds_data_T), 
  .dds_control(dds_control), 
  .dds_addr2(dds_addr2), 
	.dds_data2_I(dds_data2_I), 
  .dds_data2_O(dds_data2_O), 
	.dds_data2_T(dds_data2_T), 
  .dds_control2(dds_control2), 
  .dds_cs(dds_cs),
	.ttl_out(ttl_out), 
  .underflow_out(underflow_out),
	.counter_in(counter_in), 
  .sync_in(sync_in),
	.correlation_reset(slv_reg3[0]), 
  .correlation_data_out(correlation_data_out), 
  .correlation_data_ready(correlation_data_ready), 
  .pulses_finished_out(pulses_finished_out),
  .pulse_controller_hold(slv_reg3[7]),
  .init(slv_reg3[8]),
  .clock_out(clock_out));

endmodule
