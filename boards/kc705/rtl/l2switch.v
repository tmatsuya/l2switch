//`timescale 1ns / 1ps
`include "../rtl/setup.v"
`default_nettype none

module l2switch (
	input wire sys_rst,
	input wire sys_clk,

	// XGMII interfaces for 4 MACs
	output wire [63:0] xgmii_0_txd,
	output wire  [7:0] xgmii_0_txc,
	input  wire [63:0] xgmii_0_rxd,
	input  wire  [7:0] xgmii_0_rxc,
	input  wire  [7:0] xphy_0_status,

	output wire [63:0] xgmii_1_txd,
	output wire  [7:0] xgmii_1_txc,
	input  wire [63:0] xgmii_1_rxd,
	input  wire  [7:0] xgmii_1_rxc,
	input  wire  [7:0] xphy_1_status,

`ifdef ENABLE_XGMII2
	output wire [63:0] xgmii_2_txd,
	output wire  [7:0] xgmii_2_txc,
	input  wire [63:0] xgmii_2_rxd,
	input  wire  [7:0] xgmii_2_rxc,
	input  wire  [7:0] xphy_2_status,
`endif

`ifdef ENABLE_XGMII3
	output wire [63:0] xgmii_3_txd,
	output wire  [7:0] xgmii_3_txc,
	input  wire [63:0] xgmii_3_rxd,
	input  wire  [7:0] xgmii_3_rxc,
	input  wire  [7:0] xphy_3_status,
`endif

	// GMII interface
        input  wire        gmii_0_rxclk,
        input  wire        gmii_0_rxdv,
        input  wire  [7:0] gmii_0_rxd,
        input  wire        gmii_0_gtxclk,
        output wire        gmii_0_txen,
        output wire  [7:0] gmii_0_txd,

	// ---- BUTTON
	input  wire  button_n,
	input  wire  button_s,
	input  wire  button_w,
	input  wire  button_e,
	input  wire  button_c,
	// ---- DIP SW
	input  wire [3:0] dipsw,		
	// ---- LED
	output wire [7:0] led		   
);

wire  [71:0] xgmii_0_rx, xgmii_1_rx, xgmii_2_rx, xgmii_2_rx, xgmii_3_rx, xgmii_4_rx, xgmii_5_rx;

//-----------------------------------
// RX0,RX1,RX2,RX3_XGMIIQ FIFO
//-----------------------------------
wire [71:0] rx0_phyq_din, rx0_phyq_dout;
wire rx0_phyq_full, rx0_phyq_wr_en;
wire rx0_phyq_empty, rx0_phyq_rd_en;

wire [71:0] rx1_phyq_din, rx1_phyq_dout;
wire rx1_phyq_full, rx1_phyq_wr_en;
wire rx1_phyq_empty, rx1_phyq_rd_en;

wire [71:0] rx2_phyq_din, rx2_phyq_dout;
wire rx2_phyq_full, rx2_phyq_wr_en;
wire rx2_phyq_empty, rx2_phyq_rd_en;

wire [71:0] rx3_phyq_din, rx3_phyq_dout;
wire rx3_phyq_full, rx3_phyq_wr_en;
wire rx3_phyq_empty, rx3_phyq_rd_en;

`ifdef NO
sfifo72_10 rx0fifo (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(rx0_phyq_din),
	.full(rx0_phyq_full),
	.wr_en(rx0_phyq_wr_en),

	.dout(rx0_phyq_dout),
	.empty(rx0_phyq_empty),
	.rd_en(rx0_phyq_rd_en)
);
sfifo72_10 rx1fifo (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(rx1_phyq_din),
	.full(rx1_phyq_full),
	.wr_en(rx1_phyq_wr_en),

	.dout(rx1_phyq_dout),
	.empty(rx1_phyq_empty),
	.rd_en(rx1_phyq_rd_en)
);
sfifo72_10 rx2fifo (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(rx2_phyq_din),
	.full(rx2_phyq_full),
	.wr_en(rx2_phyq_wr_en),

	.dout(rx2_phyq_dout),
	.empty(rx2_phyq_empty),
	.rd_en(rx2_phyq_rd_en)
);
sfifo72_10 rx3fifo (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(rx3_phyq_din),
	.full(rx3_phyq_full),
	.wr_en(rx3_phyq_wr_en),

	.dout(rx3_phyq_dout),
	.empty(rx3_phyq_empty),
	.rd_en(rx3_phyq_rd_en)
);
`endif

