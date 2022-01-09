`define MREAD 2'b01
`define MWRITE 2'b10
`define MNONE 2'b00

module top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
input [3:0] KEY;
input [9:0] SW;
output [9:0] LEDR;
output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
wire clk,reset,msel,writeMem,N,V,Z;
wire [8:0] mem_addr;
wire [7:0] read_address,write_address;
wire [15:0]read_data,datapath_out,dout,write_data;
wire [1:0] mem_cmd;
wire o1, o2, loadOut;
wire equals;

//assign clock to Key 0
assign clk=~KEY[0];

//Assign reset to Key 1
assign reset=~KEY[1];

//Hex5 bits 0, 3 and 6 represent the Zero, Negative and Overflow flags
assign HEX5[0] = ~Z;
  assign HEX5[6] = ~N;
  assign HEX5[3] = ~V;

  // fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
  sseg H0(datapath_out[3:0],   HEX0);
  sseg H1(datapath_out[7:4],   HEX1);
  sseg H2(datapath_out[11:8],  HEX2);
  sseg H3(datapath_out[15:12], HEX3);
//HEX4 IS DISABLED
  assign HEX4 = 7'b1111111;
  assign {HEX5[2:1],HEX5[5:4]} = 4'b1111; // disabled

//Instantiates the RAM module
RAM #(16,8,"data.txt") MEM (clk,read_address,write_address,writeMem,datapath_out,dout);

//Instantiates the CPU
cpu CPU(clk,reset,read_data,datapath_out,N,V,Z,mem_cmd,mem_addr);

//assigns write_data to the memory to datapath_out
assign write_data = datapath_out;

//assigns the read_address to the lower 8 bits of mem_addr
assign read_address = mem_addr[7:0];
//assigns the write_address to the lower 8 bits of mem_addr
assign write_address = mem_addr[7:0];
//assign msel to either either 1 or 0, depending on whether or not mem_addr[8] is equal to 0
assign msel = (mem_addr[8]==1'b0) ? 1'b1: 1'b0;

//assign read_data to msel ANDED with the MREAD command. If not MREAD, then output z
assign read_data = msel&(mem_cmd==`MREAD)? dout : {16{1'bz}};

assign writeMem = msel&(mem_cmd==`MWRITE);//controls the write signal

assign read_data[7:0] = (mem_addr == 9'h140)&(mem_cmd==`MREAD) ? SW[7:0]: {8{1'bz}};// If address is 9'h140 and mem_cmd=mread, reads the value on switches SW0 through SW7
assign read_data[15:8] = (mem_addr == 9'h140)&(mem_cmd==`MREAD) ? 8'h00: {8{1'bz}};// If address is 9'h140 and mem_cmd=mread, the upper bits will be zero.

//assign equals to whether or not mem_addr is equal to 9'h100. 1 if mem_addr is equal to 9'h100, otherwise 0
assign equals = (mem_addr === 9'h100);
//assign o2 to equals ANDED with mem_cmd[1]
assign o2 = equals & mem_cmd[1];
//assign o1 to equals ANDED with the NOT of mem_cmd[0]
assign o1 = equals & ~mem_cmd[0];
//assign loadOut to O1 AND O2. loadOut should be 1 ONLY IF write is equal to MWRITE and equals is 1
assign loadOut = o2 & o1;

//Instantiates VDFF for LED register
vDFF1 #(8) LED_REG(clk, write_data[7:0], loadOut, LEDR[7:0]);

endmodule


module RAM(clk,read_address,write_address,write,din,dout);
  parameter data_width = 32; 
  parameter addr_width = 4;
  parameter filename = "data.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename, mem);

//writes to din when WRITE SIGNAL is 1
  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
endmodule 

//module for output onto 7 segment display
module sseg(in,segs);
  input [3:0] in;
  output [6:0] segs;
  reg [6:0] segs;

//always block to display the different possible values (0-hexf) for each 7 segment display
  always @* begin
    case(in)
     4'd0: segs = 7'b1000000;
     4'd1: segs = 7'b1111001;
     4'd2: segs = 7'b0100100; 
     4'd3: segs = 7'b0110000;
     4'd4: segs = 7'b0011001;
     4'd5: segs = 7'b0010010;
     4'd6: segs = 7'b0000010; 
     4'd7: segs = 7'b1111000;
     4'd8: segs = 7'b0000000;
     4'd9: segs = 7'b0010000;
     4'd10: segs = 7'b0001000; // output A
     4'd11: segs = 7'b0000011; // output b
     4'd12: segs = 7'b1000110; // output C
     4'd13: segs = 7'b0100001; // output d
     4'd14: segs = 7'b0000110; // output E
     4'd15: segs = 7'b0001110; // output F  
     default: segs=7'bxxxxxxx;
    endcase
  end
endmodule
