module calculadora_tb #(parameter W = 32);

	reg clock, reset, opera;
	reg [4:0] read;
	output [W-1:0] data;

	calculadora #(32) calc (
		.clock(clock),
		.reset(reset),
		.opera(opera),
		.read(read),
		.data(data)
	);

	initial begin
		clock = 1'b0;
		forever #1 clock = ~clock;
	end

	initial begin
		$dumpfile ("calculadora_tb.vcd");
		$dumpvars(0, calculadora_tb);
		opera = 1;
		reset = 1'b0;
		#2;
		reset = 1'b1;
		#3;
		reset = 1'b0;
		#200;
		$finish;
	end

endmodule
