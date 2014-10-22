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
wire [71:0] rx0_phyq_din, rx0_phyq_dout;
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
reg rx_dv;
reg rx_ctl;
reg [7:0] rx_data;
reg [1:0] state1 = 2'b0;
reg [2:0] col = 3'd0;

parameter STATE1_IDLE = 2'b00;
parameter STATE1_DV   = 2'b01;
parameter STATE1_IFG  = 2'b10;

always @(posedge gmii_clk) begin
	if (sys_rst) begin
		rx_dv <= 1'b0;
		rx_ctl <= 1'b0;
		rx_data <= 8'h00;
		state1 <= STATE1_IDLE;
		col <= 3'd0;
	end else begin
		rx_ctl <= 1'b1;
		col <= col + 3'd1;
		case (state1)
			STATE1_IDLE: begin
				col <= 3'd0;
				if (gmii_dv) begin
					rx_dv <= 1'b1;
					rx_data <= 8'hfb;
					col <= 3'd0;
					state1 <= STATE1_DV;
				end else
					rx_dv <= 1'b0;
			end
			STATE1_DV: begin
				if (gmii_dv) begin
					rx_ctl <= 1'b0;
					rx_data <= gmii_rxd;
				end else begin
					rx_data <= 8'hfd;
					state1 <= STATE1_IFG;
				end
			end
			STATE1_IFG: begin
				rx_data <= 8'h07;
				col <= col - 3'd1;
				if (col == 3'd0) begin
					state1 <= STATE1_IDLE;
				end
			end
		endcase
	end
end

reg [7:0] xgmii_c;
reg [63:0] xgmii_d;
reg fifo_wr_en;
reg [2:0] rx_count;

always @(posedge gmii_clk) begin
	if (sys_rst) begin
		rx_count <= 3'd0;
		xgmii_c <= 8'hff;
		xgmii_d <= 64'h07_07_07_07_07_07_07_07;
		fifo_wr_en <= 1'b0;
	end else begin
		fifo_wr_en <= 1'b0;
		if (rx_dv) begin
			rx_count <= rx_count + 3'd1;
			if (rx_count == 3'd7) begin
				fifo_wr_en <= 1'b1;
			end
			xgmii_c <= {rx_ctl, xgmii_c[7:1]};
			xgmii_d <= {rx_data, xgmii_d[63:8]};
		end else begin
			xgmii_c <= 8'hff;
			xgmii_d <= 64'h07_07_07_07_07_07_07_07;
			if (rx_count != 3'd0) begin
				fifo_wr_en <= 1'b1;
				rx_count <= rx_count + 3'd1;
			end
		end
	end
end

assign rx0_phyq_wr_en = fifo_wr_en;
assign rx0_phyq_din = {xgmii_c, xgmii_d};

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
