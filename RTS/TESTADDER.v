module TESTADDER();

  reg [0:31]operand_1;
  reg [0:31]operand_2;
  reg clk;
  reg NbarT;
  reg Si;
  wire [0:31]Sum;
  wire [0:0]So;
  adder_net FUT (
    .operand_1(operand_1),
    .operand_2(operand_2),
    .NbarT(NbarT),
    .Si(Si),
    .clk(clk),
    .Sum(Sum),
    .So(So)
  );

  initial begin
    $FaultCollapsing(TESTADDER.FUT, "AdderFaults.flt");
    clk = 0;
    operand_1 = 32'b0;
    operand_2 = 32'b0;
    repeat (32) begin
      repeat (32) begin
        #10 {clk, operand_1} = {~clk, operand_1 + 1};
      end
      #10 {clk, operand_2} = {~clk, operand_2 + 1};
    end

    #10 $finish;
  end

  always #5 clk = ~clk;

endmodule
