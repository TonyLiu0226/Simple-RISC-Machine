 module datapath(clk,readnum,write,writenum, sximm8, sximm5, mdata, PC ,datapath_out,loada,loadb,shift,asel,bsel,ALUop,loadc,loads,vsel,Z_out,V_out,N_out);
  input clk,write, loada, loadb, asel, bsel, loadc, loads;
  input [1:0] vsel;
  input [15:0] sximm8, mdata, PC, sximm5;
  input [2:0] readnum, writenum;
  input [1:0] shift, ALUop;
  output Z_out,V_out,N_out;
  output [15:0] datapath_out;
  wire[15:0] data_in, data_out,in,sout,Ain,Bin,out,aout;
  wire N,V,Z;


  //instantiate the writeback multiplexer 
  writeBackMux wbm(mdata, sximm8, PC, datapath_out, data_in, vsel); 
  
  //Instantiates regfile
  regfile REGFILE(data_in, writenum, write, readnum, clk, data_out);

  //instantiates a vDFF for loadA (A register)
  vDFF1 #(16)loadA(clk, data_out, loada, aout);
  //instantiates a vDFF for loadB (B register)
  vDFF1 #(16)loadB(clk, data_out, loadb, in);

  //passes data stored in B to shifter
  shifter SHIFTER(in, shift, sout);
  //instantiate the multiplexer for Ain 
  assign Ain= asel ? 16'b0000000000000000: aout;
  //instantiate the multiplexer for Bin 
  assign Bin= bsel ? sximm5 : sout;
  
  //instantiate the ALU block
  ALU U2(Ain,Bin,ALUop,out,N,V,Z);
  //instantiate the Register C
  vDFF1 #(16) C(clk,out,loadc,datapath_out);
  //instantiate the Status Register to check if out is negative
  vDFF1 #(1) statusN(clk,N,loads,N_out);
  //instantiate the Status Register to check if out is overflow
  vDFF1 #(1) statusV(clk,V,loads,V_out);
  //instantiate the Status Register to check if out is 0
  vDFF1 #(1) statusZ(clk,Z,loads,Z_out);

endmodule

//4 input multiplexer
module writeBackMux (a,b,c,d,e,select);
  input [15:0] a, b, c, d;
  input [1:0] select;
  output [15:0] e;
  reg [15:0] e;
  //always block to instantiate writeback multiplexer  
 	always @* begin
		case (select)
			2'b00: e = a;
			2'b01: e = b;
			2'b10: e = c;
			2'b11: e = d;
			//should never get to this state, as all possible inputs of vsel are already covered above
			default: e = e;
		endcase
	end
endmodule
			
	
  
