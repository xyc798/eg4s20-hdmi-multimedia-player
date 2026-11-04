`timescale 1ns/1ps
module tb_video_mixer;
    reg clk=0,rst_n=0,de=0,fb_valid=0; reg [10:0] x=0,y=0; reg [15:0] fb_pixel=16'hf800; reg [3:0] brightness=8,contrast=8;
    wire [23:0] rgb; wire valid;
    video_mixer dut(.clk(clk),.rst_n(rst_n),.x(x),.y(y),.de(de),.fb_valid(fb_valid),.fb_pixel(fb_pixel),.brightness(brightness),.contrast(contrast),.rgb(rgb),.valid(valid));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); rst_n=1; de=1; fb_valid=1;
        @(posedge clk); #1;
        if(!valid || rgb[23:16] < 8'hf0 || rgb[15:0] != 0) begin $display("FAIL: RGB565 conversion"); $finish; end
        $display("PASS: tb_video_mixer"); $finish;
    end
endmodule
