module video_timing #(
    parameter HACTIVE = 640,
    parameter HFP     = 16,
    parameter HSYNC   = 96,
    parameter HBP     = 48,
    parameter VACTIVE = 480,
    parameter VFP     = 10,
    parameter VSYNC   = 2,
    parameter VBP     = 33
) (
    input  wire        clk,
    input  wire        rst_n,
    output wire [10:0] x,
    output wire [10:0] y,
    output wire        de,
    output wire        hs,
    output wire        vs,
    output wire        sof,
    output wire        eol,
    output wire        vblank
);
    localparam HTOTAL = HACTIVE + HFP + HSYNC + HBP;
    localparam VTOTAL = VACTIVE + VFP + VSYNC + VBP;
    reg [10:0] hcnt;
    reg [10:0] vcnt;

    always @(posedge clk) begin
        if (!rst_n) begin
            hcnt <= 0;
            vcnt <= 0;
        end else if (hcnt == HTOTAL - 1) begin
            hcnt <= 0;
            if (vcnt == VTOTAL - 1)
                vcnt <= 0;
            else
                vcnt <= vcnt + 1'b1;
        end else begin
            hcnt <= hcnt + 1'b1;
        end
    end

    assign x = hcnt;
    assign y = vcnt;
    assign de = (hcnt < HACTIVE) && (vcnt < VACTIVE);
    assign hs = !((hcnt >= HACTIVE + HFP) && (hcnt < HACTIVE + HFP + HSYNC));
    assign vs = !((vcnt >= VACTIVE + VFP) && (vcnt < VACTIVE + VFP + VSYNC));
    assign sof = (hcnt == 0) && (vcnt == 0);
    assign eol = (hcnt == HACTIVE - 1) && (vcnt < VACTIVE);
    assign vblank = (vcnt >= VACTIVE);
endmodule
