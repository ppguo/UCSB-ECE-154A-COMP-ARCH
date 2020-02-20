//-------------------------------------------------------
// Multicycle MIPS processor
//------------------------------------------------

module mips(input        clk, reset,
            output [31:0] adr, writedata,
            output        memwrite,
            input [31:0] readdata);

  wire        zero, pcen, irwrite, regwrite,
               alusrca, iord, memtoreg, regdst;
  wire [1:0]  alusrcb, pcsrc;
  wire [2:0]  alucontrol;
  wire [5:0]  op, funct;

  controller c(clk, reset, op, funct, zero,
               pcen, memwrite, irwrite, regwrite,
               alusrca, iord, memtoreg, regdst, 
               alusrcb, pcsrc, alucontrol);
  datapath dp(clk, reset, 
              pcen, irwrite, regwrite,
              alusrca, iord, memtoreg, regdst,
              alusrcb, pcsrc, alucontrol,
              op, funct, zero,
              adr, writedata, readdata);
endmodule

// Todo: Implement controller module
module controller(input       clk, reset,
                  input [5:0] op, funct,
                  input       zero,
                  output       pcen, memwrite, irwrite, regwrite,
                  output       alusrca, iord, memtoreg, regdst,
                  output [1:0] alusrcb, pcsrc,
                  output [2:0] alucontrol);

// **PUT YOUR CODE HERE**
wire [1:0] aluop;
MainDecoder md(  clk,reset,
		op[5:0],
		zero,
		pcen,memwrite,irwrite,regwrite,
		alusrca,iord,memtoreg,regdst,
		alusrcb[1:0],pcsrc[1:0],
		aluop[1:0]);
ALUDecoder ad(aluop[1:0],funct[5:0],alucontrol[2:0]); 
endmodule

module MainDecoder(input clk,reset,
		     input  [5:0] op,
	 	     input zero,
		     output pcen,
		     output   reg memwrite, irwrite, regwrite,
                  	     output   reg    alusrca, iord, memtoreg, regdst,
                  	     output reg [1:0] alusrcb, pcsrc,
		     output reg [1:0] aluop);
reg branch,pcwrite,up;
reg [15:0] controlword;
reg [3:0] state;
assign pcen = (branch & zero) + pcwrite;
always @ (*) begin
if  (reset ==  1) begin
	controlword <= 16'h5010;
	{up,pcwrite,memwrite,irwrite,regwrite,alusrca,branch,iord,memtoreg,regdst,alusrcb,pcsrc,aluop} <= 16'h5010;
	state <= 0;
end
end
always @ (posedge clk) begin
case (state)  
4'b0000:begin
	controlword <= 16'h0030;
	{up,pcwrite,memwrite,irwrite,regwrite,alusrca,branch,iord,memtoreg,regdst,alusrcb,pcsrc,aluop} <= 16'h0030;
	state <= 4'b0001;
    end
4'b0001:begin
	case (op)	
	//r-type
	6'b000000:begin
		controlword <= 16'h0402;
		{up,pcwrite,memwrite,irwrite,regwrite,alusrca,branch,iord,memtoreg,regdst,alusrcb,pcsrc,aluop} <= 16'h0402;	
		state <= 4'b0110;
		  end
	//beq
	6'b000100:begin
		controlword <= 16'h0605;
		{up,pcwrite,memwrite,irwrite,regwrite,alusrca,branch,iord,memtoreg,regdst,alusrcb,pcsrc,aluop} <= 16'h0605;	
		state <= 4'b1000;
		end
	//addi
	6'b001000:begin
		controlword <= 16'h0420;
		{up,pcwrite,memwrite,irwrite,regwrite,alusrca,branch,iord,memtoreg,regdst,alusrcb,pcsrc,aluop} <= 16'h0420;	
		state <= 4'b1001;
		end
	//j
	6'b000010:begin
		controlword <= 16'h4008;
		{up,pcwrite,memwrite,irwrite,regwrite,alusrca,branch,iord,memtoreg,regdst,alusrcb,pcsrc,aluop} <= 16'h4008;	
		state <= 4'b1011;
		end
	//lw or sw
	default:begin
		controlword <= 16'h0420;
		{up,pcwrite,memwrite,irwrite,regwrite,alusrca,branch,iord,memtoreg,regdst,alusrcb,pcsrc,aluop} <= 16'h0420;	
		state <= 4'b0010;
	             end
	endcase
  end
