`timescale 1ns / 1ps

/* fifo2: precise timing fifo to control experiments
	
	This is a finite state machine (FSM) connected to a 64 bit wide FIFO,
	and a DDS controller module.
	
	The FSM pulls instructions from the FIFO, and executes them for a precise number 
	of clock cycles.  Instructions consist of one 8-byte FIFO word.
	
	bits 0...3, instruction
	
		Currently there are three instructions:
		0 TIMED_OUTPUT (6 cycles minimum, 4000000 maximum)
				bits 10...31 = duration (in clock cycles, must be at least 6)
				bits 31...63 = output word 
				
		1 DDS_CONTROL (50 cycles)
				bits 15...31 = DDS opcode
				bits 32...63 = DDS operand
				
		2 PMT_READ (read PMT data into rFIFO, 10 cycles)
		
		3 CLEAR_UNDERFLOW (5 cycles)
		
	bit 4, disable underflow flag.  Prevents underflow from going high.
	
	bit 5, count pulses flag.  Enables the PMT counter during this pulse.
*/

module timing_controller(clock, resetn, 
								 iFIFO_Data, iFIFO_DataReady, iFIFO_Ack, result0, 
								 dds_addr, dds_data_I, dds_data_O, dds_data_T, dds_control, dds_cs,
								 ttl_out, underflow_out, counter_in, sync_in,
								 correlation_config_in, correlation_data_out, correlation_data_ready, pulses_finished_out);

parameter N_CORR_BINS = 16;
parameter N_CORR_BITS = 8;

parameter MAX_VAL 					= 32'hFFFFFFFF;
parameter iFIFO_WIDTH 				= 32;
parameter RESULT_WIDTH 				= 32;
parameter TTL_WIDTH					= 32;
parameter TIMER_WIDTH 				= 24;				 
parameter N_DDS 						= 8;
parameter N_COUNTER 					= 1;
parameter DDS_OPCODE_WIDTH 		= 16;
parameter DDS_OPERAND_WIDTH 		= 32;

parameter INSTRUCTION_BITA 		    = 63;
parameter INSTRUCTION_BITB 		    = 60;
parameter PMT_ENABLE_BIT		    = 63-5;
parameter PMT_INVERT_SYNC_BIT		= 63-6;
parameter ENABLE_TIMING_CHECK_BIT	= 63-4;
parameter TIMER_BITA				= 63-8;
parameter TIMER_BITB				= TIMER_BITA - TIMER_WIDTH + 1;
parameter TTL_BITA					= 31;
parameter TTL_BITB					= 0;
 
input  clock;
input  resetn;

input  [(iFIFO_WIDTH-1):0]	iFIFO_Data;
input   iFIFO_DataReady;
output  iFIFO_Ack; //acknowledge that we read the data.  wait until pulse is done.
reg     iFIFO_Ack_reg;

output [(RESULT_WIDTH-1):0] result0;

output [5:0] dds_addr;

//tri-state for dds_data to allow read & write
output [7:0] dds_data_O;
input  [7:0] dds_data_I;
output dds_data_T;

output [3:0] dds_control;
output [(N_DDS-1):0] dds_cs;

input [(N_COUNTER-1):0] counter_in;

input sync_in;
input [6:0] correlation_config_in;
output [(N_CORR_BINS*N_CORR_BITS - 1):0] correlation_data_out;
output correlation_data_ready;

output [(TTL_WIDTH-1):0] 	ttl_out;
output underflow_out;
output pulses_finished_out;

reg   [(TTL_WIDTH-1):0]   ttl_out_reg;
reg	[(TIMER_WIDTH-1):0] timer;
reg	[(TIMER_WIDTH-1):0] iFIFO_timer;

reg 	[2:0] state;

reg	timing_check;
reg	underflow;

reg   data_valid;
reg   pulses_finished;

wire reset;
assign reset = ~resetn;

assign iFIFO_Ack = iFIFO_Ack_reg;
assign ttl_out = ttl_out_reg;
assign underflow_out = underflow;
assign pulses_finished_out = pulses_finished;

reg  dds_we;

reg [(DDS_OPCODE_WIDTH-1):0]  dds_opcode;
reg [(DDS_OPERAND_WIDTH-1):0] dds_operand;

wire dds_WrReq;
wire [31:0] dds_result;

dds_controller #(.N_DDS(N_DDS))
					dds_controller_inst(.clock(clock), .reset(reset), 
											  .write_enable(dds_we), .opcode(dds_opcode), .operand(dds_operand),
											  .dds_addr(dds_addr), 
											  .dds_data_I(dds_data_I), .dds_data_O(dds_data_O), 
											  .dds_data_T(dds_data_T), .dds_control(dds_control), .dds_cs(dds_cs),
											  .result_data(dds_result));


reg PMT_enable; //enable counting on PMT
reg PMT_invert_sync;// invert sync_in of PMT_correlation
reg PMT_RdReq;  //raise high to read result into FIFO

wire PMT_WrReq;
wire [31:0] PMT_result;

wire sync2;
assign sync2 = sync_in ^ PMT_invert_sync;

PMT_counter #(.N_COUNTER(N_COUNTER))
				 PMT_counter_inst(.clock(clock), .reset(reset), .counter_in(counter_in), .count_enable(PMT_enable), 
										.get_result(PMT_RdReq), .result_data(PMT_result));

PMT_correlation #(.N_BINS(N_CORR_BINS), .N_BITS(N_CORR_BITS)) 
	PMT_correlation_inst(
	.clk(clock),
	.reset(reset),
	.configdata_in(correlation_config_in[6:1]),
	.configwrite_in(correlation_config_in[0]),
	.gate_in(PMT_enable),
	.data_out(correlation_data_out),
	.dataready_out(correlation_data_ready),
	.pmt_in(counter_in),
	.sync_in(sync2));

assign result0 = dds_result | PMT_result; 

reg [1:0] instruction_valid;
reg [63:0] instruction;



always @(posedge clock or posedge reset) begin
	if(reset) begin
		state <= 0;
		ttl_out_reg <= 0;
		timer <= 0;
		iFIFO_Ack_reg <= 0;
		dds_we <= 0;
		timing_check <= 0;
		underflow <= 0;
		pulses_finished <= 1;
		PMT_enable <= 0;
		PMT_invert_sync <= 0;
		PMT_RdReq <= 0;
		instruction_valid <= 0;
	end else begin
		
		case (state)	
			//Set FIFO read enable to load the next word, if the fifo has data.
			//If there is no valid instruction and this is not the last pulse, set underflow high.
			0: begin
				iFIFO_Ack_reg <= 0;
			 
				if(instruction_valid == 2) begin
						 state <= 1;
						 PMT_RdReq <= 0; 
						 pulses_finished <= 0;				 
				end else begin
						 underflow <= (underflow || timing_check);
						 PMT_RdReq <= 0;
						 pulses_finished <= 1;
						 timer <= 100;
						 state <= 2; //get next pulse even if there is a timing glitch
				end
			   end
			
			//New data
			1: begin
					state <= 2;
					instruction_valid <= 0;
					timing_check <= instruction[ENABLE_TIMING_CHECK_BIT];
					PMT_enable <= instruction[PMT_ENABLE_BIT];
					PMT_invert_sync <= instruction[PMT_INVERT_SYNC_BIT];
					
					case(instruction[INSTRUCTION_BITA:INSTRUCTION_BITB])
						0 : begin // set digital output
								timer <= instruction[TIMER_BITA:TIMER_BITB];
								ttl_out_reg <= instruction[TTL_BITA:TTL_BITB];
							 end
							 
						1 : begin // DDS instruction
								dds_opcode <= instruction[31:16];
								dds_operand <= instruction[63:32];
								dds_we <= 1; // write to DDS
								timer <= 50;
							 end
							 
						2 : begin //read PMT
								PMT_RdReq <= 1;
								timer <= 10;
							 end
							 
						3 : begin // clear underflow
						        underflow <= 0;
						        timer <= 5;
						    end
						           
						default : timer <= 1000;
					endcase
				 end
					
			2 : begin //decrement timer until it equals the minimum pulse time
					dds_we <= 0; 
					PMT_RdReq <= 0;
				
					if(timer == 4) state <= 0;	// minimum pulse time is 4 cycles		
					else timer <= timer + MAX_VAL; // decrement timer
					
					//get next instruction
					if(instruction_valid !== 2 && iFIFO_Ack_reg == 0 && iFIFO_DataReady) begin
						iFIFO_Ack_reg <= 1;
						
						if(instruction_valid == 0) begin
							instruction[31:0] <= iFIFO_Data[31:0];   //TTL or DDS operand word
							instruction_valid <= 1;
						end else begin
							instruction[63:32] <= iFIFO_Data[31:0];	//Timing, flags or DDS opcode word 
							instruction_valid <= 2;
						end
					end
					else iFIFO_Ack_reg <= 0;
				end
		endcase
	end
end

endmodule
