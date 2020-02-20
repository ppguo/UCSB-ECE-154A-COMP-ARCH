`timescale 1ns/100ps
module tb();
reg clk,reset;
top top_1(.clk(clk),.reset(reset));
initial begin
clk = 0;
reset = 1;
#20 reset = 0;
end
always begin
#10 clk = ~clk;
end
endmodule 