4'b0010:begin
	if (op == 6'b100011)begin
		controlword <= 16'h0100;
		{up,pcwrite,memwrite,irwrite,regwrite,alusrca,branch,iord,memtoreg,regdst,alusrcb,pcsrc,aluop} <= 16'h0100;	
		state <= 4'b0011;
	             end	
	else begin
		controlword <= 16'h2100;
		{up,pcwrite,memwrite,irwrite,regwrite,alusrca,branch,iord,memtoreg,regdst,alusrcb,pcsrc,aluop} <= 16'h2100;	
		state <= 4'b0101;
	             end
  end
4'b0011:begin
	controlword <= 16'h0880;
	{up,pcwrite,memwrite,irwrite,regwrite,alusrca,branch,iord,memtoreg,regdst,alusrcb,pcsrc,aluop} <= 16'h0880;	
	state <=4'b0100;
   end
4'b0110:begin
	controlword <= 16'h0840;
	{up,pcwrite,memwrite,irwrite,regwrite,alusrca,branch,iord,memtoreg,regdst,alusrcb,pcsrc,aluop} <= 16'h0840;
	state <= 4'b0111;
end	
4'b1001:begin
	controlword <= 16'h0800;
	{up,pcwrite,memwrite,irwrite,regwrite,alusrca,branch,iord,memtoreg,regdst,alusrcb,pcsrc,aluop} <= 16'h0800;
	state <= 4'b1010;
end
default:begin
	controlword <= 16'h5010;
	{up,pcwrite,memwrite,irwrite,regwrite,alusrca,branch,iord,memtoreg,regdst,alusrcb,pcsrc,aluop} <= 16'h5010;
	state <= 4'b0000;
end
endcase
end
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
module datapath(input        clk, reset,
                input        pcen, irwrite, regwrite,
                input        alusrca, iord, memtoreg, regdst,
                input [1:0]  alusrcb, pcsrc, 
                input [2:0]  alucontrol,
                output [5:0]  op, funct,
                output        zero,
                output [31:0] adr, writedata, 
                input [31:0] readdata);

// **PUT YOUR CODE HERE** 
wire [31:0] instr,WD3,RD1,RD2,mux3out,
	pcout,data,aout,bout,aluout,aluresult,
	immext,SrcA,SrcB;
wire [4:0] A3;
assign op = instr[31:26];
assign funct = instr[5:0];
ALU ALU(SrcA[31:0],SrcB[31:0],alucontrol[2:0],aluresult[31:0],zero);

registerfile rgf(clk,instr[25:21],instr[20:16],
	    A3[4:0],
	    WD3[31:0],
	    regwrite,
	    RD1[31:0],RD2[31:0]);

pc_reg pcreg (reset,clk,pcen,
	       mux3out [31:0],
	       pcout [31:0]);

instr_reg instrreg (reset,clk,irwrite,
		readdata[31:0],
		instr[31:0]);

Data_reg datareg(reset,clk,
	              readdata[31:0],
	              data[31:0]);

AB_reg abreg(reset,clk,
	        RD1[31:0],RD2[31:0],
	        aout[31:0],writedata[31:0]);


ALUOUT ALUOUT (reset,clk,
		aluresult [31:0],
		aluout[31:0]);

signextend signextend(instr[15:0],
		      immext [31:0]);

pc_mux pcmux(pcout[31:0],aluout[31:0],iord,
		adr[31:0]);


A3_mux a3mux(instr[20:16],instr[15:11],
		regdst,
		A3[4:0]);

SrcA_mux srcamux(pcout[31:0],aout[31:0],
	alusrca,
	SrcA[31:0]);

WD3_mux wd3mux(aluout[31:0],data[31:0],
		memtoreg,
		WD3[31:0]);

SrcB_mux srcbmux(writedata[31:0],immext[31:0],
		alusrcb[1:0],
		SrcB[31:0]);

pc3_mux pc3mux (aluresult[31:0],aluout[31:0],
		pcout[3:0],instr[25:0],pcsrc[1:0],mux3out[31:0]);

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
always @ (*)  begin
RD1 <= regfile [A1];
RD2 <= regfile [A2];
end

always @ (posedge clk) begin
 if  (WE3 == 1'b1)
	regfile[A3] <= WD3;
end

endmodule

module pc_reg (input reset,clk,pcen,
	         input[31:0] pcin,
	         output reg[31:0] pc);
always @ (posedge clk) begin
if (pcen == 1) pc <= pcin;
end
always @ (*) begin
if (reset == 1) pc = 32'h00000000;
end
endmodule


module instr_reg (input reset,clk,irwrite,
	              input [31:0] instr_in,
	              output reg[31:0] instr_out);
always @ (posedge clk) begin
if (irwrite == 1) instr_out <= instr_in;
end
always @ (*) begin
if (reset == 1) instr_out = 32'h00000000;
end
endmodule

module  Data_reg(  input reset,clk,
	 	input [31:0] data_in,
		output reg [31:0] data_out);
always @ (posedge clk) begin
data_out <= data_in;
end
always @ (*)  begin
if (reset == 1) data_out = 32'h00000000;
end
endmodule



module AB_reg (     input reset,clk,
		input [31:0] A_in,B_in,
		output reg [31:0] A_out,B_out);
always @ (posedge clk) begin
A_out <= A_in;
B_out <= B_in;
end
always @ (*)  begin
if (reset == 1) begin
A_out = 32'h00000000;
B_out = 32'h00000000;
end
end
endmodule

module ALUOUT(   input reset,clk,
		input [31:0] aluin,
		output reg [31:0] aluout);
always @ (posedge clk) begin
aluout <= aluin;
end

always @ (*)  begin
if (reset == 1) aluout = 32'h00000000;
end

endmodule

module signextend(input [15:0] instr,
		output reg [31:0] immext);
always @ (*) begin
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
endmodule


module pc_mux(input [31:0] a,b,
	       input sel,
	       output reg [31:0] c);
always @ (*)  begin
 c <= (sel == 0) ? a :b;
end
endmodule

module A3_mux(input [4:0] a,b,
	       input sel,
	       output reg [4:0] c);
always @ (*) begin
 c <= (sel == 0) ? a :b;
end
endmodule

module WD3_mux(input [31:0] a,b,
	       input sel,
	       output reg [31:0] c);
always @ (*)  begin
 c <= (sel == 0) ? a :b;
end
endmodule



module SrcA_mux(input [31:0] a,b,
	       input sel,
	       output reg [31:0] srca);
always @ (*)  begin
 srca <= (sel == 0) ? a :b;
end
endmodule



module SrcB_mux(input [31:0] a0,a2,
	       input[1:0] sel,
	       output reg [31:0] srcb);
always @ (*)  begin
case (sel) 
2'b00:srcb <= a0;
2'b01:srcb<= 32'h00000004;
2'b10:srcb <= a2;
2'b11:srcb <= a2 << 2;
endcase
end
endmodule

module pc3_mux (  input [31:0] a0,a1,
	   	input [3:0] pcpart,
		input [25:0] jump,
		input [1:0] sel,
		output reg [31:0] pc3);
always @ (*)  begin
case(sel) 
2'b00:pc3 <= a0;
2'b01:pc3 <= a1;
2'b10:pc3 <= {pcpart,jump,2'b00};
endcase
end
endmodule





