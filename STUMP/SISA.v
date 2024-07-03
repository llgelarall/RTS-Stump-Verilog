module SISA #(parameter SISA_Size = 181) (
    input clk, internalRst, SISA_En, 
    input [SISA_Size - 1:0] SISA_Poly, SISA_Seed,
    input So,
    output reg [SISA_Size - 1:0] SISA_Out
);

    integer i;

    always @(posedge clk or posedge internalRst) begin
        if (internalRst == 1'b1)
            SISA_Out <= SISA_Seed;
        else if (SISA_En == 1'b1) begin
            SISA_Out[SISA_Size - 1] <= SISA_Out[0] ^ So;
            for (i = 0; i < SISA_Size - 1; i = i + 1) begin
                SISA_Out[i] <= (SISA_Out[0] & SISA_Poly[i]) ^ SISA_Out[i + 1];
            end 
        end
    end

endmodule