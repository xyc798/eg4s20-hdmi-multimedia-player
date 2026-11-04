module bmp_decoder (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [22:0] fb_base,
    input  wire        byte_valid,
    input  wire [7:0]  byte_data,
    input  wire        file_done,
    output reg         wr_valid,
    output reg  [22:0] wr_addr,
    output reg  [15:0] wr_data,
    output reg         wr_last,
    output reg         decode_done,
    output reg         decode_error
);
    reg active, header_ok;
    reg [31:0] pos, pixel_offset;
    reg [15:0] width, height, col, row;
    reg [15:0] row_pad, pad_left;
    reg [1:0] pixel_byte;
    reg [7:0] b, g;
    reg top_down;
    reg [7:0] sig0, sig1, bpp0, bpp1, cmp0, cmp1, cmp2, cmp3;
    reg [7:0] w0,w1,h0,h1,h2,h3;

    always @(posedge clk) begin
        if (!rst_n) begin
            active<=0; header_ok<=0; pos<=0; pixel_offset<=0; width<=0; height<=0; col<=0; row<=0;
            row_pad<=0; pad_left<=0; pixel_byte<=0; wr_valid<=0; wr_last<=0; decode_done<=0; decode_error<=0;
        end else begin
            wr_valid<=0; wr_last<=0;
            if (start) begin
                active<=1; header_ok<=0; pos<=0; col<=0; row<=0; pixel_byte<=0; pad_left<=0;
                decode_done<=0; decode_error<=0;
            end
            if (active && byte_valid) begin
                case(pos)
                    0: sig0<=byte_data; 1: sig1<=byte_data;
                    10: pixel_offset[7:0]<=byte_data; 11: pixel_offset[15:8]<=byte_data;
                    12: pixel_offset[23:16]<=byte_data; 13: pixel_offset[31:24]<=byte_data;
                    18: w0<=byte_data; 19: w1<=byte_data;
                    22: h0<=byte_data; 23: h1<=byte_data; 24: h2<=byte_data; 25: h3<=byte_data;
                    28: bpp0<=byte_data; 29: bpp1<=byte_data;
                    30: cmp0<=byte_data; 31: cmp1<=byte_data; 32: cmp2<=byte_data; 33: cmp3<=byte_data;
                endcase
                if (pos == 34) begin
                    width <= {w1,w0};
                    top_down <= h3[7];
                    height <= h3[7] ? (~{h1,h0}+1'b1) : {h1,h0};
                    row_pad <= (({w1,w0} * 3 + 3) & 16'hfffc) - ({w1,w0} * 3);
                    if (sig0 != "B" || sig1 != "M" || {bpp1,bpp0} != 24 || {cmp3,cmp2,cmp1,cmp0} != 0 || {w1,w0} == 0 || {h1,h0} == 0) begin
                        active<=0; decode_error<=1;
                    end else header_ok<=1;
                end
                if (header_ok && pos >= pixel_offset) begin
                    if (pad_left != 0) begin
                        pad_left <= pad_left - 1'b1;
                    end else begin
                        case (pixel_byte)
                            0: begin b<=byte_data; pixel_byte<=1; end
                            1: begin g<=byte_data; pixel_byte<=2; end
                            default: begin
                                wr_valid<=1;
                                wr_data<={byte_data[7:3],g[7:2],b[7:3]};
                                if (row==0 && col==0)
                                    wr_addr <= top_down ? fb_base : fb_base + ((height-1'b1) * width * 2);
                                else if (col==0)
                                    wr_addr <= top_down ? wr_addr : wr_addr - ((width<<2)-2);
                                else
                                    wr_addr <= wr_addr + 2;
                                pixel_byte<=0;
                                if (col == width-1'b1) begin
                                    col<=0; row<=row+1'b1; pad_left<=row_pad;
                                    if (row == height-1'b1) begin
                                        wr_last<=1; decode_done<=1; active<=0;
                                    end
                                end else col<=col+1'b1;
                            end
                        endcase
                    end
                end
                pos <= pos + 1'b1;
            end
            if (active && file_done && !decode_done) begin active<=0; decode_error<=1; end
        end
    end
endmodule
