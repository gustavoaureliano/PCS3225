module double_dabble(clk, rst, start, binary, done, bcd);
	parameter W = 18;
	input clk, rst, start;
	input [W - 1: 0 ] binary ;
	output done;
	output [4*$ceil(W/3.0) - 1:0] bcd;
	// Seu codigo
	wire zero;
	wire en_bcd, en_bin, en_cnt;
	wire load_bcd, load_bin, load_cnt;

	double_dabble_fd #(W) fd(
		.bin(binary),
		.clk(clk),
		.rst(rst),
		.en_bcd(en_bcd),
		.en_bin(en_bin),
		.en_cnt(en_cnt),
		.load_bcd(load_bcd),
		.load_bin(load_bin),
		.load_cnt(load_cnt),
		.zero(zero),
		.start(start),
		.out_Rbcd(bcd)
	);

	double_dabble_uc uc(
		.clk(clk),
		.rst(rst),
		.start(start),
		.zero(zero),
		.en_bcd(en_bcd),
		.en_bin(en_bin),
		.en_cnt(en_cnt),
		.load_bcd(load_bcd),
		.load_bin(load_bin),
		.load_cnt(load_cnt),
		.done(done)
	);
endmodule

module double_dabble_uc(
	input clk, rst, start, zero,
	output en_bcd, en_bin, en_cnt, load_bcd, load_bin, load_cnt,
	output done
);
	localparam [1:0] INIT  = 2'b00;
	localparam [1:0] SHIFT = 2'b01;
	localparam [1:0] SUM   = 2'b10;
	localparam [1:0] DONE  = 2'b11;

	reg [2:0] state;
	reg [2:0] next_state;	
	reg [6:0] out;

	always @(posedge clk, rst) begin
		if (rst) state = INIT;
		state <= next_state;
	end

	always @(start, state) begin
		case(state)
			INIT: if (start) next_state = SHIFT;
				  else		 next_state = INIT;
			SHIFT: if(zero)  next_state = DONE;
				   else		 next_state = SUM;
			SUM:			 next_state = SHIFT;
			DONE: if (start) next_state = DONE;
				  else		 next_state = INIT;
			default			 next_state = INIT;
		endcase
	end

	always @(state) begin
		case(state)
			INIT:	out = 7'b111_111_0;
			SHIFT:	out = 7'b110_000_0;
			SUM:	out = 7'b101_100_0;
			DONE:	out = 7'b000_000_1;
		endcase
	end
	assign {en_bcd, en_bin, en_cnt, load_bcd, load_bin, load_cnt, done} = out;
endmodule	

module double_dabble_fd
    #(parameter W = 18, N = (4*$ceil(W/3.0)))    
	(
		input [W-1:0] bin,
		input clk, rst,
		input en_bcd, en_bin, en_cnt,
		input load_bcd, load_bin, load_cnt,
		output [N-1:0] out_Rbcd,
		output [W-1:0] out_Rbin,
		output zero, start
	);
	wire msb_Rbin;
	wire [N-1:0] in_Rbcd;
	wire [$clog2(W)-1:0] out_cnt;
	wire [N-1:0] add_out;

	assign msb_Rbin = out_Rbin[W-1];
	assign in_Rbcd = ~start ? 0 : add_out;

	shiftr_reg #(N) Rbcd(
		.clk(clk),
		.rst(rst),
		.en(en_bcd),
		.load(load_bcd),
		.si(msb_Rbin),
		.d(in_Rbcd),
		.q(out_Rbcd)
	);

	shiftr_reg #(W) Rbin(
		.clk(clk),
		.rst(rst),
		.en(en_bin),
		.load(load_bin),
		.si(1'b0),
		.d(bin),
		.q(out_Rbin)
	);

	counter_dec #($clog2(W)) counter(
		.clk(clk),
		.rst(rst),
		.en(en_cnt),
		.ld(load_cnt),
		.d(W-1),
		.q(out_cnt),
		.z(zero)
	);

	genvar gen;
	generate
		for (gen = 0; gen < N; gen = gen + 4) begin
			add3or0 add(
				.bcd_i(out_Rbcd[gen + 3:gen]),
				.bcd_o(add_out[gen + 3:gen])
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

module counter_dec
    #(parameter WIDTH=3)
    (
        input  clk, rst, en, ld,
        input  [WIDTH-1:0] d,
        output [WIDTH-1:0] q,
        output z
    );

    reg [WIDTH-1:0] cnt;

    always @ (posedge clk)
    begin
        if (rst)
            cnt=0;
        else if (en)
            if (ld)
                cnt = d;
            else 
                cnt = cnt-1;
    end 

    assign q = cnt;
    assign z = cnt==0 ? 1'b1 : 1'b0;

endmodule

module shiftr_reg
    #(parameter WIDTH=8)
    (
        input  clk, rst, en, load, si, 
        input  [WIDTH-1:0] d, 
        output [WIDTH-1:0] q);
	reg [WIDTH-1:0] sreg;
	always @(posedge clk or posedge rst)
	begin
		if (rst)
			sreg = 0;        
		else if (en)
			if (load) 
				sreg = d;
			else 
				sreg = (sreg << 1) + si;
	end
	assign q = sreg;
endmodule
