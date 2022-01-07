module ALU_tb;
 reg err = 1'b0;
 reg [15:0] Ain, Bin;
 reg [1:0] ALUop;
 wire [15:0] out;
 wire Z;

ALU DUT(Ain,Bin,ALUop,out,Z);

//The task that checks if out is expected out and if Z is expected Z.
task check;
 input expect_z;
 input [15:0] expect_out;
begin

if(Z !== expect_z) begin
  $display ("Expected: %b but: %b", expect_z,Z);
  err=1;
end

if(out !== expect_out) begin
  $display ("Expected: %b but: %b", expect_out,out);
  err=1;
end

end
endtask

initial begin
  err=1'b0;//Initialize the err

  // Test the + operation, checks 2 + 3 = 5 and 5 + 9 = 14 and -1 + 2 = 1
  $display("Check the '+' operation (1)");
  Ain=16'd3; Bin=16'd2;  ALUop=2'b00; #10;
  check(1'b0, 16'd5);

  $display("Check the '+' operation (2)");
  Ain=16'd5; Bin=16'd9; #10; 
  check(1'b0, 16'd14);

  $display("Check the '+' operation (3)");
  Ain= -16'd1; Bin=16'd2; #10; 
  check(1'b0, 16'd1);

  // Test if Z is 1 when Ain + Bin = 0
  $display("Check Z ");
  Ain=16'd0; Bin=16'd0; #10;
  check(1'b1, 16'd0);

  // Test the - operation, checks 20 - 19 = 1 and 15 - 5 = 10 and 1 - 2 = -1
  $display("Check the '-' operation (1)");
  Ain=16'd20; Bin=16'd19;  ALUop=2'b01; #10;
  check(1'b0, 16'd1);
  
  
  $display("Check the '-' operation (2)");
  Ain=16'd15; Bin=16'd5;  #10;
  check(1'b0, 16'd10);
  
  $display("Check the '-' operation (3)");
  Ain=16'd1; Bin=16'd2;  #10;
  check(1'b0, {16{1'b1}});

  // Test if Z is 1 when Ain - Bin = 0
  $display("Check Z ");
  Ain=16'd3; Bin=16'd3;  #10;
  check(1'b1, 16'd0);

  // Test the & operation, ensures that 1000101001011111 & 1000101001011111 = 1000101001011111
  $display("Check the '&' operation (1)");
  Ain=16'b1000101001011111; Bin=16'b1000101001011111;  ALUop=2'b10; #10;
  check(1'b0, 16'b1000101001011111);

  //ensures that 1111010101100110 & 0110111111110110 = 0110010101100110
  $display("Check the '&' operation (2)");
  Ain=16'b1111010101100110; Bin=16'b0110111111110110;  #10;
  check(1'b0, 16'b0110010101100110);

  // Test if Z is 1 when Ain & Bin = 0
  $display("Check Z ");
  Ain={16{1'b1}}; Bin={16{1'b0}};  #10;
  check(1'b1, 16'd0);

  // Test the ~B operation
  //ensures that the result with input Bin = 1101010111010011 is 0010101000101100
  $display("Check the '~B' operation (1)");
  Ain=16'd5; Bin=16'b1101010111010011;  ALUop=2'b11; #10;
  check(1'b0, 16'b0010101000101100);

  //ensures the result with input Bin = 1100111010110110 is 0011000101001001
  $display("Check the '~B' operation (2)");
  Ain=16'd24; Bin=16'b1100111010110110;  #10;
  check(1'b0, 16'b0011000101001001);

  // Test if Z is 1 when Bin = {16{1'b1}}
  $display("Check Z ");
  Ain={16'd38}; Bin={16{1'b1}};  #10;
  check(1'b1, 16'd0);

   
  if(~err) $display("Passed");
  else $display("Failed");

end

endmodule
