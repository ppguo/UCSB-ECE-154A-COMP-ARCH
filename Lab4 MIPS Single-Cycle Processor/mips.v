// single-cycle MIPS processor
// instantiates a controller and a datapath module

module mips(input          clk, reset,
            output [31:0] pc,
            input   [31:0] instr,
            output  memwrite,
            output [31:0] aluout, writedata,
            input   [31:0] readdata);

  wire        memtoreg, branch,
               pcsrc, zero,
               alusrc, regdst, regwrite, jump;
  wire [2:0]  alucontrol;



 controller c(instr[31:26], instr[5:0], zero,
               memtoreg, memwrite, pcsrc,
               alusrc, regdst, regwrite, jump,
               alucontrol);
  datapath dp(clk, reset, memtoreg, pcsrc,
              alusrc, regdst, regwrite, jump,
              alucontrol,
              zero, pc, instr,
              aluout, writedata, readdata);

endmodule


// Todo: Implement controller module
module controller(input   [5:0] op, funct,
                  input         zero,
                  output        memtoreg, memwrite,
                  output        pcsrc, alusrc,
                  output        regdst, regwrite,
                  output        jump,
                  output  [2:0] alucontrol);

// **PUT YOUR CODE HERE**
 wire [1:0] aluop;
 //divide decoder to two parts and use aluop to connect them
 MainDecoder md(op[5:0],zero,aluop[1:0],
	              memtoreg,memwrite,pcsrc,
	               regdst,regwrite,alusrc,jump);
 ALUDecoder ad(aluop[1:0],funct[5:0],alucontrol[2:0]); 
endmodule

module MainDecoder(input  [5:0] op,
	 	     input zero,
		     output reg [1:0] aluop,
		     output reg memtoreg,memwrite,
		     output pcsrc,
		     output reg regdst,
	                     output reg regwrite,alusrc,
		     output reg jump);
 reg branch,branchne; //branchne is 1 when bne
 always @* begin
	case(op[5:0])
	 6'b000000 : begin
		regwrite <= 1;
		regdst <= 1;
		alusrc   <= 0;
		branch <= 0;
		memwrite <= 0;
		memtoreg <= 0;
		aluop <= 2'b10;
		jump <= 0;
		branchne <= 0;
		end
	6'b100011:begin
		regwrite <= 1;
		regdst <= 0;
		alusrc   <= 1;
		branch <= 0;
		memwrite <= 0;
		memtoreg <= 1;
		aluop <= 2'b00;
		jump <= 0;
		branchne <= 0;
		end
	6'b101011:begin
		regwrite <= 0;
		regdst <= 1'bx;
		alusrc   <= 1;
		branch <= 0;
		memwrite <= 1;
		memtoreg <= 1'bx;
		aluop <= 2'b00;
		jump <= 0;
		branchne <= 0;
		end
	6'b000100:begin
		regwrite <= 0;
		regdst <= 1'bx;
		alusrc   <= 0;
		branch <= 1;
		memwrite <= 0;
		memtoreg <= 1'bx;
		aluop <= 2'b01;
		jump <= 0;
		branchne <= 0;
		end
	6'b001000:begin
		regwrite <= 1;
		regdst <= 0;
		alusrc   <= 1;
		branch <= 0;
		memwrite <= 0;
		memtoreg <= 0;
		aluop <= 2'b00;
		jump <= 0;
		branchne <= 0;
		end
	6'b000010:begin
		regwrite <= 0;
		regdst <= 1'bx;
		alusrc   <= 1'bx;
		branch <= 1'bx;
		memwrite <= 0;
		memtoreg <= 1'bx;
		aluop <= 2'bxx;
		jump <= 1;
		branchne <= 1'bx;
		end
	6'b001101:begin
		regwrite <= 1;
		regdst <= 0;
		alusrc   <= 1;
		branch <= 0;
		memwrite <= 0;
		memtoreg <= 0;
		aluop <= 2'b11;
		jump <= 0;
		branchne <= 0;
		end
	6'b000101:begin
		regwrite <= 0;
		regdst <= 1'bx;
		alusrc   <= 0;
		branch <= 1;
		memwrite <= 0;
		memtoreg <= 1'bx;
		aluop <= 2'b01;
		jump <= 0;
		branchne <= 1;
		end	
	endcase
	end
 assign pcsrc = (branch & zero) | (branchne & (~zero));
endmodule

