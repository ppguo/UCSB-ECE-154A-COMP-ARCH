// Top level system including MIPS and memory

module top(input        clk, reset, 
           output [31:0] writedata, adr, 
           output        memwrite);

  wire [31:0] readdata;
  
  // microprocessor (control & datapath)
  mips mips(clk, reset, adr, writedata, memwrite, readdata);

  // memory 
  mem mem(clk, memwrite, adr, writedata, readdata);

endmodule
