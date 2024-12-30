module double_dabble(clk, rst, start, binary, done, bcd);
	parameter W = 18;
	input clk, rst, start;
	input [W - 1: 0 ] binary ;
	output done;
	output [4*$ceil(W/3.0) - 1:0] bcd;
	// Seu codigo
	localparam [1:0] INIT  = 2'b00;
	localparam [1:0] SHIFT = 2'b01;
	localparam [1:0] SUM   = 2'b10;
	localparam [1:0] DONE  = 2'b11;

	reg [W - 1: 0 ] bin_reg ;
	reg [4*$ceil(W/3.0) - 1:0] bcd_reg;
	wire [4*$ceil(W/3.0) - 1:0] bcd_reg_sum;
	reg [$clog2(W)-1:0] count;

	assign bcd = bcd_reg;
	assign done = state == DONE;

	reg [2:0] state;
	reg [4:0] out;

	always @(posedge clk) begin
		if (rst) state = 0;
	end

	always @(state, posedge clk) begin
		case(state)
			INIT:
				begin
					bcd_reg = 0;
					bin_reg = binary;
					count = W-1;
					if (start)	   state = SHIFT;
					else		   state = INIT;
				end
			SHIFT:
				begin
					bcd_reg = (bcd_reg << 1) + bin_reg[W-1];
					bin_reg = bin_reg << 1;
					if (count <= 0) state = DONE;
					else begin
					   	count = count - 1;
						state = SUM;
					end
				end
			SUM:
				begin
					bcd_reg = bcd_reg_sum;
				  	state = SHIFT;
				end
			DONE:
				begin
					if (start)	   state = DONE;
					else			 state = INIT;
				end
			default				  state = INIT;
		endcase
	end

	genvar gen;
	generate
		for (gen = 0; gen < 4*$ceil(W/3.0); gen = gen + 4) begin
			add3or0 add(
				.bcd_i(bcd_reg[gen + 3:gen]),
				.bcd_o(bcd_reg_sum[gen + 3:gen])
			);
		end
	endgenerate
endmodule

module add3or0(bcd_i, bcd_o);
	input [3:0] bcd_i;
	output [3:0] bcd_o;
	assign bcd_o = (bcd_i < 5) ? bcd_i
							   : bcd_i + 4'b0011;
endmodule
