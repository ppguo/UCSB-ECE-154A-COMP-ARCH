`timescale 1ns/100ps
module tb();
reg clk,reset;
wire memwrite;
wire [31:0] writedata,adr;
top top_1(.clk(clk),.reset(reset),.writedata(writedata),.adr(adr),.memwrite(memwrite));
initial begin
clk = 1;
reset = 1;
#20 reset = 0;
end
always begin
#10 clk = ~clk;
end
endmodule 
