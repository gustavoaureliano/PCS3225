module calculadora_tb;

  localparam W = 64;  // Teste com Ws diferentes!

  reg          reset, opera, clock = 0;
  reg  [4:0]   read;
  wire [W-1:0] data;
  
  calculadora #(W) dut(.*);

  always #1 clock = ~clock;

  initial begin
    $dumpfile ("calculadora_tb.vcd");
    $dumpvars(0, calculadora_tb);

    read <= 1'b0;
    opera <= 1'b0;
    reset <= 1'b1;
    #1 reset <= 1'b0;

    #3;

    // Teste instrução 1 -> addi x0, x0, 1
    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 0;
    #1 if (data==3)
      $display("Acerto: RF[%d] = %d, esperado 3.", read, data);
    else
      $display("Erro: RF[%d] = %d, esperado 3.", read, data);

    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 1;
    #1 if (data==5)
      $display("Acerto: RF[%d] = %d, esperado 5.", read, data);
    else
      $display("Erro: RF[%d] = %d, esperado 5.", read, data);

    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 1;
    #1 if (data==6)
      $display("Acerto: RF[%d] = %d, esperado 6.", read, data);
    else
      $display("Erro: RF[%d] = %d, esperado 6.", read, data);

    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 2;
    #1 if (data==6)
      $display("Acerto: RF[%d] = %d, esperado 6.", read, data);
    else
      $display("Erro: RF[%d] = %d, esperado 6.", read, data);

    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 3;
    #1 if (data==8)
      $display("Acerto: RF[%d] = %d, esperado 8.", read, data);
    else
      $display("Erro: RF[%d] = %d, esperado 8.", read, data);

    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 4;
    #1 if (data==0)
      $display("Acerto: RF[%d] = %d, esperado 0.", read, data);
    else
      $display("Erro: RF[%d] = %d, esperado 0.", read, data);

    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 5;
    #1 if (data==1036)
      $display("Acerto: RF[%d] = %d, esperado 1036.", read, data);
    else
      $display("Erro: RF[%d] = %d, esperado 1036.", read, data);

    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 6;
    #1 if (data==1039)
      $display("Acerto: RF[%d] = %d, esperado 1039.", read, data);
    else
      $display("Erro: RF[%d] = %d, esperado 1039.", read, data);

    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 7;
    #1 if (data==4)
      $display("Acerto: RF[%d] = %d, esperado 4.", read, data);
    else
      $display("Erro: RF[%d] = %d, esperado 4.", read, data);

    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 7;
    #1 if (data==36)
      $display("Acerto: RF[%d] = %d, esperado 36.", read, data);
    else
      $display("Erro: RF[%d] = %d, esperado 36.", read, data);

    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 8;
    #1 if (data==0)
      $display("Acerto: RF[%d] = %d, esperado 0.", read, data);
    else
      $display("Erro: RF[%d] = %d, esperado 0.", read, data);

    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 9;
    #1 if (data==4)
      $display("Acerto: RF[%d] = %d, esperado 4.", read, data);
    else
      $display("Erro: RF[%d] = %d, esperado 4.", read, data);

    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 10;
    #1 if (data==42)
      $display("Acerto: RF[%d] = %d, esperado 42.", read, data);
    else
      $display("Erro: RF[%d] = %d, esperado 42.", read, data);

    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 0;
    #1 if (data==51)
      $display("Acerto: RF[%d] = %d, esperado 51.", read, data);
    else
      $display("Erro: RF[%d] = %d, esperado 51.", read, data);

    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 10;
    #1 if (data==9)
      $display("Acerto: RF[%d] = %d, esperado 9.", read, data);
    else
      $display("Erro: RF[%d] = %d, esperado 9.", read, data);

    opera <= 1'b1; #2; opera <= 1'b0;
    read <= 10;
    #1 if (data==1040)
      $display("Acerto: RF[%d] = %d, esperado 1040.", read, data);
    else
      $display("Erro: RF[%d] = %d, esperado 1040.", read, data);

    // Escreva os proximos testes, usando a mesma temporização


    $finish;
  end
    
endmodule
