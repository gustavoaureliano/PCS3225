module m_dec
(
  input  clk_dec,
  input  rst,
  input  data_m,
  output reg data_out,
  output reg sample
);
  reg [2:0] state;

  localparam
    s_ini = 0,
    s_1   = 1,
    s_2   = 2;

  // "sample" is a signal which tells the testbench to save data_out. This process is triggered with @(posedge sample).
  initial sample = 0;

  // State-change block
  always@(clk_dec) begin
    if (rst === 1) begin
      state = s_ini;
      data_out = 1'bz;
    end
    else if (state === s_ini) state = s_1;
  	else if (state == s_1) begin
		state = s_2;
	end
	else if (state == s_2) begin
		state = s_1;
	end
  end

  // State-logic block
  always@(state) begin
  	case (state)
	  s_ini: begin
	  	sample = 0;
		data_out = 1'bz;
	  end
	  s_1: begin
		sample = 0;
	  end
	  s_2: begin
		sample = 1;
		data_out = data_m;
	  end
    endcase
  end
  
endmodule
