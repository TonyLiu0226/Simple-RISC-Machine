module ALU(Ain,Bin,ALUop,out,N,V,Z);
input [15:0] Ain, Bin;
input [1:0] ALUop;
output [15:0] out;
output N,V,Z;
wire c1,c2;
reg [15:0] out; //out is always updated.
reg V;

assign Z = (out==16'd0) ? 1:0; //If out is 0,Z=1;otherwise, Z=0.
assign N =  (out[15]==1'b1) ? 1:0; // If out is negative, N=1; otherwise, N=0.
always @* begin
    V=1'b0;
   
  case(ALUop)
    2'b00: out= Ain+Bin; //when an input on ALUOP is 2'b00 out is the sum of Ain and Bin.
    2'b01: out= Ain-Bin; //when an input on ALUOP is 2'b01 out is  Ain minus Bin.
    2'b10: out= Ain&Bin; //when an input on ALUOP is 2'b10 out is  Ain and Bin.
    2'b11: out= ~Bin;   //when an input on ALUOP is 2'b11 out is  negation of Bin.
   default:out={16{1'bx}};
   endcase

   // When operation is addition and substraction, we consider overflow.
   if(ALUop==2'b01) begin
     
       if(Ain[15]== ~Bin[15] & out[7]!==Ain[7]) begin
             V=1'b1;
          end // For substraction it can be considered as Ain + (-Bin)

   end
end



endmodule
