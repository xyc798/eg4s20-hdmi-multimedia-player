module audio_arc_calculate #(
    parameter ACR_N = 6144
) (
    input  wire       I_clk,
    input  wire       I_rst,
    input  wire       I_audio_valid,
    output reg        O_acr_valid,
    output reg [19:0] O_acr_cts,
    output reg [19:0] O_acr_n
);
    localparam AUDIO_DIV = ACR_N >> 7;
    reg [7:0] audio_div_count;
    reg [19:0] cts_count;
    wire acr_tick = I_audio_valid && (audio_div_count == AUDIO_DIV - 1);

    always @(posedge I_clk or posedge I_rst) begin
        if (I_rst)
            audio_div_count <= 0;
        else if (I_audio_valid)
            audio_div_count <= acr_tick ? 0 : audio_div_count + 1'b1;
    end

    always @(posedge I_clk or posedge I_rst) begin
        if (I_rst)
            cts_count <= 0;
        else if (acr_tick)
            cts_count <= 0;
        else
            cts_count <= cts_count + 1'b1;
    end

    always @(posedge I_clk or posedge I_rst) begin
        if (I_rst) begin
            O_acr_valid <= 0;
            O_acr_cts <= 0;
            O_acr_n <= 0;
        end else if (acr_tick) begin
            O_acr_valid <= 1'b1;
            O_acr_cts <= cts_count + 1'b1;
            O_acr_n <= ACR_N;
        end else begin
            O_acr_valid <= 0;
            O_acr_cts <= 0;
            O_acr_n <= 0;
        end
    end
endmodule
