module rom_tb
	#(
		parameter W = 32,
		parameter L = 16
	);
	reg  [$clog2(L)-1:0] address;
	reg  oe;
	wire [W-1:0] data;
	
	rom mem (
		.address(address),
		.oe(oe),
		.data(data)
	);

	integer i;
	initial begin
		$monitor("%h: %h", address, data);
		oe = 0;
		for (i = 0; i < L; i = i + 1) begin
			address = i;
			#1;
		end
		oe = 1;
		for (i = 0; i < L; i = i + 1) begin
			address = i;
			#1;
		end
	end
	
endmodule
