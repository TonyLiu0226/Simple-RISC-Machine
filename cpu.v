//defines values for the state encodings
`define SW 5
`define RST 5'd11
`define IF1 5'd12
`define IF2 5'd13
`define UpdatePC 5'd0
`define Decode 5'd1
`define WriteToRn 5'd2
`define ReadRm 5'd3
`define Shift 5'd4
`define WriteRd 5'd5
`define ReadRn 5'd6
`define NOT 5'd7
`define ADD 5'd8
`define AND 5'd9
`define CMP 5'd10
`define HALT 5'd14
`define SXMM 5'd15
`define DataAdd 5'd16
`define ReadMem 5'd17
`define WriteMemToRd 5'd18
`define ReadRd 5'd19
`define OutputRd 5'd20
`define WriteMem 5'd21
`define DELAY 5'd22
`define MREAD 2'b01
`define MWRITE 2'b10
`define MNONE 2'b00

module cpu(clk,reset,in,out,N,V,Z, mem_cmd, mem_addr);
	input clk, reset;
	input [15:0] in;
	output [15:0] out;
	output N, V, Z;
	wire [15:0] regOut, sximm5, sximm8,mdata, out, pc;
        wire[2:0] opcode,nsel, readnum, writenum; 
        wire[1:0] op, ALUop, shift,vsel;
        wire loada, loadb, loadc, loads, asel, bsel,write, address_select, load_PC, reset_PC, load_ir, load_addr;
	wire[8:0] next_PC, PC, next_PC_out_plusOne, DA; 
	output[1:0] mem_cmd;
	output[8:0] mem_addr; 
	//assigns pc to 8'b0, followed by the value of the program counter
	assign pc = {8'b0, PC};
	//instantiate a vDFF2 for loading instruction into instruction register
	vDFF1 #(16) instructionRegister(clk, in, load_ir, regOut);
	
	//instantiates an instance of the instruction decoder that will drive the input of the FSM and signals to datapath
	instruction_decoder ID(regOut, nsel, ALUop, sximm5, sximm8, shift, readnum, writenum, opcode, op);

	//instantiates the FSM controller
	FSM fSM(clk,reset,opcode,op,nsel,loada,loadb,loadc,loads,asel,bsel,vsel,write, mem_cmd, address_select, load_PC, reset_PC, load_ir, load_addr);

	//instantiates the datapath
	datapath DP(.clk(clk), .write(write),.loada(loada),.loadb(loadb),.loadc(loadc),.loads(loads)
                       , .asel(asel),.bsel(bsel),.vsel(vsel), .writenum(writenum), 
                      .readnum(readnum),  .sximm5(sximm5), .sximm8(sximm8), .mdata(in), 
                     .PC(pc),  .datapath_out(out), .shift(shift), .ALUop(ALUop)  
                      , .N_out(N), .V_out(V), .Z_out(Z));

	//Lab 6 changes
	//Instantiates a multiplexer to increment the program counter
	assign next_PC = reset_PC ? 9'b000000000: next_PC_out_plusOne;

	//instantiate a vDFF3 for loading onto the PC
	vDFF1 #(9) Program_Counter(clk, next_PC, load_PC, PC);

	//instantiate the incrementer to increment PC after each load into the program counter
	assign next_PC_out_plusOne = PC + 9'd1;
	
	//instantiates a multiplexer to drive the output mem_addr
	assign mem_addr = address_select ? PC: DA; 

	//LAB 6 STAGE 2
	//instantiates a vDFF to load the data address
	vDFF1 #(9) Data_Address(clk, out[8:0], load_addr, DA);

endmodule


//the instruction decoder module that was instantiated in cpu
module instruction_decoder(instruction,nsel,ALUop,sixmm5,sixmm8,shift,readnum,writenum,opcode,op);
	input[15:0] instruction;
 	input[2:0] nsel;
 	output[1:0] ALUop,shift,op;
 	output[2:0] readnum,writenum,opcode;
 	output[15:0] sixmm5,sixmm8;
	wire [2:0] rd;
	wire [2:0] rn;
	wire [2:0] rm;
	reg [2:0] multOut;

	//assigns rd to instruction bits 7 through 5 as per specification
	assign rd = instruction[7:5];
	//assigns rn to instruction bits 10 through 8 as per specification
	assign rn = instruction[10:8];
	//assigns rm to instruction bits 2 through 0 as per specification
	assign rm = instruction[2:0];
	
	assign ALUop = instruction[12:11]; // ALUop is the bit 12 to 11 of assembly instruction
 	assign shift = instruction[4:3]; // Shift is the bit 4 to 3 of assembly instruction

 	// If im5 is positive, the upper 11 bits will be 0. otherwise, they will be 1 
 	assign sixmm5 = (instruction[4]==0) ? {{11{1'b0}},instruction[4:0]}:{{11{1'b1}},instruction[4:0]};
 	// If im8 is positive, the upper 8 bits will be 0. otherwise, they will be 1 
 	assign sixmm8 = (instruction[7]==0) ? {{8{1'b0}},instruction[7:0]}:{{8{1'b1}},instruction[7:0]};

	//multiplexer to choose which of rd, rn or rm to feed into multiplexer, with nsel acting as the select
	always @* begin
                
		case (nsel)
			3'b001: multOut = rn;
			3'b010: multOut = rd;
			3'b100: multOut = rm;
			//should never reach this statement, as all one-hot possible inputs for nsel are already covered above
			default: multOut = 3'b000;
		endcase
	end

	//assigns the readnum to the output of the multiplexer created earlier 
	assign readnum = multOut;
	//assigns the writenum to the output of the multiplexer created earlier
	assign writenum = multOut;

	//assigns the opcode to drive the state machine
	assign opcode = instruction[15:13];
	//assign the op value to drive the state machine
	assign op = instruction[12:11];

endmodule


//the FSM module that was instantiated in cpu
module FSM(clk,reset,opcode,op,nsel,loada,loadb,loadc,loads,asel,bsel,vsel,write, mem_cmd, address_select, load_PC, reset_PC, load_ir, load_addr);
input clk, reset;
input [1:0] op;
input [2:0] opcode; 
output loada,loadb,loadc,loads,write,asel,bsel, address_select, load_PC, reset_PC, load_ir, load_addr;
output [1:0] vsel, mem_cmd;
output[2:0] nsel;

wire [`SW-1:0] present_state, state_next_reset, next_state;
//instantiates a vDFF for the state machine
vDFF2 #(`SW) STATE(clk,state_next_reset,present_state);
//multiplexer to choose between either going to the next state, or reset state, based on the reset input
assign state_next_reset = reset ? `RST: next_state;
reg [(`SW+19)-1:0] next;

