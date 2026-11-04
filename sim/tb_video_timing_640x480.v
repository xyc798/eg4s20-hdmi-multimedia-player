`timescale 1ns/1ps

module tb_video_timing_640x480;
    reg clk = 0;
    reg rst_n = 0;
    wire [10:0] x, y;
    wire de, hs, vs, sof, eol, vblank;
    integer pixels = 0;
    integer lines = 0;
    integer frames = 0;

    video_timing #(
        .HACTIVE(640), .HFP(16), .HSYNC(96), .HBP(48),
        .VACTIVE(480), .VFP(10), .VSYNC(2), .VBP(33)
    ) dut (
        .clk(clk), .rst_n(rst_n), .x(x), .y(y), .de(de), .hs(hs), .vs(vs),
        .sof(sof), .eol(eol), .vblank(vblank)
    );

    always #5 clk = ~clk;
    always @(posedge clk) begin
        if (rst_n) begin
            if (sof && frames == 1) begin
                if (pixels != 640*480 || lines != 480) begin
                    $display("FAIL: active pixels=%0d lines=%0d", pixels, lines);
                    $finish;
                end
                $display("PASS: tb_video_timing_640x480");
                $finish;
            end
            if (de) pixels = pixels + 1;
            if (eol) lines = lines + 1;
            if (sof) frames = frames + 1;
        end
    end

    initial begin
        repeat (3) @(posedge clk);
        rst_n = 1;
    end
endmodule
