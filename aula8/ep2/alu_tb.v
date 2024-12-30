module alu_tb #(parameter W = 11);		

	localparam AND 		= 4'b0000;
	localparam OR 		= 4'b0001;
	localparam ADD 		= 4'b0010;
	localparam SUB 		= 4'b0110;
	localparam LESSTHAN = 4'b0111;
	localparam NOR 		= 4'b1100;

	reg [ 3 : 0 ] ALUctl;
	reg [W - 1 : 0 ] A, B;
	wire [W - 1 : 0 ] ALUout;
	wire Overflow, Zero;

	alu #(W) calc (
		.ALUctl(ALUctl),
		.A(A),
		.B(B),
		.ALUout(ALUout),
		.Overflow(Overflow),
		.Zero(Zero)
	);

	initial begin
		$monitor("(%b) A: %b; B: %b; res: %b; Overflow: %b; zero: %b", ALUctl, A, B, ALUout, Overflow, Zero);
		ALUctl = OR;
		A = 1036;
		B = 3;
		//      10000000000000000000000000000000
		$finish;
	end
endmodule
