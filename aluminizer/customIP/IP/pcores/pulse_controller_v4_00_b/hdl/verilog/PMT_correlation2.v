`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// PMT_correlation2
//
// Till Rosenband 1/2/2014
//
// Measure the distribution of pulse times modulo sync
//
// Timing according to Xilinx ISE (Post-PAR Static Timing)
//   Minimum period:   2.337ns{1}   (Maximum frequency: 427.899MHz)
//
// data_out contains N_BIN bins.  Each bin j has an N_BIT value
// that corresponds to the number of pulse_in counts between
// time t=j and t=j+1
// t = # cycles on clock since sync_in
//
// pulse_in and sync_in come from separate hardware,
// and are therefore on different clock domains.
// Furthermore, we have no prior knowledge of the high/low durations.
// Only rising edges will be detected.
// If two rising edges re separated by less than one clock period,
// the second edge may be missed
//
// Pipelined design allows use of only two adders
//
// Notation:
//   valueN means value, delayed by N cycles
module PMT_correlation2(clk, reset, data_out, dataready_out, pulse_in, sync_in, debug);
   parameter N_BIN = 16; // number of bins
   parameter N_BIT = 8;  // number of bits per counter
   parameter N_PHASE_BITS = 4;

   input  wire                   clk;
   input  wire                   reset;

   output wire                          [(N_BIN*N_BIT - 1):0] data_out;
   output wire         dataready_out;
   output wire         [1:0]debug;

   input  wire                     pulse_in;
   input  wire                     sync_in;

   //BEGIN: CROSS CLOCK DOMAINS
   wire pulse;
   CrossDomain pulse_CrossDomain(pulse_in, clk, pulse);

   wire sync;
   CrossDomain sync_CrossDomain(sync_in, clk, sync);
   //END: CROSS CLOCK DOMAINS

   assign debug[0] = pulse;
   assign debug[1] = pulse1;

   //BEGIN: COUNT PHASE DISTRIBUTION OF INCOMING PULSES (main code)
   reg [(N_BIT-1):0] bin[0:(N_BIN-1)]; // bin[phase] is the "active bin"
   reg [(N_BIT-1):0] bin1; //value of previously active bin
   reg [(N_BIT-1):0] bin2; //value of previously-previously active bin
   reg [(N_PHASE_BITS-1):0] phase; //phase with respect to sync
   reg [(N_PHASE_BITS-1):0] phase1; //delay-by-one phase with respect to sync
   reg [(N_PHASE_BITS-1):0] phase2; //delay-by-two phase with respect to sync
   reg wait_for_sync; //wait for first sync before counting pulses

   //delay pulse by one so that bin[j] is incremented
   //whenever pulse was high for phase = j
   reg pulse1;

   //connect bins to data output wires
   genvar i;
   for (i=0; i<N_BIN; i=i+1) assign data_out[((i+1)*N_BIT-1):(i*N_BIT)] = bin[i];

   integer c;
   always @(posedge clk or posedge reset) begin
      if(reset) begin //reset phase, etc
         pulse1 <= 0;
         phase  <= 0;
         phase1 <= N_BIN-1;
         phase2 <= N_BIN-2;
         bin1 <= 0;
         bin2 <= 0;
         wait_for_sync <= 1;

         for (c=0; c<N_BIN; c=c+1) begin
            bin[c] <= 0;
         end
      end else begin
         //reset phase on sync
         if(sync) begin
            phase  <= 0;
            wait_for_sync <= 0;
         end else
           phase  <= phase + 1;

         phase1 <= phase;
         phase2 <= phase1;

         bin1 <= bin[phase];
         bin[phase2] <= bin2;

         pulse1 <= pulse;

         //increment counter on rising edge of pulse_in
         //but wait for initial sync pulse_flag2 &
         if(pulse1 & !wait_for_sync) bin2 <= bin1 + 1;
         else bin2 <= bin1;
      end
   end
   //END: COUNT PHASE DISTRIBUTION OF INCOMING PULSES (main code)
endmodule
