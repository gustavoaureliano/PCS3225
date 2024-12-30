module alu
	#(parameter W = 32)
	(
		input [3:0] ALUctl,
		input [W-1:0] A, B,
		output [W-1:0] ALUout,
		output Overflow, Zero
	);

	localparam AND 		= 4'b0000;
	localparam OR 		= 4'b0001;
	localparam ADD 		= 4'b0010;
	localparam SUB 		= 4'b0110;
	localparam LESSTHAN = 4'b0111;
	localparam NOR 		= 4'b1100;

	reg [W-1:0] resultado;
	reg reg_overflow;

	assign ALUout = resultado[W-1:0];
	assign Overflow = reg_overflow;
	assign Zero = (resultado == 0) ? 1'b1 : 1'b0;

	always @(ALUctl, A, B) begin
		case(ALUctl)
			AND:
					resultado = A & B;
			OR:
					resultado = A | B;
			ADD: begin
					resultado = A + B;
					if (
						(!A[W-1] && !B[W-1] && resultado[W-1]) ||
						(A[W-1] && B[W-1] && !resultado[W-1])
					)
						reg_overflow = 1'b1;
					else
						reg_overflow = 1'b0;
				end
			SUB: begin
					resultado = A - B;
					if (
						(A[W-1] && !B[W-1] && !resultado[W-1]) ||
						(!A[W-1] && B[W-1] && resultado[W-1])
					)
						reg_overflow = 1'b1;
					else
						reg_overflow = 1'b0;
				end
			LESSTHAN:
					resultado = A < B;
			NOR:
					resultado = ~(A | B);
		endcase
	end
endmodule
