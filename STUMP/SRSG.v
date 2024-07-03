module SRSG #(
    parameter SRSG_Size = 32
) (
    input  wire clk,
    input  wire internalRst,
    input  wire SRSG_En,
    input  wire [SRSG_Size-1:0] SRSG_Poly,
    input  wire [SRSG_Size-1:0] SRSG_Seed,
    output reg SRSG_Out
);
    reg lfsr;
    always @(posedge clk or posedge internalRst) begin
        if (internalRst)
            SRSG_Out <= SRSG_Seed[0];
        else if (SRSG_En)
            SRSG_Out <= SRSG_Out ^ (SRSG_Out & SRSG_Poly[0]) ^ SRSG_Seed[0];
    end


endmodule 
