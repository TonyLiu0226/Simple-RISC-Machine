module shifter(in,shift,sout);

//instantiates all the signals required
input [15:0] in;
input [1:0] shift;
output [15:0] sout;
reg [15:0] sout;

//always block to determine output based on the current value of shift
always @* begin
	case(shift)
		//output remains the same as input
		2'b00: sout = in;
		//output is a 1 bit left logical shift of input
		2'b01: sout = in<<1;
		//output is a 1 bit right logical shift of input
		2'b10: sout = in>>1;
		//output is a 1 bit right arithmetic shift of input
		2'b11: sout = $signed(in) >>> 1;
		//default case, if code is correct it should never reach this case
		default: sout = 16'bxxxxxxxxxxxxxxxx;

	endcase

end
endmodule