module 	ALUDecoder(input [1:0] aluop,
		     input [5:0] funct,
		     output reg[2:0] alucontrol);
	always @* begin
	case (aluop[1:0])
	2'b00:alucontrol <= 3'b010;
	2'b01:alucontrol <= 3'b110;
	2'b10:begin
		case (funct[5:0])
		6'b100000 : alucontrol <= 3'b010;
		6'b100010 : alucontrol <= 3'b110;
		6'b100100 : alucontrol <= 3'b000;
		6'b100101 : alucontrol <= 3'b001;
		6'b101010 : alucontrol <= 3'b111;
		default : alucontrol <= 3'b000;
		endcase
	          end
	2'b11:alucontrol <= 3'b001;   // now we give 11 meaning for ori
	endcase
	end
endmodule		
// Todo: Implement datapath
module datapath(input          clk, reset,
                input          memtoreg, pcsrc,
                input          alusrc, regdst,
                input          regwrite, jump,
                input   [2:0]  alucontrol,
                output         zero,
                output [31:0] pc,
                input   [31:0] instr,
                output  [31:0] aluout, writedata,
                input   [31:0] readdata);

// all the modules and their connection according to the figure, for convenience we label each part on the figure.
wire [31:0] immext,srcA,srcB,wd3,pcplus,pcoutb,mux1out,mux2out,pcins;                
wire [4:0] a3;
ALU alu(srcA,srcB,alucontrol[2:0],aluout,zero);
mux5 mux5(aluout,readdata,memtoreg,wd3);              
extend se(instr[31:26],instr[15:0],immext[31:0]);
registerfile refile(clk,instr [25:21],instr [20:16],a3,wd3,regwrite,srcA,writedata);
pcbranch pcb(immext,pcplus,pcoutb);
pcplus4 pcp4(pc,pcplus);
mux1 mux1(pcplus,pcoutb,pcsrc,mux1out);
mux2 mux2 (mux1out,pcplus[31:28],instr[25:0],jump,mux2out);
mux3 mux3(instr[20:16],instr[15:11],regdst,a3);
mux4 mux4(writedata,immext,alusrc,srcB);
pcinstr pci(reset,mux2out,clk,pc);

endmodule
//this is the extend part
module extend(input [5:0] op,
		input [15:0] instr,
		output reg [31:0] immext);
always @* begin
if (op == 6'b001101) begin
		immext[31:16] <= 16'h0000;
		immext[15:0] <= instr;
		end    // for ori we just need to zero extend
else  begin  
         case (instr[15])
	1'b1:begin
		immext[31:16] <= 16'hFFFF;
		immext[15:0] <= instr;
	         end
	1'b0:begin
		immext[31:16] <= 16'h0000;
		immext[15:0] <= instr;
	        end
	endcase
	end 
end

endmodule


module registerfile(input clk,
		input [4:0] A1,A2,A3,
		input [31:0] WD3,
		input WE3,
		output reg[31:0]  RD1,RD2);
reg [31:0] regfile [31:0];
initial begin
regfile[0] = 0;
end
always @ * begin
RD1 <= regfile [A1];
RD2 <= regfile [A2];
end

always @ (posedge clk) begin
 if  (WE3 == 1'b1)
	regfile[A3] <= WD3;
end

endmodule

module pcinstr(input reset,
                          input [31:0] pcin,
	          input clk,
	          output reg [31:0] pcout);
always @(posedge clk) begin
pcout <= pcin;
//end
//always @* begin
if (reset == 1'b1) begin
	pcout <= 32'h00000000;

end
end
endmodule

module pcbranch(  input [31:0] immext,pcin,
	  	output [31:0] branchout);
assign branchout = (immext << 2) + pcin;
endmodule

module pcplus4(input [31:0] pctoplus,
	           output [31:0] pcplus);
assign pcplus = pctoplus + 4;
endmodule

module mux1(input [31:0] a,b,
	       input sel,
	       output reg [31:0] c);
always @* begin
 c <= (sel == 0) ? a :b;
end
endmodule


module mux2(input [31:0] a,
	        input [3:0] b0,
	       input [25:0] b1,
	       input sel,
	       output reg [31:0] c);
wire [31:0] b;
assign b[27:0] = b1  << 2;
assign b[31:28] = b0;
always @* begin
 c <= (sel == 0) ? a :b;
end
endmodule


module mux3(input [4:0] a,b,
	       input sel,
	       output reg [4:0] c);
always @* begin
 c <= (sel == 0) ? a :b;
end
endmodule


module mux4(input [31:0] a,b,
	       input sel,
	       output reg [31:0] c);
always @* begin
 c <= (sel == 0) ? a :b;
end
endmodule


module mux5(input [31:0] a,b,
	       input sel,
	       output reg [31:0] c);
always @* begin
 c <= (sel == 0) ? a :b;
end
endmodule



	