//assigns all required values in the next state to next
assign {next_state,loada,loadb,loadc,loads,write,asel,bsel,vsel,nsel, address_select, load_PC, load_ir, reset_PC, mem_cmd, load_addr}=next;

always @(*) begin
	casex ({present_state, opcode, op})
            // State RST: the next state will be IF1, regardless of the opcode or op
	   // All outputs are 0 except for load_pc and reset_pc, which are both 1.
           {`RST, 5'bxxxxx}: next= {`IF1, 18'b000000000000010100, 1'b0};
	//STATE IF1: The next state will be IF2, regardless of the opcode or op
	//All outputs are 0 except for address_select and mem_cmd, which are 1 and MREAD respectively
	   {`IF1, 5'bxxxxx}: next = {`IF2, 16'b0000000000001000, `MREAD, 1'b0};
	//STATE IF2: The next state will be UpdatePC, regardless of the opcode or op
	//All outputs are 0 except for address_select and load_ir which are both 1, and mem_cmd which is MREAD
	   {`IF2, 5'bxxxxx}: next= {`UpdatePC,{12{1'b0}},1'b1,1'b0,1'b1,1'b0,`MREAD, 1'b0};
	//STATE UpdatePC: The next state will be decode, regardless of the opcode or op
	//All outputs are 0 except for load_pc, which is 1.
           {`UpdatePC, 5'bxxxxx}: next= {`Decode, {12{1'b0}},1'b0,1'b1,2'b00,`MNONE, 1'b0};

           // State decode: The output is all zeros. If opcode is 110 and op is 10 it will change to WriteToRn
           //  If opcode is 110 and op is 00 or pcode is 101 and op is 11 it will change to ReadRm
	   //If opcode is 111 it will go to HALT
           // Otherwise, it will change to ReadRn
           {`Decode,5'b11010 }: next={`WriteToRn,{19{1'b0}}};
	   {`Decode, 5'b11000},{`Decode, 5'b10111}: next={`ReadRm,{19{1'b0}}};
	   {`Decode, 5'b11100}: next = {`HALT, {19{1'b0}}};
           {`Decode,5'bxxxxx}: next={`ReadRn,{19{1'b0}}};

           //State WriteToRn: loadc=1 vsel=01 and nsel=001. 
           // It will change to IF1 regardless of opcode or op
	   {`WriteToRn, {5{1'bx}}}: next={`IF1,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,2'b01,3'b001, 4'b0000, `MNONE, 1'b0};

           //State ReadRn: loada=1 and nsel=001. 
           // It will change to ReadRm if opcode and op are not 01100 OR 10000.
	   // If opcode and op are 01100 OR 10000, it will go to SXMM
	   {`ReadRn, 5'b01100}, {`ReadRn, 5'b10000}: next = {`SXMM, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 3'b001, 4'b0000, `MNONE, 1'b0};
	   {`ReadRn, {5{1'bx}}}: next = {`ReadRm, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 3'b001, 4'b0000, `MNONE, 1'b0};
	   

           //State ReadRn: loadb=1 and nsel=100. 
           // If opcode is 110 and op is 00, it will change to Shift
	   {`ReadRm, 5'b11000}: next = {`Shift, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 3'b100, 4'b0000, `MNONE, 1'b0}; 
            // If opcode is 101 and op is 11, it will change to NOT
	   {`ReadRm, 5'b10111}: next = {`NOT, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 3'b100, 4'b0000, `MNONE, 1'b0}; 
            // If opcode is 101 and op is 10, it will change to AND
	   {`ReadRm, 5'b10110}: next = {`AND, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 3'b100, 4'b0000, `MNONE, 1'b0}; 
           // If opcode is 101 and op is 01, it will change to CMP
	   {`ReadRm, 5'b10101}: next = {`CMP, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 3'b100, 4'b0000, `MNONE, 1'b0}; 
           // If opcode is 101 and op is 00, it will change to ADD
	   {`ReadRm, 5'b10100}: next = {`ADD, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 3'b100, 4'b0000, `MNONE, 1'b0};
            
	   //State ADD loadc=1.
           // It will change to WriteRd
           {`ADD, {5{1'bx}}}: next = {`WriteRd, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 3'b000,4'b0000, `MNONE, 1'b0};

            //State AND loadc=1.
            // It will change to WriteRd
           {`AND, {5{1'bx}}}: next = {`WriteRd, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 3'b000, 4'b0000, `MNONE, 1'b0};

            //State CMP loads=1, others are zero.
            // It will change to IF1
           {`CMP,5'bxxxxx}: next={`IF1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, 3'b000, 4'b0000, `MNONE, 1'b0};

            //State NOT loadc=1, asel=1.
            // It will change to WriteRd
           {`NOT,5'bxxxxx}: next={`WriteRd, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 2'b00, 3'b000, 4'b0000, `MNONE, 1'b0};

            //State Shift loadc=1, asel=1.
            // It will change to WriteRd
           {`Shift,5'bxxxxx}: next={`WriteRd, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 2'b00, 3'b000, 4'b0000, `MNONE, 1'b0};

            //State WriteRd vsel=11 and nsel=010 and write 1.
            // It will change to IF1
           {`WriteRd,5'bxxxxx}: next={`IF1, 1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,2'b11,3'b010, 4'b0000, `MNONE, 1'b0};

	   //State SXMM bsel = 1, loadc = 1
	   //It will change to DataAdd
	   {`SXMM, 5'bxxxxx}: next = {`DataAdd, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 3'b000, 4'b0000, `MNONE, 1'b0};

	   //State DataAdd load_addr = 1, everything else 0
	   //If opcode and op are 01100, it will go to ReadMem. If opcode and op are 10000, it will go to ReadRd
	   {`DataAdd, 5'b01100}: next = {`ReadMem, {16{1'b0}}, `MNONE, 1'b1};
	   {`DataAdd, 5'b10000}: next = {`ReadRd, {16{1'b0}}, `MNONE, 1'b1};

	   //State ReadRd loadb = 1, nsel = 010, all others = 0
	   //It will change to OutputRd
	   {`ReadRd, 5'bxxxxx}: next = {`OutputRd, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 3'b010, 4'b0000, `MNONE, 1'b0};

	   //State OutputRd asel = 1 loadc = 1, all others 0
	   //It will change to WriteMem
	   {`OutputRd, 5'bxxxxx}: next = {`WriteMem, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 2'b00, 3'b000, 4'b0000, `MNONE, 1'b0};
	   
	   //State WriteMem address_select = 0, mem_cmd = MWRITE, all others 0
	   //It will change to IF1
	   {`WriteMem, 5'bxxxxx}: next = {`IF1, 12'b000000000000, 4'b0000, `MWRITE, 1'b0};

	   //State ReadMem addr_sel=0 and mem_cmd=MREAD
           // It will change to WriteMemToRd
            {`ReadMem,5'bxxxxx}: next={`WriteMemToRd, 1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,2'b00,3'b000, 4'b0000, `MREAD, 1'b0};
	    
           //State WriteMemToRd write=1 and vsel=2'b00
           // It will change to IF1
            {`WriteMemToRd,5'bxxxxx}: next={`IF1, 1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,2'b00,3'b010, 4'b0000, `MREAD, 1'b0};

	   //State HALT, all outputs 0, regardless of input will always self loop back to HALT
	   {`HALT,5'bxxxxx}: next={`HALT, {19{1'b0}}};

         default: next={{`SW{1'bx}},{19{1'bx}}};
         endcase
end



endmodule



//the VDFF module that is used for the FSM
module vDFF2(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;

  //on the positive edge of the clk, write the output to the value that was in the input
  always @(posedge clk)
    Q <= D;
endmodule



