module rom_16 ( out , addr , CS ) ;
 input [ 3 : 0 ] addr ;
 input CS ;
 output reg [ 15 : 0 ] out ;
 reg [ 15 : 0 ] data [ 15 : 0 ] ;
 integer i ;
 initial
 begin
 for ( i = 0 ; i < 15 ; i = i + 1 ) 
 data [ i ] = i [ 15 : 0 ] ;
 data [ 15 ] = 16'h69 ;
 end
 always @ ( addr , CS )
 out = data [ addr ] ;
 endmodule

module ram_4 ( out , in , addr , RW , CS ) ;
 input [ 15 : 0 ] in ;
 input [ 1 : 0 ] addr ;
 input RW , CS ;
 output reg [ 15 : 0 ] out ;
 reg [ 15 : 0 ] data [ 3 : 0 ] ;
 integer i ;
 initial
 for ( i = 0 ; i < 4 ; i = i + 1 )
 data [ i ] = 16'b0 ;
 always @ ( addr , CS , RW )
 if ( RW == 1'b0 )
 out = data [ addr ] ;
 else
 if ( RW == 1'b1 )
 data [ addr ] = in ;
 else
 out = 16'bz ;
 endmodule

module romram1 (out, done);
    output wire [15:0] out;
    output reg done;
    reg [3:0] endereco_rom= 4'b1111;
    reg [1:0] endereco_ram= 2'b11;
    reg RW = 1'b1;
    reg chip_selector = 1'b0;
    wire [15:0] w1 ,w2;
    rom_16 rom(w1,endereco_rom,chip_selector);
    ram_4 ram1(out, w1,endereco_ram, RW,chip_selector);

    initial begin
        #2;
        RW=1'b0;#2
		if (out==16'h69) begin 
            done=1;
		end
        
    end
endmodule