//-----------------------------------
// XGMII2FIFO72 module
//-----------------------------------
xgmii2fifo72 rx0xgmii2fifo (
	.sys_rst(sys_rst),
	.xgmii_rx_clk(sys_clk),
	.xgmii_rxd({xgmii_0_rxc,xgmii_0_rxd}),
	.din(xgmii_0_rx)
);
xgmii2fifo72 rx1xgmii2fifo (
	.sys_rst(sys_rst),
	.xgmii_rx_clk(sys_clk),
	.xgmii_rxd({xgmii_1_rxc,xgmii_1_rxd}),
	.din(xgmii_1_rx)
);
`ifdef ENABLE_XGMII2
xgmii2fifo72 rx2xgmii2fifo (
	.sys_rst(sys_rst),
	.xgmii_rx_clk(sys_clk),
	.xgmii_rxd({xgmii_2_rxc,xgmii_2_rxd}),
	.din(xgmii_2_rx)
);
`endif
`ifdef ENABLE_XGMII3
xgmii2fifo72 rx3xgmii2fifo (
	.sys_rst(sys_rst),
	.xgmii_rx_clk(sys_clk),
	.xgmii_rxd({xgmii_3_rxc,xgmii_3_rxd}),
	.din(xgmii_3_rx)
);
`endif
`ifdef NO
xgmii2fifo72 rx4xgmii2fifo (
	.sys_rst(sys_rst),
	.xgmii_rx_clk(sys_clk),
	.xgmii_rxd({xgmii_4_rxc,xgmii_4_rxd}),
	.din(xgmii_4_rx)
);
`endif

//-----------------------------------
// FIFO72TOXGMII module
//-----------------------------------
`ifdef NO
fifo72toxgmii tx0fifo2gmii (
	.sys_rst(sys_rst),

	.dout(rx1_phyq_dout),
	.empty(rx1_phyq_empty),
	.rd_en(rx1_phyq_rd_en),
	.rd_clk(),

	.xgmii_tx_clk(sys_clk),
	.xgmii_txd({xgmii_0_txc,xgmii_0_txd})
);
fifo72toxgmii tx1fifo2gmii (
	.sys_rst(sys_rst),

	.dout(rx0_phyq_dout),
	.empty(rx0_phyq_empty),
	.rd_en(rx0_phyq_rd_en),
	.rd_clk(),

	.xgmii_tx_clk(sys_clk),
	.xgmii_txd({xgmii_1_txc,xgmii_1_txd})
);
fifo72toxgmii tx2fifo2gmii (
	.sys_rst(sys_rst),

	.dout(),
	.empty(1'b1),
	.rd_en(),
	.rd_clk(),

	.xgmii_tx_clk(sys_clk),
	.xgmii_txd({xgmii_2_txc,xgmii_2_txd})
);
fifo72toxgmii tx3fifo2gmii (
	.sys_rst(sys_rst),

	.dout(),
	.empty(1'b1),
	.rd_en(),
	.rd_clk(),

	.xgmii_tx_clk(sys_clk),
	.xgmii_txd({xgmii_3_txc,xgmii_3_txd})
);
`endif

//-----------------------------------
// GMII to XGMII module
//-----------------------------------
gmii2xgmii gmii2xgmii_inst_0 (
	.sys_rst(sys_rst),
	.gmii_clk(gmii_0_rxclk),
	.gmii_dv(gmii_0_rxdv),
	.gmii_rxd(gmii_0_rxd),
	.xgmii_clk(sys_clk),
	.xgmii_rxc(xgmii_5_rx[71:64]),
	.xgmii_rxd(xgmii_5_rx[63:0])
);


// XGMII control characters
// 07: Idle, FB:Start FD:Terminate FE:ERROR

//-----------------------------------
// forwader RX0
//-----------------------------------
`ifdef NO
forwader rx0forwader (
	.sys_rst(sys_rst),
	.sys_clk(sys_clk),
	.xgmii_rx(xgmii_0_rx),
	.port0_din(),
	.port0_full(),
	.port0_half(),
	.port0_wr_en(),
	.port1_din(rx0tx1_din),
	.port1_full(rx0tx1_full),
	.port1_half(rx0tx1_data_count[11]),
	.port1_wr_en(rx0tx1_wr_en),
	.port2_din(rx0tx2_din),
	.port2_full(rx0tx2_full),
	.port2_half(rx0tx2_data_count[11]),
	.port2_wr_en(rx0tx2_wr_en),
	.port3_din(rx0tx3_din),
	.port3_full(rx0tx3_full),
	.port3_half(rx0tx3_data_count[11]),
	.port3_wr_en(rx0tx3_wr_en),
);
`endif
assign xgmii_0_txc = xgmii_1_rx[71:64];
assign xgmii_0_txd = xgmii_1_rx[63: 0];
assign xgmii_1_txc = xgmii_0_rx[71:64];
assign xgmii_1_txd = xgmii_0_rx[63: 0];
`ifdef ENABLE_XGMII2
assign xgmii_2_txc = xgmii_3_rx[71:64];
assign xgmii_2_txd = xgmii_3_rx[63: 0];
`endif
`ifdef ENABLE_XGMII3
assign xgmii_3_txc = xgmii_2_rx[71:64];
assign xgmii_3_txd = xgmii_2_rx[63: 0];
`endif

assign led[7:4] = 4'h0;
assign led[1:0] = {xphy_1_status[0], xphy_0_status[0]};
`ifdef ENABLE_XGMII2
assign led[2]   = xphy_2_status[0];
`endif
`ifdef ENABLE_XGMII3
assign led[3]   = xphy_3_status[0];
`endif

endmodule
`default_nettype wire
