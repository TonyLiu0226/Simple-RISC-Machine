`define SW 4
//state encodings for the FSM
`define Wait 4'd0
`define Decode 4'd1
`define WriteToRn 4'd2
`define ReadRm 4'd3
`define Shift 4'd4
`define WriteRd 4'd5
`define ReadRn 4'd6
`define NOT 4'd7
`define ADD 4'd8
`define AND 4'd9
`define CMP 4'd10


module cpu_tb;
  reg clk, reset, s, load;
  reg [15:0] in;
  wire [15:0] out;
  wire N,V,Z,w;

  reg err;

//instantiates the CPU module to be tested
  cpu DUT(clk,reset,s,load,in,out,N,V,Z,w);

//sets up the clk to alternate between high and low every 5 secs
  initial begin
    clk = 0; #5;
    forever begin
      clk = 1; #5;
      clk = 0; #5;
    end
  end

//main block where all the tests will run
  initial begin
    err = 0;
    reset = 1; s = 0; load = 0; in = 16'b0;
    #10;
    reset = 0; 
    #10;
//THE FOLLOWING SET OF TESTS CHECKS THE MOV, <#IM8> INSTRUCTION
$display("CHECKING MOV OPERATION");
#50;
//FIRST CASE: TESTS MOV to a positive constant: MOV R4, #16. Ensures R4 is equal to 16 in the end
    $display("TESTING MOV R4, #16");	
    in = 16'b1101010000010000;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R4 !== 16'b0000000000010000) begin
      err = 1;
      $display("FAILED: MOV R4, #16. Expected %b but was %b", 16'b0000000000010000, cpu_tb.DUT.DP.REGFILE.R4);
    end

//SECOND CASE: TESTS MOV to 0: MOV R1, #0. Ensures R1 is equal to 0 in the end 
    $display("TESTING MOV R1, #0");
    in = 16'b1101000100000000;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'h0) begin
      err = 1;
      $display("FAILED: MOV R1, #0. Expected %b but was %b", 16'h0, cpu_tb.DUT.DP.REGFILE.R1);
    end

//THIRD CASE: TESTS MOV to a negative constant: MOV R4, #-1. Ensures R1 is equal to -1 in the end
	$display("TESTING MOV R4, #-1");	
    in = 16'b1101010011111111;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R4 !== -16'd1) begin
      err = 1;
      $display("FAILED: MOV R4, #-1. Expected %b but was %b", -16'd1, cpu_tb.DUT.DP.REGFILE.R4);
    end

//FOURTH CASE: TESTS MOV R3 #19 TO PREPARE FOR ADD INSTRUCTION. Ensures R3 is equal to 19
$display("TESTING MOV R3, #19");	
    in = 16'b1101001100010011;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R3 !== 16'd19) begin
      err = 1;
      $display("FAILED: MOV R3, #19. Expected %b but was %b", 16'd19, cpu_tb.DUT.DP.REGFILE.R3);
    end

//THE FOLLOWING SET OF TESTS CHECKS THE ADD INSTRUCTION
#50;
$display("CHECKING ADD OPERATION");
#10;

//FIRST CASE: TESTS POSITIVE NUM + NEGATIVE NUM: ADD R2, R3, R4 --> ensures 19+-1 = 18
$display("CHECKING ADD R2, R3, R4");
in = 16'b1010001101000100;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'd18) begin
      err = 1;
      $display("FAILED: ADD R2 R3 R4, Expected %b but was %b", 16'd18, cpu_tb.DUT.DP.REGFILE.R2);
    end


//SECOND CASE: TESTS POSITIVE NUM + POSITIVE NUM AND LEFT SHIFT: ADD R5, R3, R2, LSR #1 --> ensures 19 + 9 = 28
$display("CHECKING ADD R5, R3, R2, LSR #1");
in = 16'b1010001110110010;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R5 !== 16'd28) begin
      err = 1;
      $display("FAILED: ADD R5 R3 R2 LSR #1, Expected %b but was %b", 16'd28, cpu_tb.DUT.DP.REGFILE.R5);
    end

//THIRD CASE: TESTS POSITIVE NUM + POSITIVE NUM AND RIGHT SHIFT: ADD R6, R5, R5, LSL #1 --> Ensures 28 + 56 = 84
$display("CHECKING ADD R6, R5, R5, LSL #1"); 
in = 16'b1010010111001101;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R6 !== 16'd84) begin
      err = 1;
      $display("FAILED: ADD R6 R5 R5 LSL #1, Expected %b but was %b", 16'd84, cpu_tb.DUT.DP.REGFILE.R6);
    end

//THE FOLLOWING SET OF TESTS CHECKS THE AND INSTRUCTION
#50;
$display("CHECK AND OPERATION");
#10;

//FIRST CASE: Trivial test to check if a number anded with itself is still the same number. AND R7, R5, R5, ASSURES R7 = R5
$display("CHECKING AND R7, R5, R5"); 
in = 16'b1011010111100101;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R7 !== 16'd28) begin
      err = 1;
      $display("FAILED: AND R7 R5 R5, Expected %b but was %b", 16'd28, cpu_tb.DUT.DP.REGFILE.R7);
    end

//SECOND CASE: Tests NUM AND WITH OTHER NUM WITHOUT SHIFT: AND R0, R5, R3, ASSURES R0 IS EQUAL TO R5 & R3 WHICH IN THIS CASE IS 16
$display("CHECKING AND R0, R5, R3"); 
in = 16'b1011010100000011;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R0 !== 16'd16) begin
      err = 1;
      $display("FAILED: AND R0 R5 R3, Expected %b but was %b", 16'd16, cpu_tb.DUT.DP.REGFILE.R0);
    end

//THIRD TEST: Tests NUM AND WITH OTHER NUM WITH LEFT SHIFT: AND R0, R5, R0, LSL #1, ASSURES R0 IS EQUAL TO R5 & R0*2, WHICH IN THIS CASE IS 0
$display("CHECKING AND R0, R5, R0, LSL #1"); 
in = 16'b1011010100001000;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R0 !== 16'd0) begin
      err = 1;
      $display("FAILED: AND R0 R5 R0 LSL #1, Expected %b but was %b", 16'd0, cpu_tb.DUT.DP.REGFILE.R0);
    end

//FOURTH TEST: Tests NUM AND WITH OTHER NUM WITH RIGHT SHIFT: AND R0, R3, R2, ASR #1, ASSURES R0 IS EQUAL TO R3 & R2/2, WHICH IN THIS CASE IS 1
$display("CHECKING AND R0, R3, R2, ASR #1"); 
in = 16'b1011001100011010;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R0 !== 16'd1) begin
      err = 1;
      $display("FAILED: AND R0 R3 R2 ASR #1, Expected %b but was %b", 16'd1, cpu_tb.DUT.DP.REGFILE.R0);
    end

//THE FOLLOWING SET OF TESTS CHECKS MOV RD RM OPERATION
#50;
$display("CHECKING MOV RD RM");
#10;

//First two tests moves values to registers to set up the tests for the MOV RD RM
  //Test MOV R3, #4, ensures R3 is 4
     $display("MOV R3, #4");
    in = 16'b1101001100000100;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R3 !== 16'd4) begin
      err = 1;
      $display("FAILED: MOV R3, #4");
      $stop;
    end

      //Test MOV R7, #10, ensures R7 is 10
       $display("MOV R7, #10");
    in = 16'b1101011100001010;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R7 !== 16'd10) begin
      err = 1;
      $display("FAILED: MOV R7, #10");
      $stop;
    end
    
    //Tests MOV a register to another register without shift (1):  MOV R1, R7. Ensures value of R1 in the end is equal to value of R7.
     $display("MOV R1, R7");
    in = 16'b1100000000100111;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'd10) begin
      err = 1;
      $display("FAILED: MOV R1, R7");
      $stop;
    end
    
   

    //Tests MOV a register to another register without shift (2):  MOV R2, R3. Ensures value of R2 in the end is equal to value of R3.
    $display("MOV R2, R3");
    in = 16'b1100000001000011;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'd4) begin
      err = 1;
      $display("FAILED: MOV R2, R3");
      $stop;
    end


 //Tests MOV a register to another register with a left shift:  MOV R1, R2, LSL#1. Ensures value of R1 in the end is equal to value of (R2*2).
    $display("MOV R1, R2,LSL#1");
    in = 16'b1100000000101010;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'd8) begin
      err = 1;
      $display("FAILED: MOV R1, R2,LSL#1");
      $stop;
    end

    //Tests MOV a register to another register with right shift:  MOV R1, R2, LSR #1. Ensures value of R1 in the end is equal to value of R2/2.
   $display("MOV R1, R2,LSR#1 ");
    in = 16'b1100000000111010;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'd2) begin
      err = 1;
      $display("FAILED: MOV R1, R2,LSR#1 ");
      $stop;
    end

