`timescale 1ns / 1ps

module reflector(
    input clk,
    input reset_n,
    input set,
    input [207:0] idx_in,
    input valid,
    input[7:0] din,
    input dec,
    output reg [7:0] dout,
    output reg done
);

    reg [7:0] r_din; reg [207:0] r_idx; 
    integer i;
    reg cnt;
    
always @ (posedge clk) begin
        if(done == 1) done = 0;
        if(reset_n == 1'b0) begin //reset_n이 0이 0인 경우 모든 값 0
            done = 1'b0;
            dout = 0;
            r_din = 0;
            r_idx = 0;
        end
    
        if(valid ==1'b1) begin  // valid일 때 valid값 받기
             r_din = din;
        end
        else r_din =0;
        if(set == 1'b1) begin  // set일 때 setting 값들 받기
            r_idx = idx_in;
        end
        if (r_din !=0) begin
            if(dec == 1'b0) begin  // dec가 0일 때 암호화 수행
                for(i=0;i<26;i=i+1) begin
                    if(r_din==i+65)dout = r_idx[(207-8*i)-:8];
                end
                done = 1;
            end //dec ==0 의 end
            
            if(dec == 1'b1) begin // dec가 1일 때 복호화 수행
                for(i=0;i<26;i=i+1) begin
                    if(r_din==r_idx[(207-8*i)-:8])dout = i+65;
                end
                done = 1;
            end //dec==1 end 의 end
        end //din!=0의 end 
end //always의 end

endmodule