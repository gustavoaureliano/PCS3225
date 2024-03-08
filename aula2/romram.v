module romram1(
    output [15:0] out,
    output reg done
);
    wire [15:0] outrom;
    reg [15:0] in;
    reg RW;

    rom_16 rom(
        .addr(4'd15),
        .out(outrom),
        .CS(1'b0)
    );

    ram_4 ram(
        .out(out),
        .in(in),
        .addr(2'h3),
        .RW(RW),
        .CS(1'b0)
    );

    initial begin
        RW = 0;
        done = 0; #2
        in = outrom; #2;
        RW = 1; #2;
        RW = 0; #2;
        done = 1; #2;
    end



endmodule

module romram2(output reg [15:0] soma,
               output reg comp,
               output reg done);
   
    reg [15:0] aux_sum;
    integer i;
    reg [1:0] addr_ram = 2'b1;
    reg [3:0] addr_rom;
    wire [15:0] output_rom;
    reg [15:0] input_ram;
    wire [15:0] output_ram;
    reg rw_ram;

    rom_16 rom (output_rom, addr_rom, 1'b0);
    ram_4 ram (output_ram, input_ram, 2'b0, rw_ram, 1'b0);

    initial begin
        done = 1'b0;
        aux_sum = 16'b0;
        rw_ram = 1'b0;
        for(i = 0; i < 16; i = i + 1)begin
            addr_rom = i[3:0];#4
            if(i < 15) aux_sum = aux_sum + output_rom;
        end
        #4;
        rw_ram = 1'b1; #4
        input_ram = aux_sum; #2

        if(aux_sum == output_rom) comp = 1'b1;
        else comp = 1'b0;

        done = 1'b1;
        soma = aux_sum;
        #4;
    end

endmodule

module ram_4 ( out , in , addr , RW , CS ) ;
    input [ 15 : 0 ] in ;
    input [ 1 : 0 ] addr ;
    input RW , CS ;
    output reg [ 15 : 0 ] out ;
    reg [ 15 : 0 ] data [ 3 : 0 ] ;
    integer i ;
    initial begin
        for ( i = 0 ; i < 4 ; i = i + 1 ) begin
            data [ i ] = 16'b0 ;
        end
    end
    always @ ( addr , CS , RW ) begin
        if ( RW == 1'b0 )
        out = data [ addr ] ;
        else
        if ( RW == 1'b1 )
        data [ addr ] = in ;
        else
        out = 16'bz ;
    end
endmodule

module rom_16 ( out , addr , CS ) ;
    input [ 3 : 0 ] addr ;
    input CS ;
    output reg [ 15 : 0 ] out ;
    reg [ 15 : 0 ] data [ 15 : 0 ] ;
    integer i ;
    initial
    begin
        for ( i = 0 ; i < 15 ; i = i + 1 ) begin
            data [ i ] = i [ 15 : 0 ] ;
            data [ 15 ] = 16'h69 ;
        end
    end
    always @ ( addr , CS )
    out = data [ addr ] ;
endmodule