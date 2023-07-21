`timescale 1ns / 1ps

module rotor(
    input clk,
    input reset_n,
    input set,
    input en,
    input valid,
    input rot,
    input[7:0] din,
    input[31:0] offset,
    input[31:0] delay,
    input[207:0] idx_in,
    input dec,
    output [7:0] dout,
    output reg done
);
    reg [7:0] r_dout; reg [7:0] r_din; reg [31:0] r_offset; reg [31:0] r_delay; reg [207:0] r_idx; reg[31:0] cnt;
    integer i;
    
always @ (posedge clk) begin
       if(done == 1)begin done = 0; cnt=0;end    
       if(reset_n == 1'b0) begin //reset_n이 0이 0인 경우 모든 값 0
          done = 1'b0;
          r_dout = 1'b0;
          r_din = 0;
          r_offset = 0;
          r_delay = 0;
          r_idx = 0;
          cnt =0;
        end    
        
        if(valid ==1'b1) begin  // valid 1일 때 din값 받기
            r_din = din;
            cnt=0;
        end        
        
        if(set == 1'b1) begin  // set 1일 때 setting 값들 받기
            r_offset = offset;
            r_delay = delay;
            r_idx = idx_in;
        end
        
       
        if(en == 1'b1)begin // en 1일 때 module 동작
            if(rot==1'b1) begin
                if(dec == 1'b1&&cnt==0) begin // dec가 1일 때 복호화 수행
                    for(i=0;i<26;i=i+1) begin
                        if(r_din==r_idx[(207-8*i)-:8])r_dout = i+65;
                    end
                end
                
                if(dec == 1'b0) begin  // dec가 0일 때 암호화 수행
                    if(r_din != 0) begin cnt = cnt+1; end
                    for(i=0;i<26;i=i+1) begin
                        while(r_offset>26)r_offset=r_offset-26;
                        r_idx[(207-8*i)-:8]=r_idx[(207-8*i)-:8]+r_offset;
                        while(r_idx[(207-8*i)-:8]>90)r_idx[(207-8*i)-:8]=r_idx[(207-8*i)-:8]-26;
                    end
                end
        
                 else if(dec == 1'b1) begin // dec가 1일 때 복호화 수행
                    if(r_din != 0) begin cnt = cnt+1; end
                    for(i=0;i<26;i=i+1) begin
                        while(r_offset>26)r_offset=r_offset-26;
                        r_idx[(207-8*i)-:8]=r_idx[(207-8*i)-:8]-r_offset;
                        while(r_idx[(207-8*i)-:8]<65)r_idx[(207-8*i)-:8]=r_idx[(207-8*i)-:8]+26;
                    end
                end
        
                if(dec==0)begin
                    for(i=0;i<26;i=i+1) begin
                        if(r_din==i+65)r_dout = r_idx[(207-8*i)-:8];
                    end
                end
             end 
             
        if(cnt == r_delay) begin  
            done = 1; r_din =0; cnt =0;
        end      
    end 
end 

assign dout = r_dout;

endmodule