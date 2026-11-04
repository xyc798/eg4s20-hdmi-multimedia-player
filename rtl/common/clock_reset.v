module clock_reset (
    input  wire clk,
    input  wire pll_lock,
    output reg  rst_n
);
    reg [3:0] release_count;
    always @(posedge clk or negedge pll_lock) begin
        if (!pll_lock) begin
            release_count <= 0;
            rst_n <= 1'b0;
        end else if (&release_count) begin
            rst_n <= 1'b1;
        end else begin
            release_count <= release_count + 1'b1;
            rst_n <= 1'b0;
        end
    end
endmodule