//THE FOLLOWING SET OF TESTS TESTS THE CMP INSTRUCTION
#50;
$display("CHECKING CMP OPERATION");
#10;

    $display("CMP R1, R2 ");
    //Test CMP OF TWO NUMS WITHOUT ANY SHIFT: CMP R1, R2. Ensures N is 1, Z is 0, and V is 0 in the end
    in = 16'b1010100100000010;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (N !== 1'b1) begin
      err = 1;
      $display("FAILED:CMP R1, R2 ");
      $stop;
    end

     if (Z !== 1'b0) begin
      err = 1;
      $display("FAILED: CMP R1, R2 ");
      $stop;
    end
     if (V!== 1'b0) begin
      err = 1;
      $display("FAILED: CMP R1, R2 ");
      $stop;
    end
  
     //Test CMP OF TWO NUMS WITH A LEFT SHIFT: CMP R2, R1,LSL#1. Ensures N is 0, Z is 1, and V is 0 in the end.
    $display("CMP R2, R1,LSL#1 ");
    in = 16'b1010101000001001;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (N !== 1'b0) begin
      err = 1;
      $display("FAILED: CMP R2, R1,LSL#1 ");
      $stop;
    end

     if (Z !== 1'b1) begin
      err = 1;
      $display("FAILED: CMP R2, R1,LSL#1 ");
      $stop;
    end
     if (V!== 1'b0) begin
      err = 1;
      $display("FAILED: CMP R2, R1,LSL#1 ");
      $stop;
    end

//THE NEXT TWO TESTS SIMPLY MOVES NEW VALUES INTO R3 AND R7 TO SET UP THE FINAL TEST FOR CMP
 //Test MOV R3, #4, ensures R3 is equal to 4
     $display("MOV R3, #127");
    in = 16'b1101001101111111;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R3 !== 16'd127) begin
      err = 1;
      $display("FAILED: MOV R3, #4");
      $stop;
    end

      //Test MOV R7, #-127, ensures R7 is equal to -127
       $display("MOV R7, #-127");
    in = 16'b1101011110000001;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R7 !== -16'd127) begin
      err = 1;
      $display("FAILED: MOV R7, #-127");
      $stop;
    end

$display("CMP R3, R7 ");
    //Tests CMP between a positive number and a negative number: CMP R1, R2. Ensures Z is 0, and V is 1 in the end
    in = 16'b1010101100000111;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (N !== 1'b0) begin
      err = 1;
      $display("FAILED:CMP R3, R7 ");
      $stop;
    end

     if (Z !== 1'b0) begin
      err = 1;
      $display("FAILED: CMP R3, R7 ");
      $stop;
    end
     if (V!== 1'b1) begin
      err = 1;
      $display("FAILED: CMP R3, R7 ");
      $stop;
    end

//THE FOLLOWING SET OF TESTS CHECKS THE MVN INSTRUCTION
#50;
$display("CHECKING MVN OPERATION");
#10;
    
    //Test MVN of a positive number: MVN R4, R2. Ensures R4 is equal to the NOT of the bits of R2 in the end, which in this case is -5.
   $display("MVN R4, R2 ");
    in = 16'b1011100010000010;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R4 !== -16'd5) begin
      err = 1;
      $display("FAILED: MVN R4, R2 ");
      $stop;
    end
    
     //Test MVN of a negative number: MVN R4, R1. Ensures R4 is equal to the NOT of R1 in the end, which in this case is -3.
   $display("MVN R4, R1 ");
    in = 16'b1011100010000001;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R4 !== -16'd3) begin
      err = 1;
      $display("FAILED: MVN R4, R1 ");
      $stop;
    end

    //Test the same instruction but with a right shift operation: MVN R4, R1, LSR#1. Ensures R4 is equal to the NOT of (R1/2) in the end, which in this case is -2. 
   $display("MVN R4, R1, LSR#1 ");
    in = 16'b1011100010010001;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R4 !== -16'd2) begin
      err = 1;
      $display("FAILED: MVN R4, R1, LSR#1 ");
      $stop;
    end

if (~err) $display("PASSED");
else $display("FAILED");
$stop;

end
endmodule
