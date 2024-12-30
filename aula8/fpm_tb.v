module fpm_tb;
	reg [1:0] ram_addr_juiz;
	wire [31:0] ram_out_juiz;
	wire done;

	fpm add(
		.ram_addr_juiz(ram_addr_juiz),
		.ram_out_juiz(ram_out_juiz),
		.done(done)
	);

	initial begin
        $dumpfile ("fpm_tb.vcd");
        $dumpvars(0, fpm_tb);
		while(!done) begin
			#1;
		end
		for(integer i = 0; i < 4; i = i + 1) begin
			ram_addr_juiz = i; #1;
			$display("%h", ram_out_juiz);
		end
		$finish;
	end
endmodule
