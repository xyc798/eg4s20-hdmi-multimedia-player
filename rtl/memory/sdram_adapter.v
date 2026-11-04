


`define   DATA_WIDTH                        32
`define   ADDR_WIDTH                        21
`define   DM_WIDTH                          4

`define   ROW_WIDTH                        11
`define   BA_WIDTH                        2

`define	  SDR_CLK_PERIOD				1000000000/150000000
`define   SELF_REFRESH_INTERVAL			64000000/`SDR_CLK_PERIOD/2**(`ROW_WIDTH)


module sdram_adapter (
    input  wire        clk,
    input  wire        clk_shift,
    input  wire        rst_n,
    input  wire        wr_valid,
    input  wire [22:0] wr_addr,
    input  wire [15:0] wr_data,
    output wire        wr_ready,
    input  wire        rd_valid,
    input  wire [22:0] rd_addr,
    output wire        rd_ready,
    output wire        rvalid,
    output wire [15:0] rdata
);
    wire init_done, refresh_valid, sdr_busy, sdr_rd_valid;
    wire [31:0] sdr_rd_data;
    reg rd_upper;
    wire [31:0] app_wr_data = wr_addr[1] ? {wr_data, 16'h0000} : {16'h0000, wr_data};
    wire [3:0] app_wr_dm = wr_addr[1] ? 4'b0011 : 4'b1100;

    always @(posedge clk) begin
        if (!rst_n)
            rd_upper <= 1'b0;
        else if (rd_valid && rd_ready)
            rd_upper <= rd_addr[1];
    end

    assign wr_ready = init_done && !sdr_busy;
    assign rd_ready = init_done && !sdr_busy;
    assign rvalid = sdr_rd_valid;
    assign rdata = rd_upper ? sdr_rd_data[31:16] : sdr_rd_data[15:0];

    sdr_as_ram #(.self_refresh_open(1'b1)) u_sdram (
        .Sdr_clk(clk), .Sdr_clk_sft(clk_shift), .Rst(~rst_n),
        .Sdr_init_done(init_done), .Sdr_init_ref_vld(refresh_valid), .Sdr_busy(sdr_busy), .App_ref_req(1'b0),
        .App_wr_en(wr_valid && wr_ready), .App_wr_addr(wr_addr[22:2]), .App_wr_dm(app_wr_dm), .App_wr_din(app_wr_data),
        .App_rd_en(rd_valid && rd_ready), .App_rd_addr(rd_addr[22:2]), .Sdr_rd_en(sdr_rd_valid), .Sdr_rd_dout(sdr_rd_data),
        .SDRAM_CLK(), .SDR_RAS(), .SDR_CAS(), .SDR_WE(), .SDR_BA(), .SDR_ADDR(), .SDR_DM(), .SDR_DQ()
    );
endmodule
