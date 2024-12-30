module rom
#(parameter L=32)
(
  input  [$clog2(L)-1:0] addr,
  input  oe,
  output [31:0] data
);

  reg [31:0] mem[L-1:0];
  
  assign data = (oe) ? mem[addr] : 32'bz;
  integer i;
  initial begin
  	mem[0] = 32'b0000000_00000_00000_000_00001_0110011; // add x1, x0, x0
  	mem[1] = 32'b000000000111_00010_000_00010_0100011; // addi x2, x0, 7
  	mem[2] = 32'b000000110010_00001_010_00011_0000011; // lw x3, 0x50(x1)
  	mem[3] = 32'b0000000_00011_00010_000_01000_1100011; // beq x3, x2, FINAL 
  	mem[4] = 32'b0000000_00001_00011_000_00100_0110011; // add x4, x3, x1
  	mem[5] = 32'b000000000001_00001_000_00001_0100011; // addi x1, x1, 1
  	mem[6] = 32'b0000000_00011_00010_001_00010_1100111; //bne x3, x2, INIT
  	mem[7] = 32'b0000001_00000_00100_010_01000_0100011; //sw x4, 0x40(x0)
	for (i = 8; i < L; i = i + 1) begin
      mem[i] = 32'h10500073; // wfi
	 end
  end
    
endmodule
