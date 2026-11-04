module frame_buffer_ctrl #(
    parameter FRAME_BYTES = 23'd614400
) (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        frame_ready,
    input  wire        swap_req,
    input  wire        vblank,
    output reg  [22:0] display_base,
    output reg  [22:0] write_base,
    output reg         swap_done
);
    reg pending;
    always @(posedge clk) begin
        if (!rst_n) begin
            display_base <= 0;
            write_base <= FRAME_BYTES;
            pending <= 0;
            swap_done <= 0;
        end else begin
            swap_done <= 0;
            if (frame_ready && swap_req) pending <= 1'b1;
            if (pending && vblank) begin
                display_base <= write_base;
                write_base <= display_base;
                pending <= 1'b0;
                swap_done <= 1'b1;
            end
        end
    end
endmodule
