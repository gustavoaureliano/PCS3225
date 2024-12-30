module ham74
(
  input  [6:0] data_in,
  output err_detect,
  output reg [6:0] data_out
);
  wire
    p1 = data_in[0],
    p2 = data_in[1],
    d1 = data_in[2],
    p3 = data_in[3],
    d2 = data_in[4],
    d3 = data_in[5],
    d4 = data_in[6];
  
  reg p1_err, p2_err, p3_err;
  reg p1_c, p2_c, p3_c;
  reg [2:0] bit_err;

  // error detection block
  always@* begin
    case({d1, d2, d4, p1}) // p1 block
      (4'b0000):
	    p1_err <= 0;
	  (4'b0011):
	  	p1_err <= 0;
	  (4'b0101):
	  	p1_err <= 0;
      (4'b0110):
	    p1_err <= 0;
      (4'b1001):
	    p1_err <= 0;
	  (4'b1010):
	  	p1_err <= 0;
	  (4'b1100):
	  	p1_err <= 0;
	  (4'b1111):
	  	p1_err <= 0;
      default: p1_err <= 1;
    endcase

    case({d1, d3, d4, p2}) // p2 block
      (4'b0000):
	    p2_err <= 0;
	  (4'b0011):
	  	p2_err <= 0;
	  (4'b0101):
	  	p2_err <= 0;
      (4'b0110):
	    p2_err <= 0;
      (4'b1001):
	    p2_err <= 0;
	  (4'b1010):
	  	p2_err <= 0;
	  (4'b1100):
	  	p2_err <= 0;
	  (4'b1111):
	  	p2_err <= 0;
      default: p2_err <= 1;
    endcase

    case({d2, d3, d4, p3}) // p3 block
      (4'b0000):
	    p3_err <= 0;
	  (4'b0011):
	  	p3_err <= 0;
	  (4'b0101):
	  	p3_err <= 0;
      (4'b0110):
	    p3_err <= 0;
      (4'b1001):
	    p3_err <= 0;
	  (4'b1010):
	  	p3_err <= 0;
	  (4'b1100):
	  	p3_err <= 0;
	  (4'b1111):
	  	p3_err <= 0;
      default: p3_err <= 1;
    endcase
  end
  assign err_detect = p1_err | p2_err | p3_err;

  // error correction block
  always@* begin
    case({p3_err, p2_err, p1_err})
		3'b001:
			data_out <= {d4, d3, d2, p3, d1, p2, ~p1};
		3'b010:
			data_out <= {d4, d3, d2, p3, d1, ~p2, p1};
		3'b011:
			data_out <= {d4, d3, d2, p3, ~d1, p2, p1};
		3'b100:
			data_out <= {d4, d3, d2, ~p3, d1, p2, p1};
		3'b101:
			data_out <= {d4, d3, ~d2, p3, d1, p2, p1};
		3'b110:
			data_out <= {d4, ~d3, d2, p3, d1, p2, p1};
		3'b111:
			data_out <= {~d4, d3, d2, p3, d1, p2, p1};
      default: data_out <= {d4, d3, d2, p3, d1, p2, p1}; // no error
    endcase
	end

endmodule
