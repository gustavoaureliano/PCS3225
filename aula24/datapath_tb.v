module datapath_tb;
	parameter W = 32,
	 IM_L = 16,
	 DM_L = 64;
	reg  clk, rst, run;

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	initial begin
		rst = 0;
		#5;
		rst = 1;
		#5;
		rst = 0;
		#5;
	end

	// Control Unit I/O
	reg RegWrite;
	wire ALUsrc;
	reg [1:0] PCsrc;
	reg [2:0] MemtoReg;
	wire [2:0] ALUctl;
	wire ALUzero, ALUneg;

	// Instruction Memory I/O
	reg  [31:0] im_data;
	wire [$clog2(IM_L*4)-1:0] im_addr;

	// Data Memory I/O
	reg  [W-1:0] dm_data_out;
	wire [W-1:0] dm_data_in;
	wire [$clog2(DM_L*(W/8))-1:0] dm_addr;

	assign ALUsrc = 1'b1;
	assign ALUctl = 3'b110;

	datapath fd (.*);

	initial begin
		$dumpfile("datapath_tb.vcd");
		$dumpvars(0, datapath_tb);
		#5 im_data = 32'b00000000000000000000000000110011; // add
		#5 im_data = 32'b00000000000000000000000000010011; // addi
		#5 im_data = 32'b01000000000000000000000000110011; // sub
		#5 im_data = 32'b00000000000000000111000000110011; // and
		#5 im_data = 32'b00000000000000000111000000010011; // andi
		#5 im_data = 32'b00000000000000000110000000110011; // or
		#5 im_data = 32'b00000000000000000110000000010011; // ori
		#5 im_data = 32'b00000000000000000100000000110011; // xor
		#5 im_data = 32'b00000000000000000100000000010011; // xori
		#5 im_data = 32'b00000000000000000001000000110011; // sll
		#5 im_data = 32'b00000000000000000001000000010011; // slli
		#5 im_data = 32'b00000000000000000101000000110011; // srl
		#5 im_data = 32'b00000000000000000101000000010011; // srli
		#5 im_data = 32'b01000000000000000101000000110011; // sra
		#5 im_data = 32'b01000000000000000101000000010011; // srai
		#5 im_data = 32'b00000000000000000010000000110011; // slt
		#5 im_data = 32'b00000000000000000010000000010011; // slti
		#5 im_data = 32'b00000000000000000010000000000011; // LW
		#5 im_data = 32'b00000000000000000001000000000011; // lH
		#5 im_data = 32'b00000000000000000000000000000011; // lb
		#5 im_data = 32'b00000000000000000000000000100011; // sb
		#5 im_data = 32'b00000000000000000001000000100011; // sh
		#5 im_data = 32'b00000000000000000010000000100011; // sw
		#5 im_data = 32'b00000000000000000000000001100011; // beq
		#5 im_data = 32'b00000000000000000001000001100011; // bne
		#5 im_data = 32'b00000000000000000101000001100011; // bge
		#5 im_data = 32'b00000000000000000100000001100011; // blt
		#5 im_data = 32'b00000000000000000000000000110111; // lui
		#5 im_data = 32'b00000000000000000000000000010111; // auipc
		#5 im_data = 32'b00000000000000000000000001101111; // jal
		#5 im_data = 32'b00000000000000000000000001100111; // jalr
		#5 im_data = 32'b00000000000100000000000001110011; // ebreak
		$finish;
		
	end
endmodule
