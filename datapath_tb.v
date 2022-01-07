module datapath_tb;
  reg clk,err;
  reg [15:0] sximm8, sximm5, mdata, PC;
  reg [2:0] readnum, writenum;
  reg [1:0] shift, ALUop, vsel;
  reg write, loada, loadb, asel, bsel, loadc, loads;
  
  wire Z_out, V_out, N_out;
  wire [15:0] datapath_out;
  wire [15:0] R3 = DUT.REGFILE.R3;
  //named association for port connections
  datapath DUT(.clk(clk), .sximm8(sximm8), .sximm5(sximm5), .mdata(mdata), .PC(PC), .datapath_out(datapath_out), .readnum(readnum), .writenum(writenum),
               .write(write),.vsel(vsel),.asel(asel),.bsel(bsel), .loada(loada), .loadb(loadb), .loadc(loadc)
               , .loads(loads), .shift(shift), .ALUop(ALUop), .Z_out(Z_out), .V_out(V_out), .N_out(N_out));

//sets the clk, alternates between high and low every 5 time units
  initial forever begin
    clk = 0; #5;
    clk = 1; #5;
  end

  initial begin
    err=1'b0;
    sximm8 = 16'b0;
    mdata = 16'b0;
    sximm5 = 16'b0;
    PC = 16'b0;
    readnum = 3'b000; writenum=3'b000;
    shift = 2'b00; ALUop=2'b00;
    write = 1'b0; vsel=2'b01; loada=1'b0; loadb=1'b0; asel=1'b0; bsel=1'b0; loadc=1'b0; loads=1'b0;
    #10;

    $display("PERFORMING TEST ON FOLLOWING OPERATION: MOV R0, #7 MOV R1, #2 ADD R2, R1, RO LSL#1");
	
