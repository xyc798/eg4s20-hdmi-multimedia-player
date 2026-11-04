module hdmi_tx_eg4s20 (
    input  wire        pixel_clk,
    input  wire        serial_clk,
    input  wire        rst_n,
    input  wire        stream_sof,
    input  wire        stream_valid,
    input  wire        stream_eol,
    input  wire [23:0] stream_rgb,
    output wire        stream_ready,
    input  wire        audio_valid,
    input  wire [23:0] audio_l,
    input  wire [23:0] audio_r,
    output wire        ddc_scl,
    inout  wire        ddc_sda,
    output wire        tmds_d0_p,
    output wire        tmds_d1_p,
    output wire        tmds_d2_p,
    output wire        tmds_clk_p
);
    wire [9:0] tmds0, tmds1, tmds2, tmdsclk;
    wire acr_valid;
    wire [19:0] acr_cts, acr_n;

    audio_arc_calculate #(.ACR_N(6144)) u_acr (
        .I_clk(pixel_clk), .I_rst(~rst_n), .I_audio_valid(audio_valid),
        .O_acr_valid(acr_valid), .O_acr_cts(acr_cts), .O_acr_n(acr_n)
    );

    hdmi_1_4b_transmitter_core_wrapper #(
        .DEVICE("EG"), .HTOTAL(800), .HSA(96), .HFP(16), .HBP(48), .HACTIVE(640),
        .VTOTAL(525), .VSA(2), .VFP(10), .VBP(33), .VACTIVE(480),
        .VIDEO_VIC(1), .VIDEO_TPG("Disable"), .VIDEO_FORMAT("RGB"),
        .AUDIO_SAMPLE_RATE("48K"), .IIC_SCL_DIV(125)
    ) u_hdmi_core (
        .I_pixel_clk(pixel_clk), .I_rst(~rst_n), .I_edid_read_trig(1'b0),
        .O_edid_read_valid(), .O_edid_read_data(),
        .I_axis_s_user(stream_sof), .I_axis_s_valid(stream_valid),
        .I_axis_s_last(stream_eol), .I_axis_s_data(stream_rgb), .O_axis_s_ready(stream_ready),
        .I_audio_valid(audio_valid), .I_audio_left_data(audio_l), .I_audio_right_data(audio_r),
        .I_acr_valid(acr_valid), .I_acr_cts(acr_cts), .I_acr_n(acr_n), .O_video_locked(),
        .O_ddc_scl(ddc_scl), .IO_ddc_sda(ddc_sda),
        .O_ch0_tmds_data(tmds0), .O_ch1_tmds_data(tmds1), .O_ch2_tmds_data(tmds2), .O_clk_tmds_data(tmdsclk)
    );

    hdmi_phy_wrapper #(.DEVICE("EG")) u_phy (
        .I_pixel_clk(pixel_clk), .I_serial_clk(serial_clk), .I_rst(~rst_n),
        .I_tmds_channel_0(tmds0), .I_tmds_channel_1(tmds1), .I_tmds_channel_2(tmds2), .I_tmds_channel_clk(tmdsclk),
        .O_tmds_ch0_p(tmds_d0_p), .O_tmds_ch1_p(tmds_d1_p), .O_tmds_ch2_p(tmds_d2_p), .O_tmds_clk_p(tmds_clk_p)
    );
endmodule
