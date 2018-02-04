`timescale 1 ns / 1 ps

module clock_out_controller
  #(parameter CLOCK_WIDTH = 8)
   (input clock, input reset, input [(CLOCK_WIDTH - 1):0] div, output reg out);
   reg [(CLOCK_WIDTH - 1):0] counter;
   always @(posedge clock, posedge reset) begin
      if (reset | div == (1 << CLOCK_WIDTH) - 1) begin
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
