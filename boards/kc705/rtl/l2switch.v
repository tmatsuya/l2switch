//`timescale 1ns / 1ps
`include "../rtl/setup.v"

module l2switch # (
	parameter MaxPort = 2'h1
) (
	input	 sys_rst,
	input	 sys_clk,

	// XGMII interfaces for 4 MACs
	output [63:0] xgmii_0_txd,
	output  [7:0] xgmii_0_txc,
	input  [63:0] xgmii_0_rxd,
	input   [7:0] xgmii_0_rxc,
	input   [7:0] xphy_0_status,

	output [63:0] xgmii_1_txd,
	output  [7:0] xgmii_1_txc,
	input  [63:0] xgmii_1_rxd,
	input   [7:0] xgmii_1_rxc,
	input   [7:0] xphy_1_status,

`ifdef ENABLE_PHY2
	output [63:0] xgmii_2_txd,
	output  [7:0] xgmii_2_txc,
	input  [63:0] xgmii_2_rxd,
	input   [7:0] xgmii_2_rxc,
	input   [7:0] xphy_2_status,
`endif

`ifdef ENABLE_PHY3
	output [63:0] xgmii_3_txd,
	output  [7:0] xgmii_3_txc,
	input  [63:0] xgmii_3_rxd,
	input   [7:0] xgmii_3_rxc,
	input   [7:0] xphy_3_status,
`endif

	// ---- BUTTON
	input	 button_n,
	input	 button_s,
	input	 button_w,
	input	 button_e,
	input	 button_c,
	// ---- DIP SW
	input   [3:0] dipsw,		
	// ---- LED
	output  [7:0] led		   

);

//-----------------------------------
// RX0,RX1,RX2,RX3_PHYQ FIFO
//-----------------------------------
//
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

`ifdef SIMULATION
sfifo # (
	.DATA_WIDTH(72),
	.ADDR_WIDTH(10)
) rx0fifo (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(rx0_phyq_din),
	.full(rx0_phyq_full),
	.wr_cs(rx0_phyq_wr_en),
	.wr_en(rx0_phyq_wr_en),

	.dout(rx0_phyq_dout),
	.empty(rx0_phyq_empty),
	.rd_cs(rx0_phyq_rd_en),
	.rd_en(rx0_phyq_rd_en),

	.data_count()
);
sfifo # (
	.DATA_WIDTH(72),
	.ADDR_WIDTH(10)
) rx1fifo (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(rx1_phyq_din),
	.full(rx1_phyq_full),
	.wr_cs(rx1_phyq_wr_en),
	.wr_en(rx1_phyq_wr_en),

	.dout(rx1_phyq_dout),
	.empty(rx1_phyq_empty),
	.rd_cs(rx1_phyq_rd_en),

	.data_count()
);
`ifdef ENABLE_PHY2
sfifo # (
	.DATA_WIDTH(72),
	.ADDR_WIDTH(10)
) rx2fifo (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(rx2_phyq_din),
	.full(rx2_phyq_full),
	.wr_cs(rx2_phyq_wr_en),
	.wr_en(rx2_phyq_wr_en),

	.dout(rx2_phyq_dout),
	.empty(rx2_phyq_empty),
	.rd_cs(rx2_phyq_rd_en),

	.data_count()
);
`endif
`ifdef ENABLE_PHY3
sfifo # (
	.DATA_WIDTH(72),
	.ADDR_WIDTH(10)
) rx3fifo (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(rx3_phyq_din),
	.full(rx3_phyq_full),
	.wr_cs(rx3_phyq_wr_en),
	.wr_en(rx3_phyq_wr_en),

	.dout(rx3_phyq_dout),
	.empty(rx3_phyq_empty),
	.rd_cs(rx3_phyq_rd_en),

	.data_count()
);
`endif
`else
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
`ifdef ENABLE_PHY2
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
`endif
`ifdef ENABLE_PHY3
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
`endif

//-----------------------------------
// XGMII2FIFO72 module
//-----------------------------------
xgmii2fifo72 # (
	.Gap(4'h2)
) rx0xgmii2fifo (
	.sys_rst(sys_rst),
	.xgmii_rx_clk(sys_clk),
	.xgmii_rxd({xgmii_0_rxc,xgmii_0_rxd}),
	.din(rx0_phyq_din)
);
xgmii2fifo72 # (
	.Gap(4'h2)
) rx1xgmii2fifo (
	.sys_rst(sys_rst),
	.xgmii_rx_clk(sys_clk),
	.xgmii_rxd({xgmii_1_rxc,xgmii_1_rxd}),
	.din(rx1_phyq_din)
);
`ifdef ENABLE_PHY2
xgmii2fifo72 # (
	.Gap(4'h2)
) rx2xgmii2fifo (
	.sys_rst(sys_rst),
	.xgmii_rx_clk(sys_clk),
	.xgmii_rxd({xgmii_2_rxc,xgmii_2_rxd}),
	.din(rx2_phyq_din)
);
`endif
`ifdef ENABLE_PHY3
xgmii2fifo72 # (
	.Gap(4'h2)
) rx3xgmii2fifo (
	.sys_rst(sys_rst),
	.xgmii_rx_clk(sys_clk),
	.xgmii_rxd({xgmii_3_rxc,xgmii_3_rxd}),
	.din(rx3_phyq_din)
);
`endif

//-----------------------------------
// FIFO72TOXGMII module
//-----------------------------------
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
`ifdef ENABLE_PHY2
fifo72toxgmii tx2fifo2gmii (
	.sys_rst(sys_rst),

	.dout(),
	.empty(1'b1),
	.rd_en(),
	.rd_clk(),

	.xgmii_tx_clk(sys_clk),
	.xgmii_txd({xgmii_2_txc,xgmii_2_txd})
);
`endif
`ifdef ENABLE_PHY3
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

// XGMII control characters
// 07: Idle, FB:Start FD:Terminate FE:ERROR
//

assign led[7:4] = 4'h0;
assign led[1:0] = {xphy_1_status[0], xphy_0_status[0]};
`ifdef ENABLE_PHY2
assign led[2] = xphy_1_status[2];
`endif
`ifdef ENABLE_PHY3
assign led[3] = xphy_1_status[3];
`endif

endmodule
