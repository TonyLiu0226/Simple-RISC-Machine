module shifter_tb;
	reg [15:0] in;
	reg[1:0] shift;
	wire[15:0] out;
	reg err;
	
	//instantiates shifter module to be tested here
	shifter DUT(in, shift, out);

	initial begin
		//instantiates error to 0 by default
		err = 1'b0;

		//FIRST TEST CASE: TESTS THE VALUE 16'b1111000011001111
		//tests left shift, shift = 2'b01, expected result 16'b1111000011001111
		$display("TESTING LEFT SHIFT OPERATION");
		in = 16'b1111000011001111;
		shift = 2'b01;
		#5;
		if (out !== 16'b1110000110011110) begin
			$display("ERROR, output is %b, expected %b", out, 16'b1110000110011110);
			err = 1'b1;
		end
		#5
		
		//tests right logical shift, shift = 2'b10, expected result 16'b0111100001100111
		$display("TESTING RIGHT SHIFT OPERATION");
		in = 16'b1111000011001111;
		shift = 2'b10;
		#5;
		if (out !== 16'b0111100001100111) begin
			$display("ERROR, output is %b, expected %b", out, 16'b0111100001100111);
			err = 1'b1;
		end
		#5

		//tests right arithmetic shift, shift = 2'b11, expected result 16'b1111100001100111
		$display("TESTING RIGHT SHIFT OPERATION");
		in = 16'b1111000011001111;
		shift = 2'b11;
		#5;
		if (out !== 16'b1111100001100111) begin
			$display("ERROR, output is %b, expected %b", out, 16'b1111100001100111);
			err = 1'b1;
		end
		#5

		//ensures output is same as input if shift = 2'b00
		$display("TESTING BASE CASE OPERATION");
		in = 16'b1111000011001111;
		shift = 2'b00;
		#5;
		if (out !== 16'b1111000011001111) begin
			$display("ERROR, output is %b, expected %b", out, 16'b1111000011001111);
			err = 1'b1;
		end
		#5
		
		//NEXT TEST CASE: Tests the largest value that can be inputted, 16'b1111111111111111
		$display("REPEATING TESTING SEQUENCE FOR 16'b1111111111111111");
		//tests left shift, shift = 2'b01, expected result 16'b1111111111111110
		$display("TESTING LEFT SHIFT OPERATION");
		in = 16'b1111111111111111;
		shift = 2'b01;
		#5;
		if (out !== 16'b1111111111111110) begin
			$display("ERROR, output is %b, expected %b", out, 16'b1111111111111110);
			err = 1'b1;
		end
		#5
		
		//tests right logical shift, shift = 2'b10, expected result 16'b0111111111111111
		$display("TESTING RIGHT SHIFT OPERATION");
		in = 16'b1111111111111111;
		shift = 2'b10;
		#5;
		if (out !== 16'b0111111111111111) begin
			$display("ERROR, output is %b, expected %b", out, 16'b0111111111111111);
			err = 1'b1;
		end
		#5

		//tests right arithmetic shift, shift = 2'b11, expected result 16'b1111111111111111
		$display("TESTING RIGHT SHIFT OPERATION");
		in = 16'b1111111111111111;
		shift = 2'b11;
		#5;
		if (out !== 16'b1111111111111111) begin
			$display("ERROR, output is %b, expected %b", out, 16'b1111111111111111);
			err = 1'b1;
		end
		#5

		//ensures output is same as input if shift = 2'b00;
		$display("TESTING BASE CASE OPERATION");
		in = 16'b1111111111111111;
		shift = 2'b00;
		#5;
		if (out !== 16'b1111111111111111) begin
			$display("ERROR, output is %b, expected %b", out, 16'b1111111111111111);
			err = 1'b1;
		end
		#5

		//NEXT TEST CASE: Tests lowest value that can be inputted, which is 0
		$display("REPEATING TESTING SEQUENCE FOR 0");
		//tests left shift, expected result 0
		$display("TESTING LEFT SHIFT OPERATION");
		in = 16'd0;
		shift = 2'b01;
		#5;
		if (out !== 16'd0) begin
			$display("ERROR, output is %b, expected %b", out, 16'd0);
			err = 1'b1;
		end
		#5

		//tests right logical shift, expected result 0
		$display("TESTING RIGHT SHIFT OPERATION");
		in = 16'd0;
		shift = 2'b10;
		#5;
		if (out !== 16'd0) begin
			$display("ERROR, output is %b, expected %b", out, 16'd0);
			err = 1'b1;
		end
		#5

		//tests right arithmetic shift, expected result 0
		$display("TESTING RIGHT SHIFT OPERATION");
		in = 16'd0;
		shift = 2'b11;
		#5;
		if (out !== 16'd0) begin
			$display("ERROR, output is %b, expected %b", out, 16'd0);
			err = 1'b1;
		end
		#5

		//ensures that output is same as input if shift is 2'b00
		$display("TESTING BASE CASE OPERATION");
		in = 16'd0;
		shift = 2'b00;
		#5;
		if (out !== 16'd0) begin
			$display("ERROR, output is %b, expected %b", out, 16'd0);
			err = 1'b1;
		end
		#5

		//FINAL TEST CASE: Tests the decimal number 1
		$display("REPEATING TESTING SEQUENCE FOR 1");

		//tests left shift, expected result should be 2
		$display("TESTING LEFT SHIFT OPERATION");
		in = 16'b0000000000000001; 
		shift = 2'b01;
		#5;
		if (out !== 16'b0000000000000010) begin
			$display("ERROR, output is %b, expected %b", out, 16'b0000000000000010);
			err = 1'b1;
		end
		#5

		//tests logical right shift, expected result should be 0
		$display("TESTING RIGHT SHIFT OPERATION");
		in = 16'b0000000000000001;
		shift = 2'b10;
		#5;
		if (out !== 16'd0) begin
			$display("ERROR, output is %b, expected %b", out, 16'd0);
			err = 1'b1;
		end
		#5

		//tests arithmetic right shift. expected result should be 0
		$display("TESTING RIGHT SHIFT OPERATION");
		in = 16'b0000000000000001;
		shift = 2'b11;
		#5;
		if (out !== 16'd0) begin
			$display("ERROR, output is %b, expected %b", out, 16'd0);
			err = 1'b1;
		end
		#5

		//ensures output is same as input if shift is 2'b00
		$display("TESTING BASE CASE OPERATION");
		in = 16'b0000000000000001;
		shift = 2'b00;
		#5;
		if (out !== 16'b0000000000000001) begin
			$display("ERROR, output is %b, expected %b", out, 16'b0000000000000001);
			err = 1'b1;
		end
		#5

		if (~err) $display("PASSED");
		else $display("FAILED");
	
	end
endmodule

		
