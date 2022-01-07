module lab7_top_tb;
  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg err;

  lab7_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);

//sets up clk
  initial forever begin
    KEY[0] = 1; #5;
    KEY[0] = 0; #5;
  end

  initial begin
    err = 0;
    KEY[1] = 1'b0; // reset asserted
    // check if program from data.txt in the folder can be found loaded in memory
    if (DUT.MEM.mem[0] !== 16'b1101000000000111) begin err = 1; $display("FAILED: mem[0] wrong; Expected %b but was %b", 16'b1101000000000111, DUT.MEM.mem[0]); $stop; end
    if (DUT.MEM.mem[1] !== 16'b1101000100000010) begin err = 1; $display("FAILED: mem[1] wrong; Expected %b but was %b", 16'b1101000100000010, DUT.MEM.mem[1]); $stop; end
    if (DUT.MEM.mem[2] !== 16'b1010000101001000) begin err = 1; $display("FAILED: mem[2] wrong; Expected %b but was %b", 16'b1010000101001000, DUT.MEM.mem[2]); $stop; end
    if (DUT.MEM.mem[3] !== 16'b1100000001110001) begin err = 1; $display("FAILED: mem[3] wrong; Expected %b but was %b", 16'b1100000001110001, DUT.MEM.mem[3]); $stop; end
    if (DUT.MEM.mem[4] !== 16'b1010101100000010) begin err = 1; $display("FAILED: mem[4] wrong; Expected %b but was %b", 16'b1010101100000010, DUT.MEM.mem[4]); $stop; end
    if (DUT.MEM.mem[5] !== 16'b1101010000000011) begin err = 1; $display("FAILED: mem[5] wrong; Expected %b but was %b", 16'b1101010000000011, DUT.MEM.mem[5]); $stop; end
    if (DUT.MEM.mem[6] !== 16'b1011001110100100) begin err = 1; $display("FAILED: mem[6] wrong; Expected %b but was %b", 16'b1011001110100100, DUT.MEM.mem[6]); $stop; end
    if (DUT.MEM.mem[7] !== 16'b1011100001111010) begin err = 1; $display("FAILED: mem[7] wrong; Expected %b but was %b", 16'b1011100001111010, DUT.MEM.mem[7]); $stop; end
    if (DUT.MEM.mem[8] !== 16'b1110000000000000) begin err = 1; $display("FAILED: mem[8] wrong; Expected %b but was %b", 16'b1110000000000000, DUT.MEM.mem[8]); $stop; end
    #10; // wait until next falling edge of clock
    KEY[1] = 1'b1; // reset de-asserted, PC still undefined if as in Figure 4

    #10; // waiting for RST state to cause reset of PC

    if (DUT.CPU.PC !== 9'b0) begin err = 1; $display("FAILED: PC is not reset to zero."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; testbench expects PC set to 1 *before* executing MOV R0, 7.

    if (DUT.CPU.PC !== 9'h1) begin err = 1; $display("FAILED: PC should be 1."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; testbench expects PC set to 2 *after* executing MOV R0, 7

    if (DUT.CPU.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2."); $stop; end
    if (DUT.CPU.DP.REGFILE.R0 !== 16'h7) begin err = 1; $display("FAILED: R0 should be %b but was %b.", 16'h7, DUT.CPU.DP.REGFILE.R0); $stop; end  // because MOV R0, 7 should have occurred

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; testbench expects PC set to 3 *after* executing MOV R1, 2

    if (DUT.CPU.PC !== 9'h3) begin err = 1; $display("FAILED: PC should be 3."); $stop; end
    if (DUT.CPU.DP.REGFILE.R1 !== 16'h2) begin err = 1; $display("FAILED: R1 should be %b but was %b.", 16'h2, DUT.CPU.DP.REGFILE.R1); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; testbench expects PC set to 4 *after* executing ADD R2, R1, R0, LSL #1

    if (DUT.CPU.PC !== 9'h4) begin err = 1; $display("FAILED: PC should be 4."); $stop; end
    if (DUT.CPU.DP.REGFILE.R2 !== 16'h10) begin err = 1; $display("FAILED: R2 should be 16 but was %b.", DUT.CPU.DP.REGFILE.R2); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC); //wait here until PC changes; testbench expects PC set to 5 AFTER executing MOV R3, R1, LSR #1 
    if (DUT.CPU.PC !== 9'h5) begin err = 1; $display("FAILED: PC should be 5."); $stop; end
    if (DUT.CPU.DP.REGFILE.R3 !== 16'd1) begin err = 1; $display("FAILED: R3 should be 1 but was %b.", DUT.CPU.DP.REGFILE.R3); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC); //wait here until PC changes; testbench expects PC set to 6 AFTER executing CMP R3, R2
    if (DUT.CPU.PC !== 9'h6) begin err = 1; $display("FAILED: PC should be 6."); $stop; end
    if (DUT.CPU.DP.N_out !== 1'b1) begin err = 1; $display("FAILED: N should be 1 but was %b.", DUT.CPU.DP.N_out); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC); //wait here until PC changes; testbench expects PC set to 7 AFTER executing MOV R4, #3
    if (DUT.CPU.PC !== 9'h7) begin err = 1; $display("FAILED: PC should be 7."); $stop; end
    if (DUT.CPU.DP.REGFILE.R4 !== 16'd3) begin err = 1; $display("FAILED: R4 should be 3 but was %b.", DUT.CPU.DP.REGFILE.R4); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; testbench expects PC set to 8 *after* executing AND R5, R3, R4

    if (DUT.CPU.PC !== 9'h8) begin err = 1; $display("FAILED: PC should be 8."); $stop; end
    if (DUT.CPU.DP.REGFILE.R5 !== 16'h1) begin err = 1; $display("FAILED: R5 should be 1 but was %b.", DUT.CPU.DP.REGFILE.R5); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 9 *after* executing MVN R3, R2, ASR#1

    if (DUT.CPU.PC !== 9'h9) begin err = 1; $display("FAILED: PC should be 9."); $stop; end
    if (DUT.CPU.DP.REGFILE.R3 !== -16'd9) begin err = 1; $display("FAILED: R5 should be -9 but was %b.", DUT.CPU.DP.REGFILE.R3); $stop; end

    // NOTE: if HALT is working, PC won't change again...

    if (~err) $display("INTERFACE OK");
    $stop;
  end
endmodule
