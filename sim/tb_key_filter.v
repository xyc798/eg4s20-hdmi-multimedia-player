`timescale 1ns/1ps
module tb_key_filter;
    reg clk = 0, rst_n = 0, key_n = 1;
    wire press_pulse, long_press_pulse;
    integer pulses = 0;
    key_filter #(.STABLE_CYCLES(3), .LONG_CYCLES(8)) dut (
        .clk(clk), .rst_n(rst_n), .key_n(key_n), .press_pulse(press_pulse), .long_press_pulse(long_press_pulse)
    );
    always #5 clk = ~clk;
    always @(posedge clk) if (press_pulse) pulses = pulses + 1;
    initial begin
        repeat(3) @(posedge clk); rst_n = 1;
        key_n = 0; @(posedge clk); key_n = 1; @(posedge clk); key_n = 0;
        repeat(5) @(posedge clk);
        if (pulses != 1) begin $display("FAIL: debounce pulses=%0d", pulses); $finish; end
        repeat(8) @(posedge clk);
        if (!long_press_pulse) begin $display("FAIL: long press missing"); $finish; end
        key_n = 1; repeat(5) @(posedge clk);
        $display("PASS: tb_key_filter"); $finish;
    end
endmodule
