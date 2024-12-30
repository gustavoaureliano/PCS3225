module control_unit_tb;
	reg [31:0] im_data;
	reg ALUzero, ALUneg;
	wire RegWrite, ALUsrc;
	wire [1:0] PCsrc, MemWrite;
	wire [2:0] ALUctl, MemtoReg;

	control_unit control (.*);

	initial begin
		$dumpfile("control_unit_tb.vcd");
		$dumpvars(0, control_unit_tb);
		#5 im_data = 32'b00000000000000000000000000110011;
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