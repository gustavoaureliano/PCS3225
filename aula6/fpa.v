module fpa(ram_addr, ram_out, done);
	input [1:0] ram_addr;
	output [31:0] ram_out;
	output reg done;
	wire [1:0] ram_addr_mux;
	wire [31:0] out_rom;
	wire [31:0] ram_in;
	reg [1:0] addr_counter;
	reg [2:0] rom_addr;
	reg OE_rom, ram_OE, ram_RW;
	reg [31:0] num1;
	reg en_add;

	assign ram_addr_mux = (ram_RW ? addr_counter : ram_addr);

	reg clk = 1'b0;
	initial begin
		forever #1 clk = ~clk;
	end

	rom_8 rom(
		.addr(rom_addr),
		.OE(OE_rom),
		.out(out_rom)
	);

	ram_4 ram(
		.in(ram_in),
		.addr(ram_addr_mux),
		.RW(ram_RW),
		.OE(ram_OE),
		.out(ram_out)
	);

	adder add(
		.operand_1(num1),
		.operand_2(out_rom),
		.clk(clk),
		.en(en_add),
		.sum(ram_in)
	);
	
	integer i;
	reg sum_atual;
	initial begin
		done = 1'b0;
		OE_rom = 1'b1;
		ram_OE = 1'b1;
		ram_RW = 1'b1;
		for (i = 0; i < 4; i = i + 1) begin
			en_add = 0;
			addr_counter = i;
			rom_addr = 2*i; #1;
			num1 = out_rom; #1;
			rom_addr = 2*i+1; #1;
			en_add = 1'b1; 
			sum_atual = ram_in;
			#34;
			/*
			while (sum_atual == ram_in) begin
				#1;
			end
			*/
		end
		ram_RW = 1'b0;
		done = 1'b1;
	end
endmodule

module rom_8 (
	input [ 2 : 0 ] addr ,
	input OE ,
	output reg [ 31 : 0 ] out
	);
	reg [ 31 : 0 ] data [ 7 : 0 ] ;
	initial
	begin
		data [ 0 ] = 32'h0986ab68 ;
		data [ 1 ] = 32'h10385ba9 ;
		data [ 2 ] = 32'b00111111100000000000000000000000;
		data [ 3 ] = 32'b00111110100000000000000000000000;
		data [ 4 ] = 32'b01000000010000000000000000000000;
		data [ 5 ] = 32'b01000001001000000000000000000000;
		data [ 6 ] = 32'b00111110101000000000000000000000;
		data [ 7 ] = 32'b00111111011000000000000000000000;
	end
	always @ ( addr , OE )
		if ( OE == 1'b1 )
			out = data [ addr ] ;
		else
			out = 32'bz ;
endmodule

