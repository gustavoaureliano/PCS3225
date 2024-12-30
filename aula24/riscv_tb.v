module control_unit_tb;
	parameter W = 32, IM_L = 16, DM_L = 64;

	reg  clk, rst, run;
	// Instruction Memory
	reg [31:0] im_data;
	wire [$clog2(IM_L*4)-1:0] im_addr;
	/*
	rom #(IM_L) instructionMem(
		.addr (im_addr),
		.oe   (1'b1),
		.data (im_data)
	);
	*/

	// Data Memory
	wire [1:0] MemWrite;
	wire [W-1:0] dm_data_in, dm_data_out;
	wire [$clog2(DM_L*(W/8))-1:0] dm_addr;
	ram #(W, DM_L) dataMem(
		.addr     (dm_addr),
		.data_in  (dm_data_in),
		.clk      (clk),
		.oe       (1'b1),
		.w_mode   (MemWrite),
		.data_out (dm_data_out)
	);

	// Control Unit and Datapath
	wire RegWrite, ALUsrc, ALUzero, ALUneg;
	wire [1:0] PCsrc;
	wire [2:0] ALUctl, MemtoReg;
	control_unit control(.*);
	datapath #(W, IM_L, DM_L) dp(.*);

	initial begin
		clk = 0;
		forever #1 clk = ~clk;
	end

	initial begin
		run = 1;
		rst = 0;
		#1;
		rst = 1;
		#1;
		rst = 0;
		#1;
	end

	initial begin
		$dumpfile("control_unit_tb.vcd");
		$dumpvars(0, control_unit_tb);
		#1 im_data = 32'b00000000000000000000000000110011; // add
		#1 im_data = 32'b00000000000000000000000000010011; // addi
		#1 im_data = 32'b00000000001100000000000110010011; // addi x3 x0 3
		#1 im_data = 32'b00000000001000000000000100010011; // addi x2 x0 2
		#1 im_data = 32'b01000000000000000000000000110011; // sub
		#1 im_data = 32'b00000000000000000111000000110011; // and
		#1 im_data = 32'b00000000000000000111000000010011; // andi
		#1 im_data = 32'b00000000000000000110000000110011; // or
		#1 im_data = 32'b00000000000000000110000000010011; // ori
		#1 im_data = 32'b00000000000000000100000000110011; // xor
		#1 im_data = 32'b00000000000000000100000000010011; // xori
		#1 im_data = 32'b00000000000000000001000000110011; // sll
		#1 im_data = 32'b00000000000000000001000000010011; // slli
		#1 im_data = 32'b00000000000000000101000000110011; // srl
		#1 im_data = 32'b00000000000000000101000000010011; // srli
		#1 im_data = 32'b01000000000000000101000000110011; // sra
		#1 im_data = 32'b01000000000000000101000000010011; // srai
		#1 im_data = 32'b00000000000000000010000000110011; // slt
		#1 im_data = 32'b00000000001000011010001000110011; // slt x4, x3, x2 
		#1 im_data = 32'b00000000001100010010001000110011; // slt x4, x2, x3 
		#1 im_data = 32'b00000000000000000010000000010011; // slti
		#1 im_data = 32'b00000000001100010010001010010011; // slti x5, x2, 3
		#1 im_data = 32'b00000000000000000010000000000011; // LW
		#1 im_data = 32'b00000000000000000001000000000011; // lH
		#1 im_data = 32'b00000000000000000000000000000011; // lb
		#1 im_data = 32'b00000000000000000000000000100011; // sb
		#1 im_data = 32'b00000000000000000001000000100011; // sh
		#1 im_data = 32'b00000000000000000010000000100011; // sw
		#1 im_data = 32'b00000000000000000000000001100011; // beq
		#1 im_data = 32'b00000000000000000001000001100011; // bne
		#1 im_data = 32'b00000000000000000101000001100011; // bge
		#1 im_data = 32'b00000000000000000100000001100011; // blt
		#1 im_data = 32'b00000000000000000000000000110111; // lui
		#1 im_data = 32'b00000000000000000000000000010111; // auipc
		#1 im_data = 32'b00000000000000000000000001101111; // jal
		#1 im_data = 32'b00000000000000000000000001100111; // jalr
		#1 im_data = 32'b00000000000100000000000001110011; // ebreak
		$finish;
		
	end
endmodule
