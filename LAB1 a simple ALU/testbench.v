`timescale 1ns/100ps
module read_test(); 
	
	//make memory array large enough to hold all the values from the input file (104 values), 
	//with each location large enough to hold the largest value (32 bits)
	reg [31:0] data [0:214];   //105 memory words (lines), 32 bits wide
	reg [2:0] f;
	reg [31:0] a,b;
                wire [31:0] y;
	wire zero;
                reg [31:0] y1;    //read the standard output y from alu.tv
                reg zero1;     //read the standard output zero from alu.tv
                reg state;   // show whether the output is correct
	integer i;
                
                alu alu_1( .a(a), .b(b), .f(f) ,.y(y),.zero(zero));
                //read vector and store in data
	initial $readmemh("C:/Users/ppguo/Desktop/pj for alu/alu.tv", data);
        
	initial begin
        	for (i=0; i < 214; i=i+5) begin
                                                
			f = data[i];
			a = data[i+1];
			b = data[i+2];
                                            y1 = data[i+3];
                                            zero1 = data[i+4];
                                                           
                                 #20;
		end
	end     
                 
                always @(*)
                 if (y1 == y && zero1 == zero )  state = 1;
                                                  else state = 0;              //check whether the output is correct, state=1 shows right
endmodule 

