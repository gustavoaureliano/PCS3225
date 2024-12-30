module ram74
  #(parameter L=16)
(
  input  [$clog2(L)-1:0] addr,
  input  [6:0] data_in,
  input  clk, rw, oe,
  output [6:0] data_out
);
  reg [6:0] mem[L-1:0], data_buff;
  reg [2:0] err;

  always@(posedge clk) begin
    err = $urandom_range(7, 0);

    // Write
    if(rw===1'b1) begin
      mem[addr] = data_in;
    end

    // Read (with upto 1-bit error)
    else begin
      data_buff = mem[addr];
      if (err != 3'b111) data_buff[err] = ~data_buff[err];
    end
  end

  assign data_out = (oe===1'b1) ? (data_buff) : {7'bz};
  
endmodule