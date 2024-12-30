module memchip_64 (in, addr, RW, out);
	input [15:0] in;
	input [5:0] addr;
	input RW;
	output [15:0] out;
	
	//0 0 1 1 1 1 
	wire selrom;
	assign selrom = ~addr[5] & ~addr[4];
	rom_16 rom(
		.addr(addr[3:0]),
		.CS(selrom),
		.OE(selrom),
		.out(out)
	);
	
	//0 1 0 0 0 0
	//0 1 0 1 1 1
	wire selram1;
	assign selram1 = ~addr[5] & addr[4] & ~addr[3];
	ram_8 ram1(
		.in(in),
		.addr(addr[2:0]),
		.RW(RW),
		.CS(selram1),
		.OE(selram1),
		.out(out)
	);
	
	//1 0 1 0 0 0
	//1 0 1 1 1 1
	wire selram2;
	assign selram2 = addr[5] & ~addr[4] & addr[3];
	ram_8 ram2(
		.in(in),
		.addr(addr[2:0]),
		.RW(RW),
		.CS(selram2),
		.OE(selram2),
		.out(out)
	);

endmodule

module ram_8 (in, addr, RW, CS, OE, out);
	input [15:0] in;
	input [2:0] addr;
	input RW, CS, OE;
	output [15:0] out;
	
	wire [15:0] outram;

	ram_4 ram0(
		.in(in),
		.addr(addr[1:0]),
		.RW(RW),
		.CS((~addr[2] & CS)),
		.OE(~addr[2]),
		.out(outram)
	);

    ram_4 ram1(
        .in(in),
        .addr(addr[1:0]),
        .RW(RW),
        .CS((addr[2] & CS)),
		.OE(addr[2]),
        .out(outram)
    );
	
	assign out = (OE == 1'b1 & CS == 1'b1) ? outram : 16'bz;

endmodule

module ram_4 ( in , addr , RW , CS , OE , out ) ;
	input [ 15 : 0 ] in ;
	input [ 1 : 0 ] addr ;
	input RW , CS , OE ;
	output reg [ 15 : 0 ] out ;
	reg [ 15 : 0 ] data [ 3 : 0 ] ;
	always @ ( addr , CS , OE , RW )
	begin
		if (RW == 1'b0 & OE == 1'b1 & CS == 1'b1)
			out = data [ addr ] ;
		else
			out = 16'bz ;
		if (RW == 1'b1 & CS == 1'b1)
			data [ addr ] = in ;
	end
endmodule

module rom_16 ( addr , CS , OE , out ) ;
	input [ 3 : 0 ] addr ;
	input CS , OE ;
	output reg [ 15 : 0 ] out ;
	reg [ 15 : 0 ] data [ 15 : 0 ] ;
	initial
		for(integer i = 0 ; i < 16; i = i + 1)
			data[i] = ~i[15:0];
	always @ ( addr , CS , OE )
		if( OE == 1'b1 )
			out = data [ addr ] ;
		else
			out = 16'bz ;
endmodule
