`timescale 1ns/1ps
module tb_sdram_arbiter;
    reg clk=0, rst_n=0, d_req=0, a_req=0, w_req=0, mem_ready=1, mem_rvalid=0;
    reg [15:0] mem_rdata=0; wire d_take,a_take,w_take,mem_rd,mem_wr; wire [22:0] mem_addr; wire [15:0] mem_wdata;
    sdram_arbiter dut(.clk(clk),.rst_n(rst_n),.display_req(d_req),.display_addr(1),.display_take(d_take),.audio_req(a_req),.audio_addr(2),.audio_take(a_take),.write_req(w_req),.write_addr(3),.write_data(16'h55aa),.write_take(w_take),.mem_ready(mem_ready),.mem_rvalid(mem_rvalid),.mem_rdata(mem_rdata),.mem_rd(mem_rd),.mem_wr(mem_wr),.mem_addr(mem_addr),.mem_wdata(mem_wdata));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); rst_n=1; d_req=1; a_req=1; w_req=1;
        @(posedge clk); #1;
        if (!d_take || a_take || w_take || !mem_rd || mem_addr != 1) begin $display("FAIL: display priority"); $finish; end
        $display("PASS: tb_sdram_arbiter"); $finish;
    end
endmodule
