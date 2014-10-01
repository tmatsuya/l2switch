`timescale 1ps / 1ps
`define SIMULATION
//`include "../rtl/setup.v"
module l2switch_tb();

/* 125MHz system clock */
reg         sys_rst;
reg         sys_clk;	// clk156
initial sys_clk = 1'b0;
always #8 sys_clk = ~sys_clk;

// XGMII interfaces for 4 MACs
wire [63:0] xgmii_0_txd;
wire [7:0]  xgmii_0_txc;
reg  [63:0] xgmii_0_rxd;
reg  [7:0]  xgmii_0_rxc;

wire [63:0] xgmii_1_txd;
wire [7:0]  xgmii_1_txc;
reg  [63:0] xgmii_1_rxd;
reg  [7:0]  xgmii_1_rxc;

wire [63:0] xgmii_2_txd;
wire [7:0]  xgmii_2_txc;
reg  [63:0] xgmii_2_rxd;
reg  [7:0]  xgmii_2_rxc;

wire [63:0] xgmii_3_txd;
wire [7:0]  xgmii_3_txc;
wire [63:0] xgmii_3_rxd;
wire [7:0]  xgmii_3_rxc;

// LED and Switches
reg [7:0] dipsw;
wire [7:0] led;

reg [71:0] xgmii_rom [0:4095];
reg [11:0] xgmii_counter;
wire [71:0] xgmii_cur;

assign xgmii_cur = xgmii_rom[ xgmii_counter ];

l2switch l2switch_inst (
         .sys_rst   (sys_rst),
         .sys_clk   (sys_clk),

  // XGMII interfaces for 4 MACs
	.xgmii_0_txd(xgmii_0_txd),
	.xgmii_0_txc(xgmii_0_txc),
	.xgmii_0_rxd(xgmii_cur[63:0]),
	.xgmii_0_rxc(xgmii_cur[71:64]),

	.xgmii_1_txd(xgmii_1_txd),
	.xgmii_1_txc(xgmii_1_txc),
	.xgmii_1_rxd(xgmii_1_rxd),
	.xgmii_1_rxc(xgmii_1_rxc),

	.xgmii_2_txd(xgmii_2_txd),
	.xgmii_2_txc(xgmii_2_txc),
	.xgmii_2_rxd(xgmii_2_rxd),
	.xgmii_2_rxc(xgmii_2_rxc),

	.xgmii_3_txd(xgmii_3_txd),
	.xgmii_3_txc(xgmii_3_txc),
	.xgmii_3_rxd(xgmii_3_rxd),
	.xgmii_3_rxc(xgmii_3_rxc),

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
	@(posedge sys_clk);
	#1;
end
endtask


always @(posedge sys_clk) begin
	if (sys_rst) begin
		xgmii_counter <= 0;
	end else begin
		xgmii_counter <= xgmii_counter + 1;
		if (xgmii_0_txc != 8'hff)
			$display("%x", xgmii_0_txd);
	end
end


initial begin
        $dumpfile("test.vcd");
	$dumpvars(0, l2switch_tb); 
	$readmemh("/home/tmatsuya/l2switch/boards/kc705/test/xgmii_data.hex", xgmii_rom);
	/* Reset / Initialize our logic */
	sys_rst = 1'b1;
	xgmii_counter <= 0;

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
