`timescale 1ns/1ps

module tb_sync_fifo;
    reg clk = 0;
    reg rst_n = 0;
    reg wr_en = 0;
    reg [7:0] wr_data = 0;
    reg rd_en = 0;
    wire full;
    wire [7:0] rd_data;
    wire empty;
    wire [2:0] level;

    sync_fifo #(.WIDTH(8), .DEPTH(4)) dut (
        .clk(clk), .rst_n(rst_n), .wr_en(wr_en), .wr_data(wr_data),
        .full(full), .rd_en(rd_en), .rd_data(rd_data), .empty(empty), .level(level)
    );

    always #5 clk = ~clk;

    task push(input [7:0] value);
    begin
        @(negedge clk); wr_en = 1; wr_data = value;
        @(negedge clk); wr_en = 0;
    end
    endtask

    task pop_expect(input [7:0] value);
    begin
        @(negedge clk); rd_en = 1;
        @(posedge clk); #1;
        if (rd_data !== value) begin
            $display("FAIL: expected %h, got %h", value, rd_data);
            $finish;
        end
        @(negedge clk); rd_en = 0;
    end
    endtask

    initial begin
        repeat (3) @(posedge clk);
        rst_n = 1;
        if (!empty || level != 0) begin $display("FAIL: reset state"); $finish; end
        push(8'h11); push(8'h22); push(8'h33); push(8'h44);
        if (!full || level != 4) begin $display("FAIL: full state"); $finish; end
        pop_expect(8'h11); pop_expect(8'h22); pop_expect(8'h33); pop_expect(8'h44);
        if (!empty || level != 0) begin $display("FAIL: empty state"); $finish; end
        $display("PASS: tb_sync_fifo");
        $finish;
    end
endmodule
