module calculadora
	#(parameter W = 32)
	(
		input clock, reset, opera,
		input [4:0] read,
		output [W-1:0] data
	);
	
	wire [3:0] address_rom;
	wire oe_rom;
	wire [31:0] data_rom;
	
	rom #(.W(32), .L(16)) mem (
		address_rom,
		oe_rom,
		data_rom
	);

	wire [3:0] ALUctl;
	wire [W-1:0] A, B;
	wire [W-1:0] ALUout;
	wire Overflow, Zero;

	alu #(.W(W)) calc (
		ALUctl,
		A,
		B,
		ALUout,
		Overflow,
		Zero
	);

	wire [4:0] Read1, Read2, WriteReg;
	wire [W-1:0] WriteData;
	wire RegWrite;
	wire [W-1:0] Data1, Data2;

	registerfile #(.W(W)) regs (
		Read1,
		Read2,
		WriteReg,
		WriteData,
		RegWrite,
		Data1,
		Data2,
		clock
	);

	reg [3:0] prog_count;
	
	assign address_rom = prog_count;
	assign oe_rom = 1;

	always @(posedge reset) begin
		prog_count <= -1;
	end

	assign WriteReg = data_rom[11:7];
	assign WriteData = ALUout;
	assign Read1 = opera ? data_rom[19:15] : read;
	assign Read2 = data_rom[24:20];
	assign RegWrite = opera;

	assign data = !opera ? Data1 : 'bz;

	assign A = Data1;
	assign B = !data_rom[5] ? data_rom[31:20] : Data2;

	reg [3:0] alu_operation;

	assign ALUctl = alu_operation;

	always @(data_rom) begin
		if (data_rom[5]) begin
			case (data_rom[14:12])
				3'b000: begin
					if (data_rom[30])
						alu_operation <= 4'b0110;
					else
						alu_operation <= 4'b0010;
				end
				3'b110: 
						alu_operation <= 4'b0001;
				3'b111:
						alu_operation <= 4'b0000;
				3'b010:
						alu_operation <= 4'b0111;
			endcase
		end else begin
			case (data_rom[14:12])
				3'b000:
					alu_operation <= 4'b0010;
				3'b110:
					alu_operation <= 4'b0001;
				3'b111:
					alu_operation <= 4'b0000;
				3'b010:
					alu_operation <= 4'b0111;
			endcase
		end
	end
	
	always @(posedge opera) begin
		prog_count <= prog_count + 1;
	end

endmodule

module registerfile
	#( parameter W = 32)
	(
		input [ 4 : 0 ] Read1, Read2, WriteReg,
		input [W - 1 : 0 ] WriteData,
		input RegWrite,
		output [W - 1 : 0 ] Data1, Data2,
		input clock
	);

	reg [W-1:0] registers [31:0];
	reg [W-1:0] regData1, regData2;

	assign Data1 = Read1 == 0 ? 0 : registers[Read1];
	assign Data2 = Read2 == 0 ? 0 : registers[Read2];

	always @(posedge clock) begin
		if (RegWrite && !(WriteReg == 0)) begin
			registers[WriteReg] <= WriteData;
		end
	end
endmodule

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
					resultado = $signed(A) + $signed(B);
					if (
						(!A[W-1] && !B[W-1] && resultado[W-1]) ||
						(A[W-1] && B[W-1] && !resultado[W-1])
					)
						reg_overflow = 1'b1;
					else
						reg_overflow = 1'b0;
				end
			SUB: begin
					resultado = $signed(A) - $signed(B);
					if (
						(A[W-1] && !B[W-1] && !resultado[W-1]) ||
						(!A[W-1] && B[W-1] && resultado[W-1])
					)
						reg_overflow = 1'b1;
					else
						reg_overflow = 1'b0;
				end
			LESSTHAN:
					resultado = $signed(A) < $signed(B);
			NOR:
					resultado = ~(A | B);
		endcase
	end
endmodule
