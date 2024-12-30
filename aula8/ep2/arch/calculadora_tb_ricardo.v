module calculadora_tb;

  localparam W = 32;  // Teste com Ws diferentes!

  reg          reset, opera, clock = 0;
  reg  [4:0]   read;
  wire [W-1:0] data;
  
  calculadora #(W) dut(.*);

  always #1 clock = ~clock;

  initial begin
    // $dumpfile ("calculadora_tb.vcd");
    // $dumpvars(0, calculadora_tb);

    read <= 1'b0;
    opera <= 1'b0;
    reset <= 1'b1;
    #1 reset <= 1'b0;

    #3;

    // Teste instrução 1 -> addi x0, x0, 1
    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 0;
    #1 if (data==0)
      $display("Acerto: RF[%d] = %h, esperado 0.", read, data);
    else
      $display("Erro: RF[%d] = %h, esperado 0.", read, data);


    // Escreva os proximos testes, usando a mesma temporização


    $finish;
  end
    
endmodule