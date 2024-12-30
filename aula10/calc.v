module calc(
  input  [3:0]  ram_addr_juiz,
  input         clk,
  output [31:0] ram_out_juiz,
  output reg    done
);
  reg [3:0]  ram_addr;
  reg [31:0] ram_in;
  reg        ram_rw;

  wire [3:0] ram_addr_mux;
  assign ram_addr_mux = (ram_rw ? ram_addr : ram_addr_juiz);

  ram #(.W (32), .L (16)) mem
  (
    .addr     (ram_addr_mux),
    .data_in  (ram_in),
    .rw       (ram_rw),
    .oe       (1'b1),
    .data_out (ram_out_juiz)
  );

  initial
  begin
    done = 0;
    ram_rw = 1;
    ram_addr = 3'h00;
  end

  always@(posedge clk)
  begin
    if (done !== 1)
    begin
      if (ram_addr == 3'h01)
        ram_in = 32'haaaaaaaa;

        // continue o preenchimento da RAM aqui. 
      if (ram_addr == 4'hF) begin
        ram_in = 32'h10b02823;
        done = 1;
      end
      if (ram_addr != 4'hF)
          ram_addr = ram_addr + 1;
    end
    else
      ram_rw = 0;
  end
endmodule
