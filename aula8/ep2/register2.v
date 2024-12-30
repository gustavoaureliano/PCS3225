module registerfile
	#( parameter W = 32)
	(
		input [4:0] Read1, Read2, WriteReg,
		input [W-1:0] WriteData,
		input RegWrite,
		output [W-1:0] Data1, Data2,
		input clock
	);

	reg [W-1:0] registers [31:0];
	reg [W-1:0] regData1, regData2;

	assign Data1 = registers[Read1];
	assign Data2 = registers[Read2];

	integer i;
	initial begin
		for (i = 0; i < W; i = i + 1) begin
			registers[i] = i+1;
		end
	end

	always @(posedge clock) begin
		if (RegWrite) begin
			registers[WriteReg] <= WriteData;
		end
	end
endmodule
