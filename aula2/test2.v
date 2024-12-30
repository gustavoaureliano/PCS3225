module test;
	wire [15:0] out;
	wire done;

	romram3 u1 (out, done);

	initial begin
		$dumpfile ("test.vcd");
		$dumpvars(0, test);
		//$monitor("%d %d", out, done);
		#30;
	end
endmodule
