module eg4s20_hdmi_player_top (
    input  wire       clk_50m,
    input  wire [3:0] key_n,
    input  wire [1:0] sw,
    output wire       sd_cs_n,
    output wire       sd_clk,
    output wire       sd_mosi,
    input  wire       sd_miso,
    output wire       hdmib_d2_p,
    output wire       hdmib_d1_p,
    output wire       hdmib_d0_p,
    output wire       hdmib_clk_p,
    output wire       hdmib_scl,
    inout  wire       hdmib_sda,
    input  wire       hdmib_hpd
);
    wire pixel_clk, serial_clk, pll_lock, rst_n;
    wire [10:0] x,y;
    wire de,hs,vs,sof,eol,vblank;
    wire [23:0] rgb;
    wire stream_valid, stream_ready;

    // Generated in Tang Dynasty: 50 MHz -> 25 MHz and 125 MHz.
    pll_hdmi_640x480 u_pll (
        .refclk(clk_50m), .reset(1'b0), .lock(pll_lock), .clk0_out(pixel_clk), .clk1_out(serial_clk)
    );
    clock_reset u_reset(.clk(pixel_clk), .pll_lock(pll_lock), .rst_n(rst_n));
    video_timing u_timing(.clk(pixel_clk), .rst_n(rst_n), .x(x), .y(y), .de(de), .hs(hs), .vs(vs), .sof(sof), .eol(eol), .vblank(vblank));
    video_mixer u_mixer(.clk(pixel_clk), .rst_n(rst_n), .x(x), .y(y), .de(de), .fb_valid(1'b0), .fb_pixel(16'h0), .brightness(sw[0]?4'd10:4'd8), .contrast(sw[1]?4'd10:4'd8), .rgb(rgb), .valid(stream_valid));
    hdmi_tx_eg4s20 u_hdmi(
        .pixel_clk(pixel_clk), .serial_clk(serial_clk), .rst_n(rst_n), .stream_sof(sof), .stream_valid(stream_valid), .stream_eol(eol), .stream_rgb(rgb), .stream_ready(stream_ready),
        .audio_valid(1'b0), .audio_l(24'd0), .audio_r(24'd0), .ddc_scl(hdmib_scl), .ddc_sda(hdmib_sda),
        .tmds_d0_p(hdmib_d0_p), .tmds_d1_p(hdmib_d1_p), .tmds_d2_p(hdmib_d2_p), .tmds_clk_p(hdmib_clk_p)
    );
    assign sd_cs_n = 1'b1;
    assign sd_clk = 1'b0;
    assign sd_mosi = 1'b1;
endmodule
