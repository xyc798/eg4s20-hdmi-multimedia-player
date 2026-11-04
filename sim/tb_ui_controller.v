`timescale 1ns/1ps
module tb_ui_controller;
    reg clk = 0, rst_n = 0, catalog_ready = 0, catalog_error = 0;
    reg key_prev = 0, key_next = 0, key_play = 0, key_play_long = 0, key_fx = 0;
    reg [1:0] sw = 0; reg decoder_done = 0, decoder_error = 0, vblank = 0, auto_tick = 0;
    wire [7:0] image_index; wire load_req, swap_req, play_enable, auto_mode; wire [1:0] effect_sel; wire [3:0] brightness, contrast; wire error_state;
    ui_controller dut(
        .clk(clk), .rst_n(rst_n), .catalog_ready(catalog_ready), .catalog_error(catalog_error), .file_count(3),
        .key_prev(key_prev), .key_next(key_next), .key_play(key_play), .key_play_long(key_play_long), .key_fx(key_fx), .sw(sw),
        .decoder_done(decoder_done), .decoder_error(decoder_error), .vblank(vblank), .auto_tick(auto_tick),
        .image_index(image_index), .load_req(load_req), .swap_req(swap_req), .play_enable(play_enable), .auto_mode(auto_mode),
        .effect_sel(effect_sel), .brightness(brightness), .contrast(contrast), .error_state(error_state)
    );
    always #5 clk = ~clk;
    initial begin
        repeat(3) @(posedge clk); rst_n=1; catalog_ready=1;
        @(posedge clk); #1; if (!load_req) begin $display("FAIL: first image not requested"); $finish; end
        decoder_done=1; @(posedge clk); decoder_done=0; vblank=1; @(posedge clk); vblank=0;
        #1; if (!swap_req) begin $display("FAIL: no vblank swap"); $finish; end
        @(negedge clk); key_next=1; @(negedge clk); key_next=0;
        @(posedge clk); #1; if (image_index != 1 || !load_req) begin $display("FAIL: next image"); $finish; end
        $display("PASS: tb_ui_controller"); $finish;
    end
endmodule
