`timescale 1ns/1ps
module tb_frame_buffer_ctrl;
    reg clk=0, rst_n=0, frame_ready=0, swap_req=0, vblank=0;
    wire [22:0] display_base, write_base; wire swap_done;
    frame_buffer_ctrl dut(.clk(clk),.rst_n(rst_n),.frame_ready(frame_ready),.swap_req(swap_req),.vblank(vblank),.display_base(display_base),.write_base(write_base),.swap_done(swap_done));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); rst_n=1;
        frame_ready=1; swap_req=1; @(posedge clk); frame_ready=0; swap_req=0;
        if (display_base != 0 || swap_done) begin $display("FAIL: swapped outside vblank"); $finish; end
        vblank=1; @(posedge clk); #1; vblank=0;
        if (display_base != 23'd614400 || write_base != 0 || !swap_done) begin $display("FAIL: frame addresses"); $finish; end
        $display("PASS: tb_frame_buffer_ctrl"); $finish;
    end
endmodule
