
module add3or0 ( bcd_i , bcd_o );
 input [3:0] bcd_i ;
 output [3:0] bcd_o ;
 assign bcd_o = ( bcd_i < 5) ? bcd_i : bcd_i + 4'b0011 ;
 endmodule

module tb ();

    parameter W = 18;    

    reg clk = 0, rst = 0, start = 0;
    reg [W-1:0] bin;
    wire done;
    wire [4*$ceil(W/3.0)-1:0] bcd;

    double_dabble DUT (clk, rst, start, bin, done, bcd);
    
    integer i = 0;

    initial begin 
        forever begin
            clk = !clk;
            #1;
        end 
    end

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);

        //$monitor("%d %d - %d %d", start, done, bin, bcd);
        

        for (i = 0; i <= 999; i = i + 1) begin
            start = 0;
            #1;
            bin = i[W-1:0]; 
            #1;
            start = 1;
            #1;
            while (!done) #1;
            #1;
            $display("%0d %0h", bin, bcd); 
        end

        bin = 42;
        
        #2;

        start = 1;

        #10;
        while (!done) #2;

        #2

        start = 0;

        #2
        

        bin = 69;

        #2;

        start = 1;

        #10;
        while (!done) #2;

        #2

        start = 0;

        #2

        $finish();


    end

endmodule



module double_dabble (clk, rst, start , binary , done , bcd );
parameter W = 18;
input clk, rst, start ;
input [W-1:0] binary ;
output done;
output [4* $ceil (W/3.0)-1:0] bcd ;
 
reg[W-1:0] bin_reg;
reg[4* $ceil (W/3.0)-1:0] bcd_reg;
reg passarbit_reg;
reg done_reg;
reg[3:0] bcd_i;
wire[3:0] bcd_o;

integer i;
integer j;

initial begin
    done_reg = 0;
    bcd_reg = 24'b0;
end






always @(posedge clk) begin
    
    bin_reg = binary;
    #1;
    
    if(start == 0) begin
        done_reg = 0;
        bcd_reg = 24'b0;
        #1;
            
    end

    else if(start == 1) begin

        for(i = 0; i < W; i = i + 1) begin

            for(j = 0; j < $ceil (W/3.0); j = j + 1) begin

                if(j == 0) begin
                    bcd_i = bcd_reg[3:0];
                    #1;
                    bcd_reg[3:0] = bcd_o;
                end

                else if(j == 1) begin
                    bcd_i = bcd_reg[7:4];
                    #1;
                    bcd_reg[7:4] = bcd_o;
                
                end

                else if(j == 2) begin
                    bcd_i = bcd_reg[11:8];
                    #1;
                    bcd_reg[11:8] = bcd_o;
                
                end

                else if(j == 3) begin
                    bcd_i = bcd_reg[15:12];
                    #1;
                    bcd_reg[15:12] = bcd_o;
                
                end

                else if(j == 4) begin
                    bcd_i = bcd_reg[19:16];
                    #1;
                    bcd_reg[19:16] = bcd_o;
                end

                else if(j == 5) begin
                    bcd_i = bcd_reg[23:20];
                    #1;
                    bcd_reg[23:20] = bcd_o;
                end
            
        end

            passarbit_reg = bin_reg[W-1];
            #1;
            bin_reg = bin_reg << 1;
            bcd_reg = bcd_reg << 1;
            #1;
            bcd_reg[0] = passarbit_reg;

        
        end
        #1;
        done_reg = 1;
        #1;
        
    end
    
    
end

    assign done = done_reg;
    assign bcd = bcd_reg;

    add3or0 add(bcd_i, bcd_o);


endmodule

