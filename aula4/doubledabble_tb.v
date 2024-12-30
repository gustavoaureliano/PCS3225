module doubledabble_tb #(parameter W=8);
	reg clk, rst, start;
	reg [W - 1:0] numBin;
	wire done;
	wire [W - 1:0] binary;
	wire [4*$ceil(W/3.0) - 1:0] bcd;

	double_dabble #(W) u1(
		.clk(clk),
		.rst(rst),
		.start(start),
		.binary(binary),
		.done(done),
		.bcd(bcd)
	);
	assign binary = numBin;
	
	integer i;
	initial begin
        $dumpfile ("doubledabble_tb.vcd");
        $dumpvars(0, doubledabble_tb);
		rst = 1;
		numBin = 0;
		start = 0;
		#1
		rst = 0;
		#1
		for (i = 42; i < 50; i = i + 1) begin
			numBin =i;
			start = 1'b0;
			//rst = 1'b0;
			#4;
			//rst = 0;
			start = 1;
			#1
			while (!done) begin
				#5;
			end
			start = 1'b0;
			#1;
		end
		$finish;
	end

    // generate the clock
    initial begin
        clk = 1'b0;
	    forever #1 clk = ~clk;
    end
endmodule
