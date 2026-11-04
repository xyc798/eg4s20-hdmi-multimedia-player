`timescale 1ns/1ps
module tb_bmp_decoder;
    reg clk=0,rst_n=0,start=0,byte_valid=0,file_done=0; reg [7:0] byte_data=0;
    wire [15:0] wr_data; wire [22:0] wr_addr; wire wr_valid,wr_last,decode_done,decode_error;
    bmp_decoder dut(.clk(clk),.rst_n(rst_n),.start(start),.fb_base(0),.byte_valid(byte_valid),.byte_data(byte_data),.file_done(file_done),.wr_valid(wr_valid),.wr_addr(wr_addr),.wr_data(wr_data),.wr_last(wr_last),.decode_done(decode_done),.decode_error(decode_error));
    always #5 clk=~clk;
    task send(input [7:0] b); begin @(negedge clk); byte_valid=1; byte_data=b; @(negedge clk); byte_valid=0; end endtask
    integer i; reg [7:0] h [0:53]; reg seen=0; reg [15:0] seen_data=0;
    always @(posedge clk) if(wr_valid) begin seen=1; seen_data=wr_data; end
    initial begin
        for(i=0;i<54;i=i+1) h[i]=0;
        h[0]=8'h42; h[1]=8'h4d; h[10]=54; h[14]=40; h[18]=1; h[22]=1; h[26]=1; h[28]=24;
        repeat(2) @(posedge clk); rst_n=1; start=1; @(posedge clk); start=0;
        for(i=0;i<54;i=i+1) send(h[i]);
        send(8'h00); send(8'h00); send(8'hff);
        @(posedge clk); #1;
        if(!seen || seen_data != 16'hf800 || !decode_done || decode_error) begin $display("FAIL: BMP red pixel"); $finish; end
        $display("PASS: tb_bmp_decoder"); $finish;
    end
endmodule
