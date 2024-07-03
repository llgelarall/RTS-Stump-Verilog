module adder(operand_1,operand_2,clk,Sum);

input [31:0] operand_1;
input [31:0] operand_2;
input [0:0] clk;
output [31:0] Sum;
reg [31:0] sum;
reg rst;
reg [7:0] exponent_final;
reg [23:0] mantissa_final;
reg [24:0] mantissa_sum;
reg [23:0] shifted_mantissa_1,shifted_mantissa_2;
reg [7:0] tmp_new_exponent;
reg [7:0] diff; 

reg busy_1=0;
reg busy_2=0;
reg busy_3=0;
reg done_1,done_2,done_3;

always @(posedge clk)
begin
    if(busy_1==0)
    begin
        busy_1<=1;    
    end
    else if (done_1==1 && busy_2==0)
    begin
        busy_1<=0;
        busy_2<=1;
    end
    else if(done_2==1 && busy_3==0)
    begin

        busy_2<=0;
        busy_3<=1;
    end
    else if(done_3==1)
    begin
        sum<={operand_1[31],exponent_final,mantissa_final[22:0]};
        busy_3<=0;
    end
end
assign Sum = sum; 


always @(posedge clk)
begin
    if(operand_1[30:23] == operand_2[30:23])
    begin
        shifted_mantissa_1<={1'b1,operand_1[22:0]};
        shifted_mantissa_2<={1'b1,operand_2[22:0]};
        tmp_new_exponent<=operand_1[30:23]+1'b1;
        done_1<=1;
    end
    else if(operand_1[30:23]>operand_2[30:23])
    begin
        diff=operand_1[30:23]-operand_2[30:23];
        shifted_mantissa_1<={1'b1,operand_1[22:0]};
        shifted_mantissa_2<=({1'b1,operand_2[22:0]}>>diff);
        tmp_new_exponent<=operand_1[30:23]+1'b1;
        done_1<=1;
    end
    else if(operand_2[30:23]>operand_1[30:23])
    begin
        diff=operand_2[30:23]-operand_1[30:23];
        shifted_mantissa_2<={1'b1,operand_2[22:0]};
        shifted_mantissa_1<=({1'b1,operand_1[22:0]}>>diff);
        tmp_new_exponent<=operand_2[30:23]+1'b1;
        done_1<=1;
    end
end

always @(posedge clk)
begin
    mantissa_sum<=shifted_mantissa_1+shifted_mantissa_2;
    if(mantissa_sum==(shifted_mantissa_1+shifted_mantissa_2))
    begin
        done_2<=1;
    end
end 


always @(posedge clk)
begin
    if(rst==0)
    begin
        mantissa_final<=mantissa_sum[24:1];
        exponent_final<=tmp_new_exponent;
        if(mantissa_final==mantissa_sum[24:1])
        begin
            rst<=1;
        end
    end
    else begin
        repeat(24) begin
            if(mantissa_final[23]==0)
            begin
                mantissa_final<=(mantissa_final<<1'b1);
                exponent_final<=exponent_final-1'b1;
            end
            else begin
                done_3<=1;
                rst<=0;
            end
        end
    end
end
endmodule

