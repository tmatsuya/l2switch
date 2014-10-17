`timescale 1ps / 1ps
`define SIMULATION
module gmii2xgmii_tb();

/* 125 and 156.25MHz clock */
reg clk156, clk125;
initial begin
	clk125 = 0;
	clk156 = 0;
end
always #8  clk156 = ~clk156;
always #10 clk125 = ~clk125;

/* GMII test */
reg  [8:0] gmii_rom [0:4095];
reg [11:0] gmii_counter;
wire  [8:0] gmii_cur;
assign gmii_cur = gmii_rom[ gmii_counter ];

reg         sys_rst;
reg         gmii_clk;
reg         gmii_dv;
reg  [ 7:0] gmii_rxd;
wire        xgmii_clk;
wire [ 7:0] xgmii_rxc;

gmii2xgmii # (
	.FRAME_MAX_BIT_WIDTH(11)     // 11:2048 12:4096 13:8192 14:16384
)  gmii2xgmii_inst (
	.sys_rst(sys_rst),
	// GMII interface
	.gmii_clk(clk125),
	.gmii_dv(gmii_cur[8]),
	.gmii_rxd(gmii_cur[7:0]),
	// XGMII interfaces for MAC
	.xgmii_clk(clk156),
	.xgmii_rxc(xgmii_rxc),
	.xgmii_rxd(xgmii_rxd)
);

task waitclock;
begin
	@(posedge clk156);
	#1;
end
endtask


always @(posedge clk125) begin
	if (sys_rst) begin
		gmii_counter <= 0;
	end else begin
		gmii_counter <= gmii_counter + 1;
	end
end


initial begin
    $dumpfile("test.vcd");
	$dumpvars(0, gmii2xgmii_tb); 
	$readmemh("gmii_data.hex", gmii_rom);
	/* Reset / Initialize our logic */
	sys_rst = 1'b1;
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
