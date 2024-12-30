module calculadora
	#(parameter W = 32)
	(
		input clock, reset, opera,
		input [4:0] read,
		output [W-1:0] data
	);
	
	localparam L = 16;
	
	wire  [$clog2(L)-1:0] address_rom;
	wire  oe_rom;
	wire [W-1:0] data_rom;
	
	rom mem (
		.address(address_rom),
		.oe(oe_rom),
		.data(data_rom)
	);

	wire [ 3 : 0 ] ALUctl;
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

	reg [ 4 : 0 ] Read1, Read2, WriteReg;
	reg [W - 1 : 0 ] WriteData;
	reg RegWrite;
	wire [W - 1 : 0 ] Data1, Data2;

	registerfile #(W) regs (
		.Read1(Read1),
		.Read2(Read2),
		.WriteReg(WriteReg),
		.WriteData(WriteData),
		.RegWrite(RegWrite),
		.Data1(Data1),
		.Data2(Data2),
		.clock(clock)
	);
	
	reg [$clog2(L)-1:0] prog_count;

	assign address_rom = prog_count;
	assign oe_rom = 1;

	always @(posedge reset) begin
		prog_count = -1;
	end

	wire [4:0] addr_destino;
	wire [4:0] addr_A;
	wire [4:0] addr_B;

	assign addr_destino = data_rom[11:7];
	assign addr_A = data_rom[11:7];
	assign addr_B = data_rom[24:20];

	reg [3:0] alu_operation;

	assign ALUctl = alu_operation;

	always @(data_rom) begin
		if (data_rom[5]) begin
			case (data_rom[14:12])
				3'b000: begin
					if (data_rom[30])
						alu_operation = 4'b0110;
					else
						alu_operation = 4'b0010;
				end
				3'b110: 
						alu_operation = 4'b0001;
				3'b111:
						alu_operation = 4'b0000;
				3'b010:
						alu_operation = 4'b0111;
			endcase
		end else begin
			case (data_rom[14:12])
				3'b000:
					alu_operation = 4'b0010;
				3'b100:
					alu_operation = 4'b0001;
				3'b111:
					alu_operation = 4'b0000;
				3'b010:
					alu_operation = 4'b1100;
			endcase
		end
	end
	
	always @(posedge clock) begin
		if (opera) begin
			Read1 <= addr_A;
			A <= Data1;
			if (data_rom[5]) begin
				B <= data_rom[31:20];
			end else begin
				Read2 <= addr_B;
				B <= Data2;
			end
			WriteReg <= addr_destino;
			RegWrite <= 1;
			WriteData <= ALUout;
			if (!reset)
				prog_count = prog_count + 1;
		end
	end

	reg [W-1:0] data_out;
	assign data = data_out;
	
	always @(negedge clock) begin
		if (!opera) begin
			Read1 = read;
			data_out = Data1;
		end
	end

endmodule
