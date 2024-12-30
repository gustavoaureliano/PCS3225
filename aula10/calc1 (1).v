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
    ram_addr = 4'h0;
  end

  always@(posedge clk)
    begin
        if (done !== 1)
        begin
        if (ram_addr == 4'h0)
            ram_in = 32'b11111111111111111111111110001101;
        if (ram_addr == 4'h1)
            ram_in = 32'b00000000000000000000000000100001;
        if (ram_addr == 4'h2)
            ram_in = 32'b00000000000000000000000000111010;
        if (ram_addr == 4'h3)
            ram_in = 32'b00000000000000000000000000101111;
        if (ram_addr == 4'h4)
            ram_in = 32'b00000000000000000000000010011111;
        if (ram_addr == 4'h8)
            ram_in = 32'b00000000000100000010001010000011;       
        if (ram_addr == 4'h9)
            ram_in = 32'b00000000001000000010001100000011;
        if (ram_addr == 4'hA)
            ram_in = 32'b00000000001100000010001110000011;
        if (ram_addr == 4'hB)
            ram_in = 32'b00000000010000000010010000000011;
        if (ram_addr == 4'hC)
            ram_in = 32'b00000000011000101000010010110011;
        if (ram_addr == 4'hD)
            ram_in = 32'b00000000100000111000010100110011;
        if (ram_addr == 4'hE)
            ram_in = 32'b01000000101001001000010110110011;
        if (ram_addr == 4'hF) begin
            ram_in = 32'b00000000101100000010000000100011;
            done = 1;
        end
        if (ram_addr != 4'hF)
            ram_addr = ram_addr + 1;
        end
        else
        ram_rw = 0;
    end
    
endmodule
