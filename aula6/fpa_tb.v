module fpa_tb;
	reg [1:0] ram_addr;
	wire [31:0] ram_out;
	wire done;

	fpa add(
		.ram_addr(ram_addr),
		.ram_out(ram_out),
		.done(done)
	);

	initial begin
        $dumpfile ("fpa_tb.vcd");
        $dumpvars(0, fpa_tb);
		while(!done) begin
			#1;
		end
		for(integer i = 0; i < 4; i = i + 1) begin
			ram_addr = i; #1;
			$display("%b", ram_out);
		end
		$finish;
	end
endmodule
