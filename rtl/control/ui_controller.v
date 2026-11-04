module ui_controller (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       catalog_ready,
    input  wire       catalog_error,
    input  wire [7:0] file_count,
    input  wire       key_prev,
    input  wire       key_next,
    input  wire       key_play,
    input  wire       key_play_long,
    input  wire       key_fx,
    input  wire [1:0] sw,
    input  wire       decoder_done,
    input  wire       decoder_error,
    input  wire       vblank,
    input  wire       auto_tick,
    output reg  [7:0] image_index,
    output reg        load_req,
    output reg        swap_req,
    output reg        play_enable,
    output reg        auto_mode,
    output reg  [1:0] effect_sel,
    output wire [3:0] brightness,
    output wire [3:0] contrast,
    output wire       error_state
);
    localparam BOOT=3'd0, LOAD=3'd1, WAIT_DONE=3'd2, WAIT_VBLANK=3'd3, SHOW=3'd4, ERROR=3'd5;
    reg [2:0] state;
    assign brightness = sw[0] ? 4'd10 : 4'd8;
    assign contrast = sw[1] ? 4'd10 : 4'd8;
    assign error_state = (state == ERROR);

    function [7:0] next_index;
        input [7:0] index;
        begin
            if (file_count == 0 || index + 1 >= file_count) next_index = 0;
            else next_index = index + 1'b1;
        end
    endfunction
    function [7:0] prev_index;
        input [7:0] index;
        begin
            if (file_count == 0) prev_index = 0;
            else if (index == 0) prev_index = file_count - 1'b1;
            else prev_index = index - 1'b1;
        end
    endfunction

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= BOOT;
            image_index <= 0;
            load_req <= 0;
            swap_req <= 0;
            play_enable <= 1'b1;
            auto_mode <= 1'b1;
            effect_sel <= 0;
        end else begin
            load_req <= 1'b0;
            swap_req <= 1'b0;
            if (key_fx) effect_sel <= (effect_sel == 2) ? 0 : effect_sel + 1'b1;
            if (key_play) play_enable <= ~play_enable;
            if (key_play_long) auto_mode <= ~auto_mode;
            case (state)
                BOOT: begin
                    if (catalog_error || file_count == 0) state <= ERROR;
                    else if (catalog_ready) begin load_req <= 1'b1; state <= WAIT_DONE; end
                end
                WAIT_DONE: begin
                    if (decoder_error) state <= ERROR;
                    else if (decoder_done) state <= WAIT_VBLANK;
                end
                WAIT_VBLANK: if (vblank) begin swap_req <= 1'b1; state <= SHOW; end
                SHOW: begin
                    if (key_prev) begin image_index <= prev_index(image_index); load_req <= 1'b1; state <= WAIT_DONE; end
                    else if (key_next || (auto_tick && auto_mode && play_enable)) begin image_index <= next_index(image_index); load_req <= 1'b1; state <= WAIT_DONE; end
                end
                default: state <= ERROR;
            endcase
        end
    end
endmodule
