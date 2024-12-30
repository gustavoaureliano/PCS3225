module m_enc
(
  input  clk_enc,
  input  data_in,
  output data_m
);

  assign data_m = clk_enc ^ data_in;

endmodule

module testbench;
reg clk_enc;
reg data_in;
wire data_m;

initial begin
	clk_enc = 1'b0;
	forever clk_enc = ~clk_enc #1;
end

m_enc enc (clk_enc, data_inm data_m);

endmodule
