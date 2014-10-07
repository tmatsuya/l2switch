`default_nettype none

module gmii2xgmii (
	input  wire        sys_rst,
	input  wire        gmii_clk,
	input  wire        gmii_dv,
	input  wire [ 7:0] gmii_rxd,
	input  wire        xgmii_clk,
	output wire [ 7:0] xgmii_rxc,
	output wire [71:0] xgmii_rxd
);


//-----------------------------------
// AFIFO
//-----------------------------------
afifo72_11r afifo72_11r_0 (
	.rst(sys_rst),
	.wr_clk(gmii_clk),
	.rd_clk(xgmii_clk),
	.din(),
	.wr_en(),
	.rd_en(),
	.dout(),
	.full(),
	.empty()
);


//-----------------------------------
// logic
//-----------------------------------
reg [71:0] rxd = 72'h00;
reg [35:0] rxd2 = 36'h00;
reg start = 1'b0;
reg quad_shift = 1'b0;
always @(posedge xgmii_clk) begin
	if (sys_rst) begin
		rxd <= 72'h00;
		rxd2 <= 36'h00;
		start <= 1'b0;
		quad_shift <= 1'b0;
	end else begin
		if (xgmii_rxd[71:64] != 8'hff || xgmii_rxd[7:0] != 8'h07) begin
			if (start == 1'b1) begin
				if (xgmii_rxd[68] == 1'b0) begin
					quad_shift <= 1'b0;
					rxd[71:0] <= xgmii_rxd[71:0];
				end else begin
					rxd2[35:0] <= {xgmii_rxd[71:68],xgmii_rxd[63:32]};
					quad_shift <= 1'b1;
				end
			end else begin
				if (quad_shift == 1'b0) begin
					rxd[71:0] <= xgmii_rxd[71:0];
				end else begin
					rxd[71:0] <= {xgmii_rxd[67:64], rxd2[35:32], xgmii_rxd[31:0], rxd2[31:0]};
					rxd2[35:0] <= {xgmii_rxd[71:68],xgmii_rxd[63:32]};
				end
			end
			start <= 1'b0;
		end else begin
			start <= 1'b1;
			if (quad_shift == 1'b1)
				rxd[71:0] <= {4'hf, rxd2[35:32], 32'h07_07_07_07, rxd2[31:0]};
			else begin
				rxd[71:0] <= 72'hff_07_07_07_07_07_07_07_07;
			end
			quad_shift <= 1'b0;
		end
	end
end

endmodule
`default_nettype wire
