module alu(input [31:0] a, b,            
                    input [2:0]  f,            
                    output [31:0] y,            
                     output  zero);
                    
             reg[31:0] c,d;

            always @ (*)
            begin
            //invert input B when F2 is asserted
            c = (f[2] == 1) ? (~b) : b ;
            d = a + c + f[2];  //d is for SLT
            //choose different function according to f[1:0]
            case ( f[1:0] )
            3'b00: y = a & c;
            3'b01: y = a | c;
            3'b10: y = a + c + f[2]; //subtract
            3'b11: begin
                                  
                                  y[0] = (d[31] == 1'b1);
                                  y[31:1] = 31'h0;
                                  
                         end          //SLT
            default: y=0;
            endcase

           zero = (y == 0) ?  1  : 0 ;

           end

endmodule



