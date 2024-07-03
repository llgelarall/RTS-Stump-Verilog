module PRPG #(parameter PRPG_Size = 32) (
    input clk, internalRst, PRPG_En, 
    input [PRPG_Size - 1:0] PRPG_Poly, PRPG_Seed,
    // input So,
    output reg [PRPG_Size - 1:0] PRPG_Out
);
    integer i;
    always @(posedge clk or posedge internalRst) begin
        if (internalRst == 1'b1)
            PRPG_Out <= PRPG_Seed;
        else if (PRPG_En == 1'b1) begin
            PRPG_Out[PRPG_Size - 1] <= PRPG_Out[0];
            for (i = 0; i < PRPG_Size - 1; i = i + 1) begin
                PRPG_Out[i] <= (PRPG_Out[0] & PRPG_Poly[i]) ^ PRPG_Out[i + 1];
            end 
        end
    end

endmodule