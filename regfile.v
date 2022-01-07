module regfile(data_in,writenum,write,readnum,clk,data_out);

	input [15:0] data_in;
	input [2:0] writenum, readnum;
	input write, clk;
	output [15:0] data_out;
	reg [15:0] data_out;
	wire [7:0] writeValue;
	wire R0_in, R1_in, R2_in, R3_in, R4_in, R5_in, R6_in, R7_in;
	wire [15:0] R0;
	wire [15:0] R1;
	wire [15:0] R2;
	wire [15:0] R3;
	wire [15:0] R4;
	wire [15:0] R5;
	wire [15:0] R6;
	wire [15:0] R7;
	wire [7:0] select;

	//instantiates decoder for writenum
	Dec dec38(writenum, writeValue);
	
	//assigns Rn_in, indicator to indicate which register to write to as bit n of writeValue ANDED to write
	assign R0_in = writeValue[0] & write;
	assign R1_in = writeValue[1] & write;
	assign R2_in = writeValue[2] & write;
	assign R3_in = writeValue[3] & write;
	assign R4_in = writeValue[4] & write;
	assign R5_in = writeValue[5] & write;
	assign R6_in = writeValue[6] & write;
	assign R7_in = writeValue[7] & write;
	
	//instantiates 8 load enable DFF's, one for each register
	vDFF1 R0_dff(clk, data_in, R0_in, R0); 
	vDFF1 R1_dff(clk, data_in, R1_in, R1);
	vDFF1 R2_dff(clk, data_in, R2_in, R2);
	vDFF1 R3_dff(clk, data_in, R3_in, R3);
	vDFF1 R4_dff(clk, data_in, R4_in, R4);
	vDFF1 R5_dff(clk, data_in, R5_in, R5);
	vDFF1 R6_dff(clk, data_in, R6_in, R6);
	vDFF1 R7_dff(clk, data_in, R7_in, R7);

	//a multiplexer to select which register to read value from. Does not depend on clk

	//decoder for write signal (3 bit to 8 bit)
	Dec dec38read(readnum, select);

	always @* begin
		case (select)
			8'b00000001: data_out = R0;
			8'b00000010: data_out = R1;
			8'b00000100: data_out = R2;
			8'b00001000: data_out = R3;
			8'b00010000: data_out = R4;
			8'b00100000: data_out = R5;
			8'b01000000: data_out = R6;
			8'b10000000: data_out = R7;
			default: data_out = 16'bxxxxxxxxxxxxxxxx;
		endcase
	end
	
endmodule

//decoder modules used for all decoder components of the reg file
module Dec(a, b);
	parameter n = 3;
	parameter m = 8;

	input[n-1:0] a;
	output[m-1:0] b;

	assign b = 1<<a;
endmodule

//DFF with load enable used for writing data to the registers on the positive edge of the clock. RNin represents the load.
module vDFF1(clk, in, RNin, out);
	parameter n = 16;
	input clk;
	input [n-1:0] in;
	input RNin;
	output [n-1:0] out;
	reg [n-1:0] out;
	
//on the positive edge of the clock, writes data_in to output if RN_in (signal to indicate which register to write to) is true
	always @(posedge clk)
		if (RNin == 1'b1)
			out = in;
                else out=out;
	
endmodule
	
	