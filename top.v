`timescale 1ns / 1ps

module top(
    input clk,
    input reset_n,
    input set,
    input en,
    input valid,
    input[7:0] din,
    input dec,
    output[7:0] dout,
    output done,

    input[31:0] first_offset,
    input[31:0] second_offset,
    input[31:0] third_offset,
    input[31:0] first_delay,
    input[31:0] second_delay,
    input[31:0] third_delay,
    input[207:0] first_idx_in,
    input[207:0] second_idx_in,
    input[207:0] third_idx_in,
    input [207:0] reflector_idx_in
);
    reg[31:0] r_first_offset;
    reg[31:0] r_second_offset;
    reg[31:0] r_third_offset;
    reg[31:0] r_first_delay;
    reg[31:0] r_second_delay;
    reg[31:0] r_third_delay;
    reg[207:0] r_first_idx_in;
    reg[207:0] r_second_idx_in;
    reg[207:0] r_third_idx_in;
    reg[207:0] r_reflector_idx_in;
    reg[7:0] r_din;
    reg r_rot;
    
    reg isdelay;
    reg[31:0] endelay;
    reg[31:0] dedelay;
    reg[31:0] sumoffset;
    reg[31:0]sumdelay;

    
    wire [7:0] o1, o2, o3, o4;
    wire d1, d2, d3, d4; 
    reg r_valid1, r_valid2, r_valid3, r_valid4;
    reg[7:0] r_current_ascii;
    reg[7:0] r_answer_ascii; assign dout = r_answer_ascii; 
    reg r_done;  assign done = r_done;
    reg[7:0] r_cnt; 

    initial begin isdelay=0; endelay=0;dedelay=0; sumdelay=0; end
    always@(*)begin 
        if(d1==1 && d2==0 && d3==0 && d4==0 && r_cnt == 7) begin 
            r_current_ascii = o1;  
            if(dec==0)begin 
                sumoffset=2*(r_first_offset+r_second_offset+r_third_offset);
                if(sumoffset>25)sumoffset=sumoffset-26;
                if(endelay>=dedelay)sumdelay=(endelay-dedelay)*(sumoffset);
                else if(endelay<dedelay)sumdelay=(dedelay-endelay)*(sumoffset); 
             end
             else if(dec==1) begin 
                sumoffset=2*(r_first_offset+r_second_offset+r_third_offset);
                if(sumoffset>25)sumoffset=sumoffset-26;
                if(endelay>=dedelay) sumdelay=(endelay-dedelay)*(sumoffset);
                else if(endelay<dedelay)sumdelay=(dedelay-endelay)*(sumoffset);
             end
             while(sumdelay>25)sumdelay=sumdelay-26;
             if(dec==0)begin
                if(endelay>=dedelay) r_answer_ascii = r_current_ascii-sumdelay;
                else if(endelay<dedelay) r_answer_ascii = r_current_ascii+sumdelay;
             end
             if(dec==1)begin
                if(endelay>=dedelay)   r_answer_ascii = r_current_ascii+sumdelay;
                else if(endelay<dedelay) r_answer_ascii = r_current_ascii-sumdelay;
             end
             while(r_answer_ascii<65)r_answer_ascii=r_answer_ascii+26;
             while(r_answer_ascii>90)r_answer_ascii=r_answer_ascii-26;
             r_done =1; r_cnt =0; isdelay=1;
        end 
        if(valid==1)isdelay=0;
     end
    
always @ (posedge clk) begin
    if(isdelay&&!dec) begin 
        endelay=endelay+1; if(endelay==26)endelay=0;
    end
    else if(isdelay&&dec)begin 
        dedelay=dedelay+1;if(dedelay==26)dedelay=0;
    end

    if(done==1)r_done=0;
    if(reset_n == 1'b0) begin // 0 일 때 reset
            r_first_offset = 0;
            r_second_offset = 0;
            r_third_offset = 0;
            r_first_delay = 0;
            r_second_delay = 0;
            r_third_delay = 0;
            r_first_idx_in = 0;
            r_second_idx_in = 0;
            r_third_idx_in = 0;
            r_reflector_idx_in = 0;
            r_din = 0;
            r_current_ascii =0;
            r_answer_ascii = 0;
            r_rot = 0;
            r_cnt =0;
            r_done =0;
            isdelay=0; endelay=0; dedelay=0; sumdelay=0;
      end
            
      if(set==1'b1) begin//set값이 1일 때 setting 값 reg에 입력
            r_first_offset = first_offset;
            r_second_offset = second_offset;
            r_third_offset = third_offset;
            r_first_delay = first_delay;
            r_second_delay = second_delay;
            r_third_delay = third_delay;
            r_first_idx_in = first_idx_in;
            r_second_idx_in = second_idx_in;
            r_third_idx_in = third_idx_in;
            r_reflector_idx_in = reflector_idx_in;
       end 
        
       if(valid == 1'b1) begin //valid가 1이면 din을 받아들임        
            r_din = din;   
            r_cnt = 0;
       end 
       if(en == 1'b1) begin //en 1일 때 모듈 동작
            r_rot=1;
            if(r_valid1==1) r_valid1=0;
            if(r_valid2==1) r_valid2=0;
            if(r_valid3==1) r_valid3=0;
            if(r_valid4==1) r_valid4=0;
            
            if(d1==0 && d2==0 && d3==0 && d4==0 && r_cnt == 0&&valid == 1'b1) begin r_current_ascii = r_din; r_cnt= r_cnt+1; r_valid1 =1;r_valid2 =0;r_valid3 =0;r_valid4 =0; end
            else if(d1==1 && d2==0 && d3==0 && d4==0 && r_cnt == 1) begin r_current_ascii = o1; r_cnt= r_cnt+1; r_valid2 =1;end
            else if(d1==0 && d2==1 && d3==0 && d4==0 && r_cnt == 2) begin r_current_ascii = o2; r_cnt= r_cnt+1; r_valid3 =1;end
            else if(d1==0 && d2==0 && d3==1 && d4==0 && r_cnt == 3) begin r_current_ascii = o3; r_cnt= r_cnt+1; r_valid4 =1;end
            else if(d1==0 && d2==0 && d3==0 && d4==1 && r_cnt == 4) begin r_current_ascii = o4; r_cnt= r_cnt+1;r_valid3=1;end
            else if(d1==0 && d2==0 && d3==1 && d4==0 && r_cnt == 5) begin r_current_ascii = o3; r_cnt= r_cnt+1; r_valid2=1;end
            else if(d1==0 && d2==1 && d3==0 && d4==0 && r_cnt == 6) begin r_current_ascii = o2; r_cnt= r_cnt+1; r_valid1=1;end
        end 
        else begin r_rot = 1'b0; end 
end 

   rotor rotor1(clk, reset_n, set, en, r_valid1, r_rot, r_current_ascii, r_first_offset, r_first_delay, r_first_idx_in, dec, o1, d1);
                 
   rotor rotor2(clk, reset_n, set, en, r_valid2, r_rot, r_current_ascii, r_second_offset, r_second_delay, r_second_idx_in, dec, o2, d2);
                 
   rotor rotor3(clk, reset_n, set, en, r_valid3, r_rot, r_current_ascii, r_third_offset, r_third_delay, r_third_idx_in, dec, o3, d3);
                 
   reflector ref(clk, reset_n, set,r_reflector_idx_in, r_valid4, r_current_ascii, dec, o4, d4);
     
endmodule