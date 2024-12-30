// Judge will use Verilo 2012 (iverilog -g 2012)
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

  // instruction operation codes
  localparam
    op_no_imm 	= 7'b0110011, // fmt R
    op_imm 		= 7'b0010011, // fmt I
	op_ld 		= 7'b0000011, // fmt I
    op_st 		= 7'b0100011, // fmt S
    op_branch 	= 7'b1100011, // fmt SB
	op_lui 		= 7'b0110111, // fmt U
	op_auipc 	= 7'b0010111, // fmt U
	op_jal		= 7'b1101111, // fmt UJ
	op_jalr 	= 7'b1100111; // fmt UJ

  localparam
 	funct3_add_sub 	= 3'b000,
	funct3_and 		= 3'b111,
	funct3_or 		= 3'b110,
	funct3_sl 		= 3'b001,
	funct3_sr 		= 3'b101,
	funct3_xor 		= 3'b100,
	funct3_lb 		= 3'b000,
	funct3_lh 		= 3'b001,
	funct3_lw 		= 3'b010,
	funct3_sb 		= 3'b000,
	funct3_sh 		= 3'b001,
	funct3_sw 		= 3'b010,
	funct3_beq 		= 3'b000,
	funct3_bne 		= 3'b001,
	funct3_bge 		= 3'b101,
	funct3_blt 		= 3'b100,
	funct3_slt_slti	= 3'b010;

  localparam
 	funct7_add 		= 7'b0000000,
 	funct7_sub 		= 7'b0100000,
	funct7_and 		= 7'b0000000,
	funct7_or 		= 7'b0000000,
	funct7_sl 		= 7'b0000000,
	funct7_sra 		= 7'b0100000,
	funct7_srl 		= 7'b0000000,
	funct7_xor 		= 7'b0000000,
	funct7_slt 		= 7'b0000000;

  //store word types
  localparam
  	st_no_word 		= 2'd0,
	st_byte 		= 2'd1,
	st_half_word 	= 2'd2,
	st_word 		= 2'd3;

  //PCsrc
  localparam
	pc_next 	= 2'd0,
	pc_imm 		= 2'd1,
	pc_link_reg = 2'd2;

  //MemtoReg
  localparam
  	reg_data_alu 		= 3'd0,
  	reg_data_jmp_link 	= 3'd1,
  	reg_data_up_imm 	= 3'd2,
  	reg_data_up_imm_pc 	= 3'd3,
  	reg_data_byte 		= 3'd4,
  	reg_data_half_word 	= 3'd5,
  	reg_data_word 		= 3'd6,
  	reg_data_slt 		= 3'd7;

  // Define ALUsrc (1 bit) --
  // 0: register
  // 1: immediate

  always@*
	  case(opcode)
		(op_no_imm): begin
			ALUsrc <= 1'b0;
		end
		(op_imm): begin
			ALUsrc <= 1'b1;
		end
		(op_ld): begin
			ALUsrc <= 1'b1;
		end
		(op_st): begin
			ALUsrc <= 1'b1;
		end
		(op_branch): begin
			ALUsrc <= 1'b0;
		end
		(op_jalr): begin
			ALUsrc <= 1'b1;
		end
		default: begin
			ALUsrc <= 1'b0;
		end
	  endcase

  // Define RegWrite (1 bit) --
  // 0: no write
  // 1: write

  always@*
	  case(opcode)
		(op_no_imm): begin
			RegWrite <= 1'b1;
		end
		(op_imm): begin
			RegWrite <= 1'b1;
		end
		(op_ld): begin
			RegWrite <= 1'b1;
		end
		(op_st): begin
			RegWrite <= 1'b0;
		end
		(op_branch): begin
			RegWrite <= 1'b0;
		end
		(op_lui): begin
			RegWrite <= 1'b1;
		end
		(op_auipc): begin
			RegWrite <= 1'b1;
		end
		(op_jal): begin
			RegWrite <= 1'b1;
		end
		(op_jalr): begin
			RegWrite <= 1'b1;
		end
		default: begin
			RegWrite <= 1'b0;
		end
	  endcase

  // Define MemWrite (2 bit) --
  // 00: no write (read)
  // 01: write 8 bits / 1 byte
  // 10: write 16 bits / 2 bytes
  // 11: write 32 bits / 4 bytes

  always@*
	  case(opcode)
		(op_st): begin
			case(funct3)
				(funct3_sb): begin
					MemWrite <= st_byte;
				end
				(funct3_sh): begin
					MemWrite <= st_half_word;
				end
				(funct3_sw): begin
					MemWrite <= st_word;
				end
			endcase
		end
		default: begin
			MemWrite <= st_no_word;
		end
	  endcase

  // Define PCsrc (2 bits) ***
  // 00: to next byte (PC+4)
  // 01: to immediate (branch)
  // 10: to reg + imm (jalr)

  always@*
	  case(opcode)
		(op_branch): begin
			case(funct3)
				(funct3_beq): begin
					if(ALUzero)
						PCsrc <= pc_imm;
					else
						PCsrc <= pc_next;
				end
				(funct3_bne): begin
					if(~ALUzero)
						PCsrc <= pc_imm;
					else
						PCsrc <= pc_next;
				end
				(funct3_bge): begin
					if(~ALUneg)
						PCsrc <= pc_imm;
					else
						PCsrc <= pc_next;
				end
				(funct3_blt): begin
					if(ALUneg)
						PCsrc <= pc_imm;
					else
						PCsrc <= pc_next;
				end
			endcase
		end
		(op_jal): begin
			PCsrc <= pc_imm;
		end
		(op_jalr): begin
			PCsrc <= pc_link_reg;
		end
		default: begin
			PCsrc <= pc_next;
		end
	  endcase

  // Define MemtoReg (3 bits) (reg write data source)
  // 000: from alu
  // 001: Jump & link / Jump & link register
  // 010: load upper immediate
  // 011: add upper immediate to pc
  // 100: load byte (8bits/1byte)
  // 101: load half word (16bits/2bytes)
  // 110: load word (32bits/4bytes)
  // 111: set if less than / set if less than immediate

  always@*
	  case(opcode)
		(op_ld): begin
			case(funct3)
				(funct3_lb): begin
					MemtoReg <= reg_data_byte;
				end
				(funct3_lh): begin
					MemtoReg <= reg_data_half_word;
				end
				(funct3_lw): begin
					MemtoReg <= reg_data_word;
				end
			endcase
		end
		(op_lui): begin
			MemtoReg <= reg_data_up_imm;
		end
		(op_auipc): begin
			MemtoReg <= reg_data_up_imm_pc;
		end
		op_jal, op_jalr: begin
			MemtoReg <= reg_data_jmp_link;
		end
		op_imm, op_no_imm: begin
			case(funct3)
				funct3_slt_slti:
					MemtoReg <= reg_data_slt;
				default:
					MemtoReg <= reg_data_alu;
			endcase
		end
	  endcase

  // Define ALUctl (3 bits) ***
  // 000: add
  // 001: and
  // 010: or
  // 011: sl
  // 100: sra
  // 101: srl
  // 110: sub
  // 111: xor

  always@*
	  case(opcode)
		  (op_branch): begin
			  ALUctl <= op_sub;
		  end
		  op_ld, op_st: begin
			  ALUctl <= op_add;
		  end
		  op_auipc: begin
			  ALUctl <= op_add;
		  end
		  op_jal, op_jalr: begin
			  ALUctl <= op_add;
		  end
		  (op_no_imm): begin
			  case({funct7, funct3})
				  ({funct7_add, funct3_add_sub}): begin
					  ALUctl <= op_add;
				  end
				  ({funct7_sub, funct3_add_sub}): begin
					  ALUctl <= op_sub;
				  end
				  ({funct7_and, funct3_and}): begin
					  ALUctl <= op_and;
				  end
				  ({funct7_or, funct3_or}): begin
					  ALUctl <= op_or;
				  end
				  ({funct7_sl, funct3_sl}): begin
					  ALUctl <= op_sl;
				  end
				  ({funct7_sra, funct3_sr}): begin
					  ALUctl <= op_sra;
				  end
				  ({funct7_srl, funct3_sr}): begin
					  ALUctl <= op_srl;
				  end
				  ({funct7_xor, funct3_xor}): begin
					  ALUctl <= op_xor;
				  end
				  ({funct7_slt, funct3_slt_slti}): begin
					  ALUctl <= op_sub;
				  end
			  endcase
		  end
		(op_imm): begin
			casez({funct7, funct3})
				({7'bz,funct3_add_sub}): begin
					ALUctl <= op_add;
				end
				({7'bz,funct3_and}): begin
					ALUctl <= op_and;
				end
				({7'bz,funct3_or}): begin
					ALUctl <= op_or;
				end
				({7'bz,funct3_xor}): begin
					ALUctl <= op_xor;
				end
				({funct7_sl,funct3_sl}): begin
					ALUctl <= op_sl;
				end
				({funct7_srl,funct3_sr}): begin
					ALUctl <= op_srl;
				end
				({funct7_sra,funct3_sr}): begin
					ALUctl <= op_sra;
				end
				({7'bz,funct3_slt_slti}): begin
					ALUctl <= op_sub;
				end
			endcase
		  end
	  endcase

  // EBREAK return signal
  wire brk = (im_data[6:0] == 7'b1110011) ? 1 : 0;


  // -- Guidelines
  // For each control signal above you can use 'assign', 'case', or 'casez', as you see want. Your possible inputs are: 'im_data' (broken into opcode, funct3 and funct7), ALUzero and ALUneg.
  // The last line (wire brk) serves to inform the testbench to evaluate a response. Please leave it unaltered.
endmodule



module datapath
#(
  parameter W = 32,
  parameter IM_L = 16,
  parameter DM_L = 64
) (
  input  clk, rst, run,

  // Control Unit I/O
  input RegWrite,
  input ALUsrc,
  input [1:0] PCsrc,
  input [2:0] MemtoReg,
  input [2:0] ALUctl,
  output ALUzero, ALUneg,

  // Instruction Memory I/O
  input  [31:0] im_data,
  output [$clog2(IM_L*4)-1:0] im_addr,
  
  // Data Memory I/O
  input  [W-1:0] dm_data_out,
  output [W-1:0] dm_data_in,
  output [$clog2(DM_L*(W/8))-1:0] dm_addr
);
  
  // Instruction formats
  localparam
    fmt_R  = 3'b000,
    fmt_I  = 3'b001,
    fmt_S  = 3'b010,
    fmt_SB = 3'b011,
    fmt_U  = 3'b100,
    fmt_UJ = 3'b101;

  localparam
	pc_next 	= 2'd0,
	pc_imm 		= 2'd1,
	pc_link_reg = 2'd2;

  localparam
  	reg_data_alu 		= 3'd0,
  	reg_data_jmp_link 	= 3'd1,
  	reg_data_up_imm 	= 3'd2,
  	reg_data_up_imm_pc 	= 3'd3,
  	reg_data_byte 		= 3'd4,
  	reg_data_half_word 	= 3'd5,
  	reg_data_word 		= 3'd6,
  	reg_data_slt 		= 3'd7;

  // Partition instruction
  wire [6:0] opcode = im_data[ 6: 0];
  wire [4:0] rd     = im_data[11: 7];
  wire [2:0] funct3 = im_data[14:12];
  wire [4:0] rs1    = im_data[19:15];
  wire [4:0] rs2    = im_data[24:20];
  wire [6:0] funct7 = im_data[31:25];

  // Register File Instantiation
  wire [W-1:0] rs1_data, rs2_data;
  reg  [W-1:0] rf_wdata;
  registerfile #(W) RF (
    .Read1     (rs1),
    .Read2     (rs2),
    .WriteReg  (rd),
    .WriteData (rf_wdata),
    .RegWrite  (RegWrite),
    .clk       (clk),
    .Data1     (rs1_data),
    .Data2     (rs2_data)
  );

  // ALU Instantiation
  wire [W-1:0] aluA, aluB, aluout;
  alu #(W) ALU (
    .ALUctl (ALUctl),
    .A      (aluA),
    .B      (aluB),
    .ALUout (aluout),
    .Zero   (ALUzero),
    .Neg    (ALUneg)
  );

  // Format associator (auxiliary variable)
  // Note that 'format', as well as 'imm' below, are not real registers, despite being defined as 'reg'. They will only be synthesized as registers if they are sensitive to a signal's edge (posedge or negedge). As such, both 'always' are combinatory circuits.
  reg [2:0] format;
  always@*
    casez(opcode)
      // accounts for all A&L instructions
      7'b0110011         // ADD
        : format <= fmt_R; 

      // accounts for all A&L immediate instructions
      7'b0010011, // ADDI
      7'b1100111, // JALR
      // accounts for all load instructions EXCEPT lui
      7'b0000011, // LW       
      // accounts EBREAK
      7'b1110011  // EBREAK
        : format <= fmt_I;

      // accounts for all store instructions
      7'b0100011  // SW          
        : format <= fmt_S;

      // accounts for all branch instructions
      7'b1100011 // BEQ
        : format <= fmt_SB;

      7'b0010111, // AUIPC
      7'b0110111  // LUI
        : format <= fmt_U;

      7'b1101111 // JAL
        : format <= fmt_UJ;

      default: format <= 3'b111;    
    endcase

  // Immediate generator
  reg [31:0] imm;
  always@*
    case(format)
      fmt_I:   imm <= {{21{im_data[31]}}, im_data[30:20]};
      fmt_S:   imm <= {{21{im_data[31]}}, im_data[30:25], im_data[11:7]};
      fmt_SB:  imm <= {{20{im_data[31]}}, im_data[7], im_data[30:25], im_data[11:8], 1'b0};
      fmt_U:   imm <= {im_data[31:12], {12{1'b0}}};
      fmt_UJ:  imm <= {{11{im_data[31]}}, im_data[19:12], im_data[20], im_data[30:21], 1'b0};
      default: imm <= 32'b0;
    endcase

  // Direct assignments
  assign aluA = rs1_data;
  assign dm_addr = aluout[6:0];
  assign im_addr = PC;

  // Program Counter -> Synchronous Assignment
  reg [$clog2(IM_L*4)-1:0] PC;
  always@(posedge clk)
    if (rst)
      PC <= 0;
    else if (run) // Note: Whether PC remains in its defined range has to be ensured by the assembly code and testbench
	begin
      // PC multiplexor
	  case(PCsrc)
		  (pc_next): begin
			  PC <= PC + 4;
		  end
		  (pc_imm): begin
			  PC <= PC + imm;
		  end
		  (pc_link_reg): begin
			  PC <= rs1_data + imm;
		  end
	  endcase
	end
 
  // rf_wdata multiplexor
  always@*
	  case(MemtoReg)
		  (reg_data_alu): begin
			  rf_wdata <= aluout;
		  end
		  (reg_data_jmp_link): begin
			  rf_wdata <= PC + 4;
		  end
		  (reg_data_up_imm): begin
			  rf_wdata <= imm;
		  end
		  (reg_data_up_imm_pc): begin
			  rf_wdata <= PC + imm;
		  end
		  (reg_data_byte): begin
			  rf_wdata <= {{24{dm_data_out[7]}}, dm_data_out[7:0]};
		  end
		  (reg_data_half_word): begin
			  rf_wdata <= {{16{dm_data_out[15]}}, dm_data_out[15:0]};
		  end
		  (reg_data_word): begin
			  rf_wdata <= dm_data_out;
		  end
		  (reg_data_slt): begin
			  rf_wdata <= ALUneg;
		  end
	  endcase

  // aluB multiplexor
  assign aluB = ALUsrc ? imm : rs2_data;

  // dm_data_in multiplexor
  assign dm_data_in = rs2_data;

  // -- Guidelines
  // For each signal above you can use 'assign', 'case', or 'casez', as you see fit. HOWEVER, if you define a clock-sensitive process, such as 'always(posedge clk)', it may cause timing issues. If you use 'case', then use 'always*'.
  // For similar reasons, remember to use '<=' inside synchronous statements.
          
endmodule
