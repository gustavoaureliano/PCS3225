module tb();

    reg clk = 0;
    reg rst = 0;

    initial forever #1 clk = !clk;

    mboard DUT (.*);

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        #1;
        rst = 1;
        #2;
        rst = 0;
        #200;


        $finish();
    end


endmodule
