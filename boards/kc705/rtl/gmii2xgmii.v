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
// logic
//-----------------------------------
reg [71:0] rxd = 72'h00;
reg start = 1'b0;
always @(posedge gmii_clk) begin
	if (sys_rst) begin
		rxd <= 72'h00;
		start <= 1'b0;
	end else begin
		if (xgmii_rxd[71:64] != 8'hff || xgmii_rxd[7:0] != 8'h07) begin
			if (start == 1'b1) begin
				if (xgmii_rxd[68] == 1'b0) begin
					rxd[71:0] <= xgmii_rxd[71:0];
				end
			end
			start <= 1'b0;
		end
	end
end

endmodule
`default_nettype wire
