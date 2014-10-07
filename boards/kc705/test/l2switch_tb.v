`timescale 1ps / 1ps
`define SIMULATION
`include "../rtl/setup.v"
module l2switch_tb();

/* 125 and 156.25MHz clock */
reg clk156, clk125;
initial begin
	clk125 = 0;
	clk156 = 0;
end
always #8  clk156 = ~clk156;
always #10 clk125 = ~clk125;
reg sys_rst;

// XGMII interfaces for 4 MACs
wire [63:0] xgmii_0_txd;
wire [7:0]  xgmii_0_txc;
reg  [63:0] xgmii_0_rxd;
reg  [7:0]  xgmii_0_rxc;

`ifdef ENABLE_XGMII1
wire [63:0] xgmii_1_txd;
wire [7:0]  xgmii_1_txc;
reg  [63:0] xgmii_1_rxd;
reg  [7:0]  xgmii_1_rxc;
`endif

`ifdef ENABLE_XGMII2
wire [63:0] xgmii_2_txd;
wire [7:0]  xgmii_2_txc;
reg  [63:0] xgmii_2_rxd;
reg  [7:0]  xgmii_2_rxc;
`endif

`ifdef ENABLE_XGMII3
wire [63:0] xgmii_3_txd;
wire [7:0]  xgmii_3_txc;
wire [63:0] xgmii_3_rxd;
wire [7:0]  xgmii_3_rxc;
`endif

`ifdef ENABLE_GMII0
wire [7:0]  gmii_0_txd;
wire        gmii_0_txen;
`endif

// LED and Switches
reg [7:0] dipsw;
wire [7:0] led;

/* XGMII test */
reg [71:0] xgmii_rom [0:4095];
reg [11:0] xgmii_counter;
wire [71:0] xgmii_cur;
assign xgmii_cur = xgmii_rom[ xgmii_counter ];

/* GMII test */
reg  [8:0] gmii_rom [0:4095];
reg [11:0] gmii_counter;
wire  [8:0] gmii_cur;
assign gmii_cur = gmii_rom[ gmii_counter ];

l2switch l2switch_inst (
         .sys_rst   (sys_rst),
         .sys_clk   (clk156),

	// XGMII interfaces for 4 MACs
	.xgmii_0_txd(xgmii_0_txd),
	.xgmii_0_txc(xgmii_0_txc),
	.xgmii_0_rxd(xgmii_cur[63:0]),
	.xgmii_0_rxc(xgmii_cur[71:64]),

`ifdef ENABLE_XGMII1
	.xgmii_1_txd(xgmii_1_txd),
	.xgmii_1_txc(xgmii_1_txc),
	.xgmii_1_rxd(xgmii_1_rxd),
	.xgmii_1_rxc(xgmii_1_rxc),
`endif

`ifdef ENABLE_XGMII2
	.xgmii_2_txd(xgmii_2_txd),
	.xgmii_2_txc(xgmii_2_txc),
	.xgmii_2_rxd(xgmii_2_rxd),
	.xgmii_2_rxc(xgmii_2_rxc),
`endif

`ifdef ENABLE_XGMII3
	.xgmii_3_txd(xgmii_3_txd),
	.xgmii_3_txc(xgmii_3_txc),
	.xgmii_3_rxd(xgmii_3_rxd),
	.xgmii_3_rxc(xgmii_3_rxc),
`endif

`ifdef ENABLE_GMII0
	// GMII interface
	.gmii_0_rxclk(clk125),
	.gmii_0_rxdv(gmii_cur[8:8]),
	.gmii_0_rxd(gmii_cur[7:0]),
	.gmii_0_gtxclk(clk125),
	.gmii_0_txen(gmii_0_txen),
	.gmii_0_txd(gmii_0_txd),
`endif

	.button_n(1'b0),
	.button_s(1'b0),
	.button_w(1'b0),
	.button_e(1'b0),
	.button_c(1'b0),
	.dipsw(8'h0),
	.led(led)

);

task waitclock;
begin
	@(posedge clk156);
	#1;
end
endtask


always @(posedge clk156) begin
	if (sys_rst) begin
		xgmii_counter <= 0;
	end else begin
		xgmii_counter <= xgmii_counter + 1;
		if (xgmii_0_txc != 8'hff)
			$display("%x", xgmii_0_txd);
	end
end

always @(posedge clk125) begin
	if (sys_rst) begin
		gmii_counter <= 0;
	end else begin
		gmii_counter <= gmii_counter + 1;
	end
end


initial begin
        $dumpfile("test.vcd");
	$dumpvars(0, l2switch_tb); 
	$readmemh("/home/tmatsuya/l2switch/boards/kc705/test/xgmii_data.hex", xgmii_rom);
	$readmemh("/home/tmatsuya/l2switch/boards/kc705/test/gmii_data.hex", gmii_rom);
	/* Reset / Initialize our logic */
	sys_rst = 1'b1;
	xgmii_counter <= 0;
	gmii_counter <= 0;

	waitclock;
	waitclock;

	sys_rst = 1'b0;

	waitclock;

//	#(500*16) mst_req_o = 1'b1;

//	#(8*2) mst_req_o = 1'b0;

	#4000;

	$finish;
end

endmodule
