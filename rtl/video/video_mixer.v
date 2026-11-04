module video_mixer (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [10:0] x,
    input  wire [10:0] y,
    input  wire        de,
    input  wire        fb_valid,
    input  wire [15:0] fb_pixel,
    input  wire [3:0]  brightness,
    input  wire [3:0]  contrast,
    output reg  [23:0] rgb,
    output reg         valid
);
    reg [7:0] r, g, b;
    reg [8:0] r_adj, g_adj, b_adj;
    always @(*) begin
        if (fb_valid) begin
            r = {fb_pixel[15:11],fb_pixel[15:13]};
            g = {fb_pixel[10:5],fb_pixel[10:9]};
            b = {fb_pixel[4:0],fb_pixel[4:2]};
        end else begin
            case (x[9:7])
                0: begin r=8'hff; g=0; b=0; end
                1: begin r=8'hff; g=8'hff; b=0; end
                2: begin r=0; g=8'hff; b=0; end
                3: begin r=0; g=8'hff; b=8'hff; end
                4: begin r=0; g=0; b=8'hff; end
                5: begin r=8'hff; g=0; b=8'hff; end
                6: begin r=8'hff; g=8'hff; b=8'hff; end
                default: begin r=8'h20; g=8'h20; b=8'h20; end
            endcase
        end
        r_adj = r + ((brightness - 8) << 4);
        g_adj = g + ((brightness - 8) << 4);
        b_adj = b + ((brightness - 8) << 4);
    end
    function [7:0] saturate;
        input [8:0] value;
        begin saturate = value[8] ? 8'hff : value[7:0]; end
    endfunction
    always @(posedge clk) begin
        if (!rst_n) begin rgb<=0; valid<=0; end
        else begin
            valid <= de;
            rgb <= {saturate(r_adj),saturate(g_adj),saturate(b_adj)};
        end
    end
endmodule
