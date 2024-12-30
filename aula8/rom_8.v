module rom_8(
  input [2:0] addr,
  input OE,
  output reg [31:0] out
);
  reg [31:0] data[7:0];
  initial
  begin
	data [ 0 ] = 32'h15350076 ;
	data [ 1 ] = 32'h5952599F ;
	data [ 2 ] = 32'b00111111100000000000000000000000;
	data [ 3 ] = 32'b00111110100000000000000000000000;
	data [ 4 ] = 32'b01000000010000000000000000000000;
	data [ 5 ] = 32'b01000001001000000000000000000000;
	data [ 6 ] = 32'b00111110101000000000000000000000;
	data [ 7 ] = 32'b00111111011000000000000000000000;
  end
  always @(addr, OE)
    if (OE==1'b1)
      out=data[addr];
    else
      out=32'bz;
endmodule
