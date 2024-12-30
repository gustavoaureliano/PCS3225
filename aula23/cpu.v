module cpu
#(
  parameter IM_L = 8, DM_L = 128
) (
  input clk,
  input rst,
  input ready,
  input [31:0] rdata,
  output reg [31:0] addr,
  output reg [31:0] wdata,
  output reg write,
  output reg done
);
  // Instruction OPCODEs
  localparam [6:0]
    inst_ADD    = 7'b0110011,
    inst_LW     = 7'b0000011,
    inst_SW     = 7'b0100011,
    inst_EBREAK = 7'b1110011;

  // State parameters and register
  localparam
    s_fetch   = 0,
    s_decode  = 1,
    s_execute = 2,
    s_write   = 3;
  reg [2:0]  state;
  
  // Registers for decoded instruction
  reg [6:0]  opcode;
  reg [4:0]  rd, rs1, rs2;
  reg [31:0] imm_I, imm_S;

  // Program Counter
  reg [7:0]  PC = 0;
  
  // Register File
  reg [31:0] RF [4:0];
  initial RF[0] = 0;

  // State-change logic
  always@(posedge clk) begin
    if (rst) begin
      state <= s_fetch;
      PC    <= 0;
      addr  <= 0;
      write <= 0;
      done  <= 0;
    end
    else if ( (state == s_fetch)   && (ready) ) state = s_decode;
    else if ( (state == s_decode)  && (ready) ) state = s_execute;
    else if ( (state == s_execute) && (ready) ) state = s_write;
    else if ( (state == s_write)   && (ready) ) state = s_fetch;
  end

  // Internal state logic
  always@(state) begin

    if (state == s_fetch) begin
      // Pega dados na ROM
      addr <= PC;
      write <= 0;
    end

    else if (state == s_decode) begin
      opcode <= rdata[ 6: 0];
      rd     <= rdata[11: 7];
      rs1    <= rdata[19:15];
      rs2    <= rdata[24:20];
      imm_I  <= {{21{rdata[31]}}, rdata[30:20]};
      imm_S  <= {{21{rdata[31]}}, rdata[30:25], rdata[11:7]};
    end

    else if (state == s_execute) begin
      case (opcode) 
        inst_ADD: begin
            write <= 0;
            RF[rd] <= RF[rs1] + RF[rs2]; 
        end
        inst_LW: begin 
            write <= 0;
            addr[31:0] <= {RF[rs1] + imm_I, 8'h00};
        end
        inst_SW: begin
            write <= 1;
            addr[31:0] <= {RF[rs1] + imm_S, 8'h00};
            wdata <= RF[rs2];
        end
        inst_EBREAK: begin
            write <= 0;
            done <= 1;
        end
      endcase
    end

    else if (state == s_write) begin
        if (opcode == inst_LW) 
            RF[rd] <= rdata;
        //write <= 0;
        PC <= PC + 4;
    end
  end

endmodule
