`timescale 1ns / 1ps

module tb;

reg clk;
reg reset_n;
reg set;
reg en;
reg valid;
reg dec;
reg[7:0] din;
wire[7:0] dout;
reg[31:0] first_offset;
reg[31:0] second_offset;
reg[31:0] third_offset;
reg[31:0] first_delay;
reg[31:0] second_delay;
reg[31:0] third_delay;
reg[207:0] first_idx_in;
reg[207:0] second_idx_in;
reg[207:0] third_idx_in;
reg[207:0] reflector_idx_in;
integer counter;

reg[26*8-1:0] first_stream;
reg[26*8-1:0] second_stream;
reg[26*8-1:0] third_stream;
reg[26*8-1:0] reflector_stream;

wire[7:0] encrypt = (counter==0)? 83 :
                    (counter==1)? 79 :
                    (counter==2)? 82 :
                    (counter==3)? 76 :
                    (counter==4)? 65 :
                    (counter==5)? 66 : 90;

reg[7:0] result [0:11];

top UUT(
    .clk(clk), .reset_n(reset_n), .valid(valid), .set(set), .en(en), .din(din), 
    .dec(dec), .dout(dout), .done(done),
    .first_offset(first_offset), .second_offset(second_offset),
    .third_offset(third_offset), .first_delay(first_delay),
    .second_delay(second_delay), .third_delay(third_delay),
    .first_idx_in(first_idx_in), .second_idx_in(second_idx_in),
    .third_idx_in(third_idx_in), .reflector_idx_in(reflector_idx_in)
);

always# 5ns clk=~clk;

initial begin
    result[0]<=0; result[1]<=0; result[2]<=0;
    result[3]<=0; result[4]<=0; result[5]<=0;
    result[6]<=0; result[7]<=0; result[8]<=0;
    result[9]<=0; result[10]<=0; result[11]<=0;
    counter<=0;
    first_stream <= "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    second_stream <= "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    third_stream <= "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    reflector_stream <= "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    clk<=1;
    dec<=0;
    reset_n<=0;
    din<=0;
    set<=0;
    en<=0;
    first_offset<=0;
    first_delay<=0;
    second_offset<=0;
    second_delay<=0;
    third_offset<=0;
    third_delay<=0;
    first_idx_in<=0;
    second_idx_in<=0;
    third_idx_in<=0;
    reflector_idx_in<=0;
    valid<=0;
    #(200ns)
    reset_n<=1;
    set<=1;
    first_offset<=2;
    first_delay<=4;
    second_offset<=3;
    second_delay<=3;
    third_offset<=1;
    third_delay<=3;
    first_idx_in = stream_to_idx(first_stream);
    second_idx_in = stream_to_idx(second_stream);
    third_idx_in = stream_to_idx(third_stream);
    reflector_idx_in = stream_to_idx(reflector_stream);
    #(100ns)
    set<=0;
    #(60ns)
    en<=1;
    valid<=1;
    din<=encrypt;
    counter<=counter+1;
    #(10ns)
    valid<=0;

end
always@(posedge clk) begin
    if(done) begin
        if(counter<6) begin
            result[counter-1]<=dout;
            valid<=1;
            din<=encrypt;
            #(10ns)
            valid<=0;
            counter<=counter+1;
        end
        else if(counter==6) begin
            result[counter-1]<=dout;
            valid<=1;
            dec<=1;
            din<=dout;
            #(10ns)
            valid<=0;
            counter<=counter+1;
        end
        else if(counter<12) begin
            result[counter-1]<=dout;
            dec<=1;
            valid<=1;
            din<=result[11-counter];
            #(10ns)
            valid<=0;
            counter<=counter+1;
        end
        else if(counter<13) begin
            result[counter-1]<=dout;
            counter<=counter+1;
        end
    end
    else if(counter==13) begin
        if({result[0],result[1],result[2],result[3],result[4],result[5]}==48'b010010010101011101010010010001000100101101000100) begin
            $display("encryption is finished successfully");
            if({result[6],result[7],result[8],result[9],result[10],result[11]}==48'b010000100100000101001100010100100100111101010011) begin
                $display("decryption is also correct");
            end
            else begin
                $display("decryption failure");
            end
        end
        else begin
            $display("encryption failure");
        end
        counter<=counter+1;
        $finish;
    end
end



function [7:0] string_to_ascii;
input [8*26-1:0] in;
begin
    if(in == "A") string_to_ascii = 65;
    if(in == "B") string_to_ascii = 66;
    if(in == "C") string_to_ascii = 67;
    if(in == "D") string_to_ascii = 68;
    if(in == "E") string_to_ascii = 69;
    if(in == "F") string_to_ascii = 70;
    if(in == "G") string_to_ascii = 71;
    if(in == "H") string_to_ascii = 72;
    if(in == "I") string_to_ascii = 73;
    if(in == "J") string_to_ascii = 74;
    if(in == "K") string_to_ascii = 75;
    if(in == "L") string_to_ascii = 76;
    if(in == "M") string_to_ascii = 77;
    if(in == "N") string_to_ascii = 78;
    if(in == "O") string_to_ascii = 79;
    if(in == "P") string_to_ascii = 80;
    if(in == "Q") string_to_ascii = 81;
    if(in == "R") string_to_ascii = 82;
    if(in == "S") string_to_ascii = 83;
    if(in == "T") string_to_ascii = 84;
    if(in == "U") string_to_ascii = 85;
    if(in == "V") string_to_ascii = 86;
    if(in == "W") string_to_ascii = 87;
    if(in == "X") string_to_ascii = 88;
    if(in == "Y") string_to_ascii = 89;
    if(in == "Z") string_to_ascii = 90;
end
endfunction

function [207:0] stream_to_idx;
input reg[8*26-1:0] in;
integer i;
reg[26*8-1:0] temp;
begin

    for(i=0;i<26;i=i+1) begin
        temp = in[8*i+:8];
        stream_to_idx[8*i+:8]=string_to_ascii(temp);
    end

    
end
endfunction
endmodule