`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:   07:27:26 01/03/2014
// Design Name:   PMT_correlation2
// Module Name:   ise/PMT_corr_test1.v
// Project Name:  PMT_corr
// Target Device:
// Tool versions:
// Description:
//
// Verilog Test Fixture created by ISE for module: PMT_correlation2
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module test1;

   // Inputs
   reg clk;
   reg reset;
   reg pulse_in;
   reg sync_in;

   // Outputs
   wire [127:0] data_out;
   wire dataready_out;

   // Instantiate the Unit Under Test (UUT)
   PMT_correlation2 uut (.clk(clk),
                         .reset(reset),
                         .data_out(data_out),
                         .dataready_out(dataready_out),
                         .pulse_in(pulse_in),
                         .sync_in(sync_in));

   initial begin
      // Initialize Inputs
      clk = 0;
      reset = 1;
      pulse_in = 0;
      sync_in = 0;

      // Wait 50 ns for global reset to finish
      #50;

      // Add stimulus here
      reset = 0;
   end

   // Clock generator
   always begin
      #5  clk = ~clk; // Toggle clock every 5 ticks
   end

   always begin
      #71  pulse_in = 0;
      #71  pulse_in = 1;
   end

   always begin
      #35    sync_in = 0;
      #71    sync_in = 1;
      #35    sync_in = 0;
   end
endmodule
