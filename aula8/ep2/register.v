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
