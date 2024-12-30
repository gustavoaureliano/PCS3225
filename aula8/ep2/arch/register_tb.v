module register_tb #(parameter W = 32);		

	reg clock;
	reg [ 4 : 0 ] Read1, Read2, WriteReg;
	reg [W - 1 : 0 ] WriteData;
	reg RegWrite;
	wire [W - 1 : 0 ] Data1, Data2;

	initial begin
		clock = 1'b0;
		forever #1 clock = ~clock;
	end

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

	integer i;

	initial begin
		$monitor("%h: %d; %h: %d;", Read1, Data1, Read2, Data2);

		/*
		RegWrite = 1'b1;
		for (i = 0; i < W; i = i + 1) begin
			WriteReg = i;
			WriteData = 10;
			#2;
		end
		RegWrite = 1'b0;
		
		WriteReg = 'h1f;
		WriteData = 4294967295;
		RegWrite = 1'b1;
		$display("(%b) %h: %d", RegWrite, WriteReg, WriteData);
		#2;
		RegWrite = 1'b0;
		*/

		for (i = 0; i < W; i = i + 2) begin
			Read1 = i;
			Read2 = i+1;
			#1;
		end

		$finish;
	end
endmodule
