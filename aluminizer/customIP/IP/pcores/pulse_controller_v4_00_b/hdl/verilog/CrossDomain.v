/* Cross clock domains.  

Copied from here, with small modifications:
http://www.fpga4fun.com/CrossClockDomain2.html

"The trick is to transform the flags into level changes, 
and then use the two flip-flops technique."

*/

module CrossDomain(
    input InA,
    input clkB,
    output OutB
);

// this changes level on rising edges of InA
reg Toggle;
always @(posedge InA) Toggle <= Toggle ^ InA;

// which can then be sync-ed to clkB
reg [2:0] SyncA_clkB;
always @(posedge clkB) SyncA_clkB <= {SyncA_clkB[1:0], Toggle};

// and recreate the flag in clkB
assign OutB = (SyncA_clkB[2] ^ SyncA_clkB[1]);

// initialize for simulation
initial begin
  Toggle = 0;
end

endmodule
