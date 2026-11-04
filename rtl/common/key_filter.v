module key_filter #(
    parameter STABLE_CYCLES = 250000,
    parameter LONG_CYCLES = 25000000
) (
    input  wire clk,
    input  wire rst_n,
    input  wire key_n,
    output reg  press_pulse,
    output reg  long_press_pulse
);
    reg key_meta, key_sync, stable_key;
    integer stable_count;
    integer hold_count;
    reg long_sent;

    always @(posedge clk) begin
        if (!rst_n) begin
            key_meta <= 1'b1;
            key_sync <= 1'b1;
            stable_key <= 1'b1;
            stable_count <= 0;
            hold_count <= 0;
            long_sent <= 1'b0;
            press_pulse <= 1'b0;
            long_press_pulse <= 1'b0;
        end else begin
            key_meta <= key_n;
            key_sync <= key_meta;
            press_pulse <= 1'b0;
            long_press_pulse <= 1'b0;
            if (key_sync != stable_key) begin
                if (stable_count >= STABLE_CYCLES - 1) begin
                    stable_key <= key_sync;
                    stable_count <= 0;
                    if (!key_sync) begin
                        press_pulse <= 1'b1;
                        hold_count <= 0;
                        long_sent <= 1'b0;
                    end else begin
                        hold_count <= 0;
                        long_sent <= 1'b0;
                    end
                end else begin
                    stable_count <= stable_count + 1;
                end
            end else begin
                stable_count <= 0;
                if (!stable_key && !long_sent) begin
                    if (hold_count >= LONG_CYCLES - 1) begin
                        long_press_pulse <= 1'b1;
                        long_sent <= 1'b1;
                    end else begin
                        hold_count <= hold_count + 1;
                    end
                end
            end
        end
    end
endmodule