//THE BELOW LINES WILL TEST THE FOLLOWING ASSEMBLY CODE: MOV R0, #7 MOV R1, #2 ADD R2, R1, R0 LSL#1. We should get the datapath output to be 16
	//first cycle: load 7 to R0 and read from it
   	sximm8 = 16'd7;
	write = 1'b1;
	
	#10;
	
	//second cycle: write 2 to R1 and read from it, while loading the value at R0 to register B AND performs shift operation on it
	sximm8 = 16'd2;
	writenum = 3'b001;
	#10;

	//now read from R0 and load it into B, and shift it left 1 bit
	write = 1'b0;
	loadb = 1'b1;
	shift = 2'b01;
	#10;

	//fourth cycle: load R1 to register A and performs ALU operations on A and B
	readnum = 3'b001;
	loadb = 1'b0;
	loada = 1'b1;
	#10;

	//fifth cycle: Loads the results to C and checks datapath out is equal to 16 and z is equal to 1, n equal to 0 and v equal to 0
	loadc = 1'b1;
        loada=1'b0;
	loads = 1'b1;
	#10;

	if (datapath_out !== 16'd16) begin
		$display("ERROR IN DATAPATH OUTPUT, WAS %b BUT EXPECTED %b", datapath_out, 16'd16);
		err = 1'b1;
	end

	if (Z_out !== 1'b0) begin
		$display("ERROR IN Z OUTPUT, WAS %b BUT EXPECTED %b", Z_out, 1'b0);
		err = 1'b1;
	end

	if (N_out !== 1'b0) begin
		$display("ERROR IN N OUT, WAS %b BUT EXPECTED %b", N_out, 1'b0);
		err = 1'b1;
	end

	if (V_out !== 1'b0) begin
		$display("ERROR IN V OUT, WAS %b BUT EXPECTED %b", V_out, 1'b0);
		err = 1'b1;
	end

	//THE LAST 3 CYCLES ALSO TEST ADD R2 #0, TO ENSURE WE STILL GET R2'S VALUE OF 16 AT THE END
	//sixth cycle: store datapath out to R2
	loadc = 1'b0;
	loads = 1'b0;
	write = 1'b1;
	vsel = 2'b11;
	writenum = 3'b010;
	readnum = 3'b010;
	#10;
	
	//seventh cycle: Loads R2 to B, and changes shift to 00 to indicate we want the same value of R2. asel is 1 to indicate we want to add 0 to the value
	//ALUop remains the adding operation
	write = 1'b0;
	loada = 1'b0;
	loadb = 1'b1;
	shift = 2'b00;
	asel = 1'b1;
	#10;

	//eighth cycle: Loads R2 to C, ensures datapath output is still 16
	loadb = 1'b0;
	loadc = 1'b1;
	#10;
	
	if (datapath_out !== 16'd16) begin
		$display("R2 NOT PROPERLY SET, WAS %b BUT SHOULD HAVE BEEN %b", datapath_out, 16'd16);
		err = 1'b1;
	end
	
	#10;
	asel = 1'b0;
	loadc = 1'b0;
	vsel = 2'b01;
	//TEST CASE 2: THE BELOW LINES WILL TEST AN EXAMPLE OF AN ARITHMETIC SHIFT AND BITWISE AND OPERATION. We should get 0 in the end for output, and hence a status output of 1.
	$display("PERFORMING TEST ON BITWISE AND AND ARITHMETIC SHIFT COMBINATION");

	//cycle 1: write 0001111000011110 to R3
	sximm8 = 16'b0001111000011110;
	write = 1'b1;
	writenum = 3'b011;
	#10;
	
	//cycle 2: write 1111000011110000 to R4
	sximm8 = 16'b1111000011110000;
	writenum = 3'b100;
	#10;

	//cycle 3: read from R3 and store data into register B
	readnum = 3'b011;
	write = 1'b0;
	loadb = 1'b1;
	shift = 2'b11; //arithmetic right shift of 0001111000011110
	#10;

	//cycle 4: Reads R4 into A and performs ALU AND operation on A and B
	readnum = 3'b100;
	loadb = 1'b0;
	loada = 1'b1;
	ALUop = 2'b10;
	#10;

	//cycle 5: Loads the output to C which stores it into datapath_out, checks to ensure it is equal to 0
	//also checks Z_out to ensure it is equal to 1, N out and V out should be equal to 0
	loada = 1'b0;
	loadc = 1'b1;
	loads = 1'b1;
	#10;

	if (datapath_out !== 16'd0) begin
		$display("ERROR IN DATAPATH OUTPUT, WAS %b BUT EXPECTED %b", datapath_out, 16'd0);
		err = 1'b1;
	end
	
	//since the output is 0, z should be 1
	if (Z_out !== 1'b1) begin
		$display("ERROR IN Z OUTPUT, WAS %b BUT EXPECTED %b", Z_out, 1'b1);
		err = 1'b1;
	end

	if (N_out !== 1'b0) begin
		$display("ERROR IN N OUT, WAS %b BUT EXPECTED %b", N_out, 1'b0);
		err = 1'b1;
	end

	if (V_out !== 1'b0) begin
		$display("ERROR IN V OUT, WAS %b BUT EXPECTED %b", V_out, 1'b0);
		err = 1'b1;
	end

	//cycle 6: stores the datapath_out to R2 (overwriting it)
	loadc = 1'b0;
	loads = 1'b0;
	write = 1'b1;
	vsel = 2'b11;
	writenum = 3'b010;
	readnum = 3'b010;
	#10;

	//cycle 7: loads the value of R2 to B. Changes asel to 1, ALUop to adding, and shift to 0
	//this will ensure we add 0 to R2 to eventually just output the value of R2 in datapath_out
	write = 1'b0;
	loada = 1'b0;
	loadb = 1'b1;
	shift = 2'b00;
	ALUop = 2'b00;
	asel = 1'b1;
	#10;

	//cycle 8: loads the value of R2 to C, then outputs to datapath_out. Ensures it is equal to 0
	loadb = 1'b0;
	loadc = 1'b1;
	#10;
	
	if (datapath_out !== 16'd0) begin
		$display("R2 NOT PROPERLY SET, WAS %b BUT SHOULD HAVE BEEN %b", datapath_out, 16'd0);
		err = 1'b1;
	end

	loadc = 1'b0;
	vsel = 2'b01;
	asel = 1'b0;
	
	#10;
//CHECKS SUBTRACTION. ENSURES OUTPUT IN THE END IS 17 - 5 = 12
$display("Check '-' operation");
    // MOV R1, #17
    sximm8 = 16'h17; 
    writenum = 3'd1;
    write = 1'b1;
    vsel = 2'b01;
    #10;
    
     // MOV R2, #5
    sximm8 = 16'h5; 
    writenum = 3'd2;
    write = 1'b1;
    vsel = 2'b01;
    #10;

    write = 1'b0;
    //write is done so set write to 0

    // SUB,R3,R1,R2
    // step 1 - load the value of R1 into A register
    readnum = 3'd1; 
    loada = 1'b1;
    #10; 
    loada = 1'b0; // after loading A, set loada to zero.

    // step 2 - load the value of R2 into B register
    readnum = 3'd2; 
    loadb = 1'b1;
    #10; 
    loadb = 1'b0; // after loading B, set loadb to zero.

    // step 3 - perform operation of A - B , load into C
    shift = 2'b00;
    asel = 1'b0;
    bsel = 1'b0;
    ALUop = 2'b01;
    loadc = 1'b1;
    loads = 1'b1;
    #10; 
    loadc = 1'b0;
    loads = 1'b0;

    
    // step 4 - store C into R3
    write = 1'b1;
    writenum = 3'd3;
    vsel = 2'b11;
    #10;
    write = 0;
//STEP 5: Checks if register and datapath values are correct (16'h12). Also checks Z, N, V all equal 0.
    if (R3 !== 16'h12) begin 
      err = 1; 
      $display("R2 = %h is wrong, expected %h", R3, 16'h12); 
      
    end

    if (datapath_out !== 16'h12) begin 
      err = 1; 
      $display("datapath_out=%h is wrong, expected %h", datapath_out, 16'h12); 
      
    end

    if (Z_out !== 1'b0) begin
      err = 1; 
      $display("Z_out=%b is wrong, expected %b", Z_out, 1'b0); 
       
    end

    if (N_out !== 1'b0) begin
		$display("ERROR IN N OUT, WAS %b BUT EXPECTED %b", N_out, 1'b0);
		err = 1'b1;
	end

	if (V_out !== 1'b0) begin
		$display("ERROR IN V OUT, WAS %b BUT EXPECTED %b", V_out, 1'b0);
		err = 1'b1;
	end

    //Checks a combination of addition and left shift. Ensures 2 + 4 LSL 1 = 10
    $display("Check addition and left shift operation");
    // MOV R3, #2
    sximm8 = 16'd2; 
    writenum = 3'd3;
    write = 1'b1;
    vsel = 2'b01;
    #10;
    
     // MOV R4, #4
    sximm8 = 16'd4; 
    writenum = 3'd4;
    write = 1'b1;
    vsel = 2'b01;
    #10;

    write = 1'b0;
    //write is done so set write to 0

    // R3+2R4
    // step 1 - load the value of R3 into A register
    readnum = 3'd3; 
    loada = 1'b1;
    #10; 
    loada = 1'b0; // after loading A, set loada to zero.

    // step 2 - load the value of R4 into B register
    readnum = 3'd4; 
    loadb = 1'b1;
    #10; 
    loadb = 1'b0; // after loading B, set loadb to zero.

    // step 3 - perform operation of A + 2B , load into C
    shift = 2'b01;
    asel = 1'b0;
    bsel = 1'b0;
    ALUop = 2'b00;
    loadc = 1'b1;
    loads = 1'b1;
    #10; 
    loadc = 1'b0;
    loads = 1'b0;

//checks if output is correct. Z, N, V should all be equal to 0.

    if (datapath_out !== 16'd10) begin 
      err = 1; 
      $display("datapath_out=%h is wrong, expected %h", datapath_out, 16'd10); 
       
    end

    if (Z_out !== 1'b0) begin
      err = 1; 
      $display("Z_out=%b is wrong, expected %b", Z_out, 1'b0); 
      
    end

	if (N_out !== 1'b0) begin
		$display("ERROR IN N OUT, WAS %b BUT EXPECTED %b", N_out, 1'b0);
		err = 1'b1;
	end

	if (V_out !== 1'b0) begin
		$display("ERROR IN V OUT, WAS %b BUT EXPECTED %b", V_out, 1'b0);
		err = 1'b1;
	end

    //Checks a combination of subtraction and right shift. Ensures that 6 - 12 LSR 1 is in the end equal to 0, and Z 1, N and V 0.
    $display("Check substraction and right shift operation");
    // MOV R5, #6
    sximm8 = 16'd6; 
    writenum = 3'd5;
    write = 1'b1;
    vsel = 2'b01;
    #10;
    
     // MOV R6, #12
    sximm8 = 16'd12; 
    writenum = 3'd6;
    write = 1'b1;
    vsel = 2'b01;
    #10;

    write = 1'b0;
    //write is done so set write to 0

    // R5-R6/2 
    // step 1 - load the value of R1 into A register
    readnum = 3'd5; 
    loada = 1'b1;
    #10; 
    loada = 1'b0; // after loading A, set loada to zero.

    // step 2 - load the value of R2 into B register
    readnum = 3'd6; 
    loadb = 1'b1;
    #10; 
    loadb = 1'b0; // after loading B, set loadb to zero.

    // step 3 - perform operation of A - B/2 , load into C
    shift = 2'b10;
    asel = 1'b0;
    bsel = 1'b0;
    ALUop = 2'b01;
    loadc = 1'b1;
    loads = 1'b1;
    #10; 
    loadc = 1'b0;
    loads = 1'b0;

	//Checks for the correct values of output and N, V, Z

    if (datapath_out !== 16'd0) begin 
      err = 1; 
      $display("datapath_out=%h is wrong, expected %h", datapath_out, 16'd0); 
      
    end

    if (Z_out !== 1'b1) begin
      err = 1; 
      $display("Z_out=%b is wrong, expected %b", Z_out, 1'b1); 
      
    end

	if (N_out !== 1'b0) begin
		$display("ERROR IN N OUT, WAS %b BUT EXPECTED %b", N_out, 1'b0);
		err = 1'b1;
	end

	if (V_out !== 1'b0) begin
		$display("ERROR IN V OUT, WAS %b BUT EXPECTED %b", V_out, 1'b0);
		err = 1'b1;
	end

	 //checks bitwise AND on its own. Ensures 1100001101100101 anded with 1111011000010011 is 1100001000000001.
    $display("Check A&B");
    
    sximm8 = 16'b1100001101100101; 
    writenum = 3'd0;
    write = 1'b1;
    vsel = 2'b01;
    #10;
    
   
    sximm8 = 16'b1111011000010011; 
    writenum = 3'd7;
    write = 1'b1;
    vsel = 2'b01;
    #10;

    write = 1'b0;
    //write is done so set write to 0

    // step 1 - load the value of R1 into A register
    readnum = 3'd0; 
    loada = 1'b1;
    #10; 
    loada = 1'b0; // after loading A, set loada to zero.

    // step 2 - load the value of R2 into B register
    readnum = 3'd7; 
    loadb = 1'b1;
    #10; 
    loadb = 1'b0; // after loading B, set loadb to zero.

    // step 3 - perform operation of A - B/2 , load into C
    shift = 2'b00;
    asel = 1'b0;
    bsel = 1'b0;
    ALUop = 2'b10;
    loadc = 1'b1;
    loads = 1'b1;
    #10; 
    loadc = 1'b0;
    loads = 1'b0;

	  //Checks correct output of datapath out, and ensures N is equal to 1, while Z and V are equal to 0.

    if (datapath_out !== 16'b1100001000000001) begin 
      err = 1; 
      $display("datapath_out=%h is wrong, expected %h", datapath_out, 16'b1100001000000001); 
       
    end

    if (Z_out !== 1'b0) begin
      err = 1; 
      $display("Z_out=%b is wrong, expected %b", Z_out, 1'b0); 
   
    end

    if (N_out !== 1'b1) begin
	    $display("ERROR IN N OUT, WAS %b BUT EXPECTED %b", N_out, 1'b1);
		err = 1'b1;
	end

	if (V_out !== 1'b0) begin
		$display("ERROR IN V OUT, WAS %b BUT EXPECTED %b", V_out, 1'b0);
		err = 1'b1;
	end

	//Checks the NOT operation. Ensures that output is 0000100111101100.
    $display("Check ~B");
    // step 1 - load the value of R7 into B register
    readnum = 3'd7; 
    loadb = 1'b1;
    #10; 
    loadb = 1'b0; // after loading B, set loadb to zero.

    // step 2 - perform operation of ~B, load into C
    shift = 2'b00;
    asel = 1'b1;
    bsel = 1'b0;
    ALUop = 2'b11;
    loadc = 1'b1;
    loads = 1'b1;
    #10; 
    loadc = 1'b0;
    loads = 1'b0;

	//Ensures datapath out is correct, and checks N, V, Z all equal to 0.
    if (datapath_out !== 16'b0000100111101100) begin 
      err = 1; 
      $display("datapath_out=%h is wrong, expected %h", datapath_out, 16'b0000100111101100);  
    end

    if (Z_out !== 1'b0) begin
      err = 1; 
      $display("Z_out=%b is wrong, expected %b", Z_out, 1'b0); 
    end

	if (N_out !== 1'b0) begin
		$display("ERROR IN N OUT, WAS %b BUT EXPECTED %b", N_out, 1'b0);
		err = 1'b1;
	end

	if (V_out !== 1'b0) begin
		$display("ERROR IN V OUT, WAS %b BUT EXPECTED %b", V_out, 1'b0);
		err = 1'b1;
	end

#10;
	asel = 1'b0;
	loadc = 1'b0;
	vsel = 2'b00;
	//TEST CASE: CHECKS TO SEE IF VSEL CAN SELECT mdata and PC. Since both are initiated to 0, end result when adding the two inputs should be 0.
	$display("PERFORMING TEST ON mdata and pc");

	//cycle 1: write mdata to R3
	sximm8 = 16'b0001111000011110;
	write = 1'b1;
	writenum = 3'b011;
	#10;

	//cycle 2: write PC to R4
	vsel = 2'b10;
	sximm8 = 16'b1111000011110000;
	writenum = 3'b100;
	#10; 

	//ADD R3 R4 without shift
	//cycle 3: read from R3 and store data into register B
	readnum = 3'b011;
	write = 1'b0;
	loadb = 1'b1;
	shift = 2'b00; 
	#10;

	//cycle 4: Reads R4 into A and performs ALU ADD operation on A and B
	readnum = 3'b100;
	loadb = 1'b0;
	loada = 1'b1;
	ALUop = 2'b00;
	#10;

	//cycle 5: Loads the output to C which stores it into datapath_out, checks to ensure it is equal to 0
	//also checks Z_out to ensure it is equal to 1. N and V should be 0.
	loada = 1'b0;
	loadc = 1'b1;
	loads = 1'b1;
	#10;
	 
	if (datapath_out !== 16'd0) begin
		$display("ERROR IN DATAPATH OUTPUT, WAS %b BUT EXPECTED %b", datapath_out, 16'd0);
		err = 1'b1;
	end
	
	//since the output is 0, z should be 1
	if (Z_out !== 1'b1) begin
		$display("ERROR IN Z OUTPUT, WAS %b BUT EXPECTED %b", Z_out, 1'b1);
		err = 1'b1;
	end

	if (N_out !== 1'b0) begin
		$display("ERROR IN N OUT, WAS %b BUT EXPECTED %b", N_out, 1'b0);
		err = 1'b1;
	end

	if (V_out !== 1'b0) begin
		$display("ERROR IN V OUT, WAS %b BUT EXPECTED %b", V_out, 1'b0);
		err = 1'b1;
	end

	if (~err) $display("PASSED");
	else $display ("FAILED");
	$stop;

  end
   

 endmodule
