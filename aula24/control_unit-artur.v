module control_unit
(
  input [31:0] im_data,
  input ALUzero, ALUneg,
  output reg RegWrite, ALUsrc,
  output reg [1:0] PCsrc, MemWrite,
  output reg [2:0] ALUctl, MemtoReg
);
  
  // ALU operation codes
  localparam
    op_add  = 3'd0,
    op_and  = 3'd1,
    op_or   = 3'd2,
    op_sl   = 3'd3,
    op_sra  = 3'd4,
    op_srl  = 3'd5,
    op_sub  = 3'd6,
    op_xor  = 3'd7;
  
  // Partition instruction
  wire [6:0] opcode = im_data[ 6: 0];
  wire [2:0] funct3 = im_data[14:12];
  wire [6:0] funct7 = im_data[31:25];

  // Define ALUsrc (1 bit)
  always @(*) begin
    if (opcode == 7'b0110011 || opcode == 7'b1100011) 
      ALUsrc <= 1'b0; 
    else if (opcode == 7'b0010011 || opcode == 7'b0000011 || opcode==7'b0100011) 
      ALUsrc <= 1'b1; 
    else 
      ALUsrc <= 1'bx; // Default case to avoid latches
  end

  // Define RegWrite (1 bit)
  always @(*) begin
    if (opcode == 7'b0110011 || opcode == 7'b0010011 || opcode == 7'b0000011 || 
        opcode == 7'b0110111 || opcode == 7'b0010111 || opcode == 7'b1101111 || 
        opcode == 7'b1100111) 
      RegWrite <= 1'b1;
    else 
      RegWrite <= 1'b0;
  end

  // Define MemWrite (2 bits)
  always @(*) begin
    if (opcode == 7'b0100011) begin
      if (funct3 == 3'b000) 
        MemWrite <= 2'b01; // SB
      else if (funct3 == 3'b001) 
        MemWrite <= 2'b10; // SH
      else if (funct3 == 3'b010) 
        MemWrite <= 2'b11; // SW
      else 
        MemWrite <= 2'b00; 
    end else 
      MemWrite <= 2'b00;
  end

  // Define PCsrc (2 bits)
  always @(*) begin
    if (opcode == 7'b1100111) 
      PCsrc <= 2'b10; // JALR  
    else if (opcode == 7'b1101111) 
      PCsrc <= 2'b01; // JAL
    else if(opcode == 7'b1100011) begin //branch
      if(funct3==3'b000 && ALUzero) PCsrc <= 2'b01; //beq
      else if(funct3==3'b001 && !ALUzero) PCsrc <= 2'b01; //bne
      else if(funct3==3'b101 && !ALUneg) PCsrc <= 2'b01; //bge
      else if(funct3==3'b100 && ALUneg) PCsrc <= 2'b01;
      else PCsrc <= 2'b00;
    end
    else 
      PCsrc <= 2'b00;
  end

  // Define MemtoReg (3 bits)
  always @(*) begin
    if (opcode == 7'b0110011 || opcode == 7'b0010011) 
      MemtoReg <= 3'b000; // ADD, SUB, AND, ADDI, ANDI ... <--- ALU
    else if (opcode == 7'b0000011) begin
      if (funct3 == 3'b000) 
        MemtoReg <= 3'b100;  // LB  
      else if (funct3 == 3'b010) 
        MemtoReg <= 3'b110;  // LW
      else if (funct3 == 3'b001) 
        MemtoReg <= 3'b101; // LH 
      else 
        MemtoReg <= 3'b000; // Default case to avoid latches
    end else if (opcode == 7'b0110111) 
      MemtoReg <= 3'b010; // LUI
    else if (opcode == 7'b0010111) 
      MemtoReg <= 3'b011; // AUIPC
    else if (opcode == 7'b1101111 || opcode == 7'b1100111) 
      MemtoReg <= 3'b001; // JAL, JALR
    else 
      MemtoReg <= 3'b000; // Default case to avoid latches
  end

  // Define ALUctl (3 bits)
  always @(*) begin
    if(opcode == 7'b1100011) begin
      ALUctl <= op_sub;
    end
    else if (opcode == 7'b0110011) begin // R-type instructions
      if (funct3 == 3'b000) begin
        if (funct7 == 7'b0000000) 
          ALUctl <= op_add;
        else if (funct7 == 7'b0100000) 
          ALUctl <= op_sub;
        else 
          ALUctl <= 3'bxxx; // Default case to avoid latches
      end else if (funct3 == 3'b111) 
        ALUctl <= op_and;
      else if (funct3 == 3'b110) 
        ALUctl <= op_or;
      else if (funct3 == 3'b001) 
        ALUctl <= op_sl;
      else if (funct3 == 3'b101) begin
        if (funct7 == 7'b0000000) 
          ALUctl <= op_srl;
        else if (funct7 == 7'b0100000) 
          ALUctl <= op_sra;
        else 
          ALUctl <= 3'bxxx; // Default case to avoid latches
      end 
      else if (funct3 == 3'b100) 
        ALUctl <= op_xor;
      else 
        ALUctl <= 3'bxxx; // Default case to avoid latches
    end
     else if(opcode==7'b0000011) ALUctl <= op_add;
     else if(opcode==7'b0100011) ALUctl <= op_add;
     else if (opcode == 7'b0010011) begin // I-type instructions
      if (funct3 == 3'b000) 
        ALUctl <= op_add;
      else if (funct3 == 3'b111) 
        ALUctl <= op_and;
      else if (funct3 == 3'b110) 
        ALUctl <= op_or;
      else if (funct3 == 3'b001) 
        ALUctl <= op_sl;
      else if (funct3 == 3'b101) begin
        if (funct7 == 7'b0000000) 
          ALUctl <= op_srl;
        else if (funct7 == 7'b0100000) 
          ALUctl <= op_sra;
        else 
          ALUctl <= 3'bxxx; // Default case to avoid latches
      end
       else if (funct3 == 3'b100) 
        ALUctl <= op_xor;
      else 
        ALUctl <= 3'bxxx; // Default case to avoid latches
    end else 
      ALUctl <= 3'bxxx; // Default case to avoid latches
  end

  // EBREAK return signal
  wire brk = (im_data[6:0] == 7'b1110011) ? 1 : 0;

endmodule