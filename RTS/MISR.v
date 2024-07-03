
module MISR #(parameter MISR_Size = 32) (
    input wire clk,
    input wire internalRst,
    input wire MISR_En,
    input wire [MISR_Size-1:0] MISR_Poly,
    input wire [MISR_Size-1:0] MISR_Seed,
    input wire [MISR_Size-1:0] input_data,
    output reg [MISR_Size-1:0] MISR_Out
);

  always @(posedge clk) begin
    if (internalRst)
      MISR_Out <= MISR_Seed;
    else if(MISR_En)
      MISR_Out <= input_data ^ ({MISR_Size{MISR_Out[0]}} & MISR_Poly) ^ {1'b0, MISR_Out[MISR_Size-1:1]};
  end

endmodule
