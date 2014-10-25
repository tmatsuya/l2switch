`timescale 1ps / 1ps
`define SIMULATION
module xgmii2gmii_tb();

/* 125 and 156.25MHz clock */
reg clk156, clk125;
initial begin
	clk125 = 0;
	clk156 = 0;
end
always #8  clk156 = ~clk156;
always #10 clk125 = ~clk125;

/* GMII test */
reg  [8:0] xgmii_rom [0:4095];
reg [11:0] xgmii_counter;
wire  [71:0] xgmii_cur;
assign xgmii_cur = xgmii_rom[ xgmii_counter ];

reg         sys_rst;
wire        gmii_en;
wire [ 7:0] gmii_txd;

xgmii2gmii xgmii2gmii_inst (
	.sys_rst(sys_rst),
	// XGMII interfaces for MAC
	.xgmii_clk(clk156),
	.xgmii_txc(xgmii_cur[71:64]),
	.xgmii_txd(xgmii_cur[63: 0]),
	// GMII interface
	.gmii_clk(clk125),
	.gmii_en(gmii_en),
	.gmii_txd(gmii_txd)
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
	end
end


initial begin
    $dumpfile("test.vcd");
	$dumpvars(0, xgmii2gmii_tb); 
	$readmemh("xgmii_data.hex", xgmii_rom);
	/* Reset / Initialize our logic */
	sys_rst = 1'b1;

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
