`timescale 1ns / 1ps

/* timing_controller: precise timing FIFO to control experiments
  
  The FIFO is attached to an AXI bus for writing.  The timing controller reads words from the FIFO
  in a precisely timed manner for digital control in a laboratory.  The controller
  can output TTL words for a variable number of clock cycles, and write to a bank of attached
  DDS modules (AD9858 and AD9914).  A flag can be set to count photons (# of rising edges on an input).
  The phase of the photon arrival times with respect to a sync clock can be tracked.
  
  DDS and photon counts can be read back via a second read FIFO.
  
  Underflow of the write FIFO (timing failure) can be detected.
  
  This is implemented as a finite state machine (FSM) with attached
  DDS control and PMT modules.
    
  bits 63...60, instruction
  
    Currently there are 6 instructions:
    
    0 TIMED_OUTPUT (6 cycles minimum, 2^24 - 1 = 16,777,215 maximum)
        bits 55...32 = duration (in clock cycles, must be at least 6)
        bits 31...0  = output word 
        
    1 DDS_CONTROL (50 cycles, purposely slowed because the external DDS bus is not so fast)
        bits 47...32 = DDS opcode (read and write freq/phase/amplitude/registers)
        bits 31...0  = DDS operand (phase/frequency/amplitude/register value)
        
    2 PMT_READ (read PMT data into rFIFO, 10 cycles)
    
    3 CLEAR_UNDERFLOW (5 cycles)
    
    4 PUSH_DATA (variable # cycles)
            bits 55...32 = duration (in clock cycles)
            push bits 31...0 onto rFIFO for loop-back testing
    
    5 ENABLE/DISABLE CLOCK OUT bit 0 = high/low 
    
  bit 59, disable underflow flag.  Prevents underflow from going high.
  
  bit 58, count pulses flag.  Enables the PMT counter during this pulse.

Post-PAR timing for Zynq ZC702 speed -1:
   Minimum period:   4.916ns{1}   (Maximum frequency: 203.417MHz)
  
*/

module timing_controller(clock, resetn, 
       bus_data, bus_data_ready, bus_data_ack, 
       rFIFO_data, rFIFO_WrReq,
       dds_addr, dds_data_I, dds_data_O, dds_data_T, dds_control, 
       dds_addr2, dds_data2_I, dds_data2_O, dds_data2_T, dds_control2, dds_cs,
       dds_FUD, dds_syncO, dds_syncI, ttl_out, underflow_out, counter_in, sync_in,
       correlation_reset, correlation_data_out, correlation_data_ready, pulses_finished_out,
       pulse_controller_hold, init, clock_out);

parameter N_CORR_BINS = 16;
parameter N_CORR_BITS = 8;

parameter MAX_VAL         = 24'hFFFFFF;
parameter BUS_DATA_WIDTH      = 32;
parameter RESULT_WIDTH        = 32;
parameter TTL_WIDTH       = 32;
parameter TIMER_WIDTH         = 24;        
parameter N_DDS         = 8;
parameter U_DDS_DATA_WIDTH  = 16;
parameter U_DDS_ADDR_WIDTH  = 7;
parameter U_DDS_CTRL_WIDTH  = 3;
parameter N_COUNTER         = 1;
parameter DDS_OPCODE_WIDTH      = 16;
parameter DDS_OPERAND_WIDTH       = 32;

parameter INSTRUCTION_BITA     = 63;
parameter INSTRUCTION_BITB     = 60;
parameter PMT_ENABLE_BIT     = 63-5; //0x04000000
parameter PMT_INVERT_SYNC_BIT   = 63-6;  //0x02000000
parameter ENABLE_TIMING_CHECK_BIT = 63-4;  //0x08000000
parameter TIMER_BITA      = 63-8;
parameter TIMER_BITB      = TIMER_BITA - TIMER_WIDTH + 1;
parameter TTL_BITA      = 31;
parameter TTL_BITB      = 0;
 
//parameter CLOCK_OUT_DIV = 100;

input  clock;
input  resetn;
input  init; //init is like reet, but hold the current TTL outputs
//toggle this at the start of the sequence.

input  pulse_controller_hold; //pulses wait until this goes low

input  [(BUS_DATA_WIDTH-1):0] bus_data;
input   bus_data_ready;
output  bus_data_ack; //acknowledge that we read the data

output [(RESULT_WIDTH-1):0] rFIFO_data;
output rFIFO_WrReq;

output [(U_DDS_ADDR_WIDTH-1):0] dds_addr;
output [(U_DDS_ADDR_WIDTH-1):0] dds_addr2;

//tri-state for dds_data to allow read & write
output [(U_DDS_DATA_WIDTH-1):0] dds_data_O;
input  [(U_DDS_DATA_WIDTH-1):0] dds_data_I;
output dds_data_T;

output [(U_DDS_DATA_WIDTH-1):0] dds_data2_O;
input  [(U_DDS_DATA_WIDTH-1):0] dds_data2_I;
output dds_data2_T;

output [(U_DDS_CTRL_WIDTH-1):0] dds_control;
output [(U_DDS_CTRL_WIDTH-1):0] dds_control2;

output [1:0] dds_FUD;
output [(N_DDS-1):0] dds_cs;
input dds_syncI;
output dds_syncO;

input [(N_COUNTER-1):0] counter_in;

input sync_in;
input correlation_reset;
output [(N_CORR_BINS*N_CORR_BITS - 1):0] correlation_data_out;
output correlation_data_ready;

output [(TTL_WIDTH-1):0]  ttl_out;
output underflow_out;
output pulses_finished_out;

output clock_out;
reg clock_out_reg;
reg [7:0] clock_out_counter;
reg [7:0] clock_out_div;

assign clock_out=clock_out_reg;

reg   [(TTL_WIDTH-1):0]   ttl_out_reg;
reg [(TIMER_WIDTH-1):0] timer;
reg [(TIMER_WIDTH-1):0] iFIFO_timer;

reg   [2:0] state;

reg timing_check;
reg underflow;

reg   data_valid;
reg   pulses_finished;

wire reset;
assign reset = ~resetn;

wire [1:0]debug;
assign ttl_out = {ttl_out_reg[31:2], ttl_out_reg[1:0] ^ debug[1:0]};
assign underflow_out = underflow;
assign pulses_finished_out = pulses_finished;

reg  dds_we;

reg [(DDS_OPCODE_WIDTH-1):0]  dds_opcode;
reg [(DDS_OPERAND_WIDTH-1):0] dds_operand;

wire dds_WrReq;
wire [0:31] dds_result;

dds_controller #( .N_DDS(N_DDS),
                  .DDS_OPCODE_WIDTH(DDS_OPCODE_WIDTH),
                  .DDS_OPERAND_WIDTH(DDS_OPERAND_WIDTH),
                  .U_DDS_DATA_WIDTH(U_DDS_DATA_WIDTH), 
                  .U_DDS_ADDR_WIDTH(U_DDS_ADDR_WIDTH), 
                  .U_DDS_CTRL_WIDTH(U_DDS_CTRL_WIDTH))
  dds_controller_inst(
    .clock(clock), 
    .reset(reset), 
    .write_enable(dds_we),
    .opcode(dds_opcode),
    .operand(dds_operand),
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
    .dds_FUD(dds_FUD),
    .result_data(dds_result), 
    .result_WrReq(dds_WrReq));

reg PMT_enable;      //enable counting on PMT
reg PMT_invert_sync; // invert sync_in of PMT_correlation
reg PMT_RdReq;       //raise high to put result into FIFO

wire PMT_WrReq;
wire [31:0] PMT_result;

wire sync2;
assign sync2 = sync_in ^ PMT_invert_sync;

PMT_counter #(.N_COUNTER(N_COUNTER))
  PMT_counter_inst(
    .clock(clock), 
    .reset(reset), 
    .counter_in(counter_in), 
    .count_enable(PMT_enable), 
   .get_result(PMT_RdReq), 
    .result_data(PMT_result), 
    .result_WrReq(PMT_WrReq));

PMT_correlation2 #(.N_BIN(N_CORR_BINS), .N_BIT(N_CORR_BITS)) 
  PMT_correlation_inst(
  .clk(clock),
  .reset(reset | correlation_reset),
  .data_out(correlation_data_out),
  .dataready_out(correlation_data_ready),
  .pulse_in(counter_in & PMT_enable),
  .sync_in(sync2),
  .debug(debug));

reg [31:0] loopback_data;
reg loopback_WrReq;

//allow PMT_counter or DDS_controller or loop back to write into the rFIFO
assign rFIFO_WrReq  = dds_WrReq  | PMT_WrReq | loopback_WrReq;
assign rFIFO_data = dds_result | PMT_result | loopback_data; 

reg [63:0] instruction;

wire [63:0]  extended_bus_data;
assign extended_bus_data[31:0] = 32'h00000000;
assign extended_bus_data[63:32] = bus_data[31:0];

//FIFO data
parameter FIFO_DEPTH          = 256;
parameter FIFO_ADDR_BTS         = 8;
reg [63:0] fifo [0:(FIFO_DEPTH-1)];
reg [31:0] fifo_low_word;
reg [(FIFO_ADDR_BTS-1):0]  fifo_write_addr;
reg [(FIFO_ADDR_BTS-1):0]  fifo_read_addr;
reg [(FIFO_ADDR_BTS-1):0]  fifo_prev_read_addr;


//Control reading of 32 bit words into 64 bit wide FIFO
reg fifo_next_word_dest; 

//acknowledge if FIFO has space
assign bus_data_ack = (fifo_write_addr !== fifo_prev_read_addr) && bus_data_ready;

wire fifo_full;
assign fifo_full = (fifo_write_addr == fifo_prev_read_addr);

//goes high when fifo_full is true.  also goes low at last pulse;
reg force_release;

//pulses_hold will be released if FIFO is full or pulse_controller_hold is low
//once released, the controller runs until it is done
wire pulses_hold;
assign pulses_hold = pulse_controller_hold & ~force_release;


always @(posedge clock or posedge reset) begin
  if(reset | init) begin
    if(reset) begin
      ttl_out_reg <= 0;
    end
    
    state <= 0;
    timer <= 0;
    dds_we <= 0;
    timing_check <= 0;
    underflow <= 0;
    pulses_finished <= 1;
    PMT_enable <= 0;
    PMT_invert_sync <= 0;
    PMT_RdReq <= 0;
    loopback_data <= 0;
    loopback_WrReq <= 0;
    fifo_next_word_dest <= 0;
    fifo_write_addr <= 0;
    fifo_read_addr <= 0;  
    fifo_prev_read_addr <= (FIFO_DEPTH-1);  
    clock_out_reg <= 0;
    clock_out_counter <= 0;
    clock_out_div <= 255;
    force_release <= 0;
  end else begin
    //Get new instructions if FIFO has space.  The bus will hang if FIFO is full, until there is space.
    if(bus_data_ack) begin
      if(fifo_next_word_dest == 0) begin
        fifo_low_word <= bus_data;   //TTL or DDS operand word
        fifo_next_word_dest <= 1;
      end else begin
        fifo[fifo_write_addr] <= extended_bus_data | fifo_low_word; //Timing, flags or DDS opcode word
        fifo_write_addr <= fifo_write_addr+1;
        fifo_next_word_dest <= 0;
      end
    end
        
    //emit divided clock with period 2 x (clock_out_div+1) when clock_out_enable=1 
    
    if(clock_out_div == 255) begin //reset clock_out
      clock_out_counter <= 0;
      clock_out_reg <= 0;
    end else begin
      if(clock_out_counter == clock_out_div) begin
        clock_out_counter <= 0;
        clock_out_reg <= ~clock_out_reg;
      end else 
        clock_out_counter <= clock_out_counter + 1;
    end
  
    force_release <= force_release | fifo_full;
    
    case (state)  
      //If there are no more instructions, set underflow high.
      0: begin
          loopback_WrReq <= 0;
          loopback_data <= 0;
          
          //here read_addr == write_addr means FIFO is empty
        if((fifo_read_addr !== fifo_write_addr) & ~pulses_hold) begin
             state <= 1;
             PMT_RdReq <= 0; 
             pulses_finished <= 0;
             instruction <= fifo[fifo_read_addr]; 
             fifo_prev_read_addr <= fifo_read_addr;
             fifo_read_addr <= fifo_read_addr+1;
        end else begin
              PMT_RdReq <= 0;
              pulses_finished <= 1;
              underflow <= (underflow || timing_check); //underflow bit is sticky 
        end
      end
      
      //New data
      1: begin
          state <= 2;
          timing_check <= instruction[ENABLE_TIMING_CHECK_BIT];
          PMT_enable <= instruction[PMT_ENABLE_BIT];
          PMT_invert_sync <= instruction[PMT_INVERT_SYNC_BIT];
          
          case(instruction[INSTRUCTION_BITA:INSTRUCTION_BITB])
            0 : begin // set digital output
                timer <= instruction[TIMER_BITA:TIMER_BITB];
                ttl_out_reg <= instruction[TTL_BITA:TTL_BITB];
               end
               
            1 : begin // DDS instruction
                dds_opcode <= instruction[47:32];
                dds_operand <= instruction[31:0];
                dds_we <= 1; // write to DDS
                timer <= 30; //instruction takes 280 ns.  Allocate 300 ns.
               end
               
            2 : begin //read PMT
                PMT_RdReq <= 1;
                timer <= 10;
               end
               
            3 : begin // clear underflow
                    underflow <= 0;
                    timer <= 5;
                end
                
            4 : begin // loop-back data
                    loopback_data <= instruction[31:0];
                    loopback_WrReq <= 1;
                    timer <= 5;
                end
            
            5 : begin // enable/disable clock_out       
                  clock_out_div <= instruction[7:0];
                  timer <= 5;
                end
                
            default : timer <= 1000;
          endcase
         end
          
      2 : begin //decrement timer until it equals the minimum pulse time
          dds_we <= 0; 
          PMT_RdReq <= 0;

          if(timer == 3) state <= 0;  // minimum pulse time is 3 cycles   
          else timer <= timer + MAX_VAL; // decrement timer
        end
    endcase
  end
end

endmodule