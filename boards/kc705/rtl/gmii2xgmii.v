`default_nettype none

module gmii2xgmii (
	input  wire        sys_rst,
	input  wire        gmii_clk,
	input  wire        gmii_dv,
	input  wire [ 7:0] gmii_rxd,
	input  wire        xgmii_clk,
	output wire [ 7:0] xgmii_rxc,
	output wire [63:0] xgmii_rxd
);

//-----------------------------------
// AFIFO
//-----------------------------------
wire [8:0] rx0_phyq_din, rx0_phyq_dout;
wire rx0_phyq_full, rx0_phyq_wr_en;
wire rx0_phyq_empty, rx0_phyq_rd_en;
afifo72_11r afifo72_11r_0 (
	.rst(sys_rst),
	.wr_clk(gmii_clk),
	.rd_clk(xgmii_clk),
	.din(rx0_phyq_din),
	.wr_en(rx0_phyq_wr_en),
	.rd_en(rx0_phyq_rd_en),
	.dout(rx0_phyq_dout),
	.full(rx0_phyq_full),
	.empty(rx0_phyq_empty)
);

//-----------------------------------
// read from GMII logic
//-----------------------------------
always @(posedge gmii_clk) begin
	if (sys_rst) begin
	end else begin
		if (gmii_dv) begin
		end else begin
		end
	end
end

//-----------------------------------
// write to XGMII logic
//-----------------------------------
always @(posedge xgmii_clk) begin
	if (sys_rst) begin
	end else begin
	end
end

endmodule
`default_nettype wire
