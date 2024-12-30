module alu
#( parameter W = 32 )
( input [ 3 : 0 ] ALUctl ,
input [W-1:0] A, B,
output [W-1:0] ALUout ,
output Overflow, Zero
) ;
reg [W-1:0]ALUout_reg;
assign ALUout = ALUout_reg;
reg Zero_reg;
assign Zero = Zero_reg;
reg Overflow_reg;
assign Overflow = Overflow_reg;
always @(*) begin
    case(ALUctl) 
        4'b0000 : ALUout_reg = A & B;
        4'b0001 : ALUout_reg = A | B;
        4'b0010 : ALUout_reg = $signed(A) + $signed(B); 
        4'b0110 : ALUout_reg = $signed(A) - $signed(B); 
        4'b0111 : ALUout_reg = $signed(A) < $signed(B);
        4'b1100 : ALUout_reg = A ~| B;
    endcase
    if (ALUout_reg == 0) Zero_reg = 1;
    else Zero_reg = 0;
    if((A[W-1]==0 && B[W-1]==0 && ALUout_reg[W-1]==1 && ALUctl==4'b0010) || (A[W-1]==1 && B[W-1]==1 && ALUout_reg[W-1]==0 && ALUctl==4'b0010) || (A[W-1]==0 && B[W-1]==1 && ALUout_reg[W-1]==1 && ALUctl==4'b0110) || (A[W-1]==1 && B[W-1]==0 && ALUout_reg[W-1]==0 && ALUctl==4'b0110)) Overflow_reg=1;
    else Overflow_reg = 0;
end 
endmodule

module registerfile
#( parameter W = 32 )
( input [ 4 : 0 ] Read1 , Read2 , WriteReg ,
input [W-1:0] WriteData ,
input RegWrite ,
output [W-1:0] Data1 , Data2 ,
input clock
) ;
reg [W-1:0] regs [31:0];
assign Data1 = (Read1 == 0 ? 0 : regs[Read1]);
assign Data2 = (Read2 == 0 ? 0 : regs[Read2]);

always @(posedge clock) begin
    if(RegWrite == 1'b1 && WriteReg!=5'b0) begin
        regs [WriteReg] = WriteData;
    end
end
endmodule


module calculadora #(
parameter W = 32
) (
input clock , reset , opera ,
input [ 4 : 0 ] read ,
output [W-1:0] data
) ;
wire RegWrite;
wire [31:0] rom_data;

wire [4:0] registrador_destino;
wire [4:0] ler_A, ler_B;
wire [W-1:0] Data1, Data2, ALUout;

wire [3:0] ALUctl;
wire [W-1:0] entrada_ula_A, entrada_ula_B;

reg [3:0] adress;
reg control;
reg finished;

rom #(.W(32),.L(16)) rom1(adress, 1'b1, rom_data);
registerfile #(.W(W)) registerfile1( ler_A, ler_B, registrador_destino, ALUout,RegWrite, Data1, Data2, clock);
alu #(.W(W)) alu1(ALUctl, entrada_ula_A, entrada_ula_B, ALUout, Overflow, Zero);

assign registrador_destino = rom_data [11:7];
assign ler_A = opera==1 ? rom_data [19:15] : read;
assign entrada_ula_A = Data1;
assign data = opera==1 ? 0 : Data1;
assign RegWrite = ~control & opera;
assign ler_B = rom_data [24:20];
assign entrada_ula_B = rom_data[5]==1 ? Data2 : $signed(rom_data [31:20]);

assign ALUctl = (rom_data[14:12] == 3'b000 & rom_data[30] == 1'b0) ? 4'b0010:
                (rom_data[14:12] == 3'b000 & rom_data[30] == 1'b1) ? 4'b0110:
                (rom_data[14:12] == 3'b110) ? 4'b0001:
                (rom_data[14:12] == 3'b111) ? 4'b0000:
                (rom_data[14:12] == 3'b010) ? 4'b0111:
                (rom_data[14:12] == 3'b000 & rom_data[5] == 1'b1) ? 4'b0010:
                (rom_data[14:12] == 3'b100) ? 4'b0001:
                ( rom_data[14:12] == 3'b111) ? 4'b0000:
                ( rom_data[14:12] == 3'b010) ? 4'b0111:
                4'b1000; 
    
    always @(posedge clock) begin 
        if(finished && adress==15) control=1;
        if(~finished && adress<16 && opera==1) begin
         adress <= adress+1;
         finished = adress==15 ? 1 : 0;
        end
    end

    always @(posedge reset) begin
        finished = 0;
        control=0;
        adress = 0;
    end
endmodule