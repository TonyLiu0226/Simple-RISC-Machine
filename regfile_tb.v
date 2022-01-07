
module regfile_tb;
	
	reg[15:0] data_in;
	reg[2:0] writenum, readnum;
	reg write, clk;
	wire[15:0] data_out;
	reg err;
       
//instantiates the top level module that will be tested in this testbench
       regfile DUT(data_in,writenum,write,readnum,clk,data_out);

//sets the clock to alternate between high and low every 5 ps
       initial begin
		clk = 1'b0; #5;
		forever begin
			clk = 1'b1; #5;
			clk = 1'b0; #5;
		end
	end

//main initial block, where all the tests will run
        initial begin
		//instantiates signal err
		err = 1'b0; 
		//Writes decimal value 8 to register R0, checks to ensure that data out is equal to 8 after the rising edge of the clock
		$display("NEXT CHECK: WRITE VALUE 8 TO R0 AND READ FROM IT");
		 
		data_in = 16'b0000000000001000;
		write = 1;
		writenum = 3'b000;
		readnum = 3'b000;
		#10;
		
		
		if (data_out !== 16'b0000000000001000) begin
			$display("ERROR WITH OUTPUT, EXPECTED %b BUT WAS %b", 16'b0000000000001000, data_out);
			err = 1'b1;
		end
		
		//changes data_in to 16, but write is 0. Ensures 16 is not written to R0 when write is 0, and the value in R0 is still 8.
		$display("NEXT CHECK: ENSURE NOTHING IS WRITTEN IF WRITE IS 0 AND READ FROM R0");  
		data_in = 16'b0000000000010000;
		write = 0;
		writenum = 3'b000;
		readnum = 3'b000;
		#10;
		
		
		if (data_out !== 16'b0000000000001000) begin
			$display("ERROR WITH OUTPUT, EXPECTED %b BUT WAS %b", 16'b0000000000001000, data_out);
			err = 1'b1;
		end
		
		//changes write to 1, and ensures 16 is written to R0, overwriting the existing value 8 that is already there
		$display("NEXT CHECK: WRITES 16 TO R0 AND READ FROM R0");
		
		data_in = 16'b0000000000010000;
		write = 1;
		writenum = 3'b000;
		readnum = 3'b000;
		#10;
		
		if (data_out !== 16'b0000000000010000) begin
			$display("ERROR WITH OUTPUT, EXPECTED %b BUT WAS %b", 16'b0000000000010000, data_out);
			err = 1'b1;
		end
		
		//writes the highest possible value, 16'b1111111111111111 to R7, and reads from it to ensure the value is written
		$display("NEXT CHECK: WRITES all 1's TO R7 AND READ FROM R7");
		 
		data_in = 16'b1111111111111111;
		write = 1;
		writenum = 3'b111;
		readnum = 3'b111;
		#10;
		
		//checks to ensure that data out is equal to 16'b1111111111111111 after the rising edge of the clock
		if (data_out !== 16'b1111111111111111) begin
			$display("ERROR WITH OUTPUT, EXPECTED %b BUT WAS %b", 16'b1111111111111111, data_out);
			err = 1'b1;
		end

		//writes the value 320 to R3, however does not read from R3, but read stays at R7. Ensures that output is still R7's value as long as we are reading from it
		$display("NEXT CHECK: WRITES the value 320 TO R3 BUT READ stays at R7");
		
		data_in = 16'd320;
		write = 1;
		writenum = 3'b011;
		readnum = 3'b111;
		#10;
		
		if (data_out !== 16'b1111111111111111) begin
			$display("ERROR WITH OUTPUT, EXPECTED %b BUT WAS %b", 16'b1111111111111111, data_out);
			err = 1'b1;
		end
		
		//writes the value 1659 to R2, changes read to R3, and ensures 320, which was written to R3 earlier is the output
		$display("NEXT CHECK: WRITES the value 1659 TO R2 AND reads the value at R3"); 
		data_in = 16'd1659;
		write = 1;
		writenum = 3'b010;
		readnum = 3'b111;
		#7;
		readnum = 3'b011;
		#3;
		//checks to ensure that data out is equal to 320 after the rising edge of the clock
		if (data_out !== 16'd320) begin
			$display("ERROR WITH OUTPUT, EXPECTED %b BUT WAS %b", 16'd320, data_out);
			err = 1'b1;
		end
		
		//simply reads the value at R2 without writing anything, output should be 1659
		$display("NEXT CHECK: DOES NOT WRITE ANYTHING, but reads the value at R2"); 
		data_in = 16'd9999;
		write = 0;
		writenum = 3'b001;
		readnum = 3'b011;
		//odd delay times checks to ensure read is updated independent of clk
		#9;
		readnum = 3'b010;
		#1;
		//checks to ensure that data out is equal to 1659 after the rising edge of the clock
		if (data_out !== 16'd1659) begin
			$display("ERROR WITH OUTPUT, EXPECTED %b BUT WAS %b", 16'd1659, data_out);
			err = 1'b1;
		end
		
		//Checks for read changes independent of clk. This instance checks to ensure that the value at r1 is xxxxxxxxxxxxxxxx, as nothing should be written there
		$display("CHECKS THAT READ VALUES ARE UPDATED INDEPENDENTLY OF CLK");
		
		#2;
		readnum = 3'b001;
		#1;

		if (data_out !== 16'bxxxxxxxxxxxxxxxx) begin
			$display("ERROR WITH OUTPUT, EXPECTED %b BUT WAS %b", 16'bxxxxxxxxxxxxxxxx, data_out);
			err = 1'b1;
		end

		//Checks R7, ensure output is still 16'b1111111111111111 as nothing should be written to R7 since last time we checked
		$display("FINAL READ OF R7");
		#0.01
		readnum = 3'b111;
		#0.99
		if (data_out !== 16'b1111111111111111) begin
			$display("ERROR WITH OUTPUT, EXPECTED %b BUT WAS %b", 16'b1111111111111111, data_out);
			err = 1'b1;
		end
			
		if (~err)
			$display("PASSED");
		else
			$display("FAILED");
		
	
	end
		
endmodule
