`default_nettype none

module gmii2xgmii #(
	parameter FRAME_MAX_BIT_WIDTH = 11,	// 11:2048 12:4096 13:8192 14:16384
	parameter VALUE0 = 11'd0,
	parameter VALUE1 = 11'd1
) (
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
reg [FRAME_MAX_BIT_WIDTH-1:0] rx_count;
reg [7:0] xgmii_c;
reg [63:0] xgmii_d;
reg fifo_wr_en;
always @(posedge gmii_clk) begin
	if (sys_rst) begin
		rx_count <= VALUE0;
		xgmii_c <= 8'h01;
		xgmii_d <= 64'hd5_55_55_55_55_55_55_fb;
		fifo_wr_en <= 1'b0;
	end else begin
		fifo_wr_en <= 1'b0;
		if (gmii_dv) begin
			rx_count <= rx_count + VALUE1;
			if (rx_count[2:0] == 3'd7) begin
				fifo_wr_en <= 1'b1;
			end
			if (rx_count[FRAME_MAX_BIT_WIDTH-1:3] != 0) begin
				xgmii_c <= 8'h00;
				xgmii_d <= {gmii_rxd, xgmii_d[63:8]};
			end
		end else begin
			if (rx_count != VALUE0) begin
				case (rx_count[2:0])
					3'h0: begin
						xgmii_c <= 8'hff;
						xgmii_d <= 64'h07_07_07_07_07_07_07_fd;
					end
					3'h1: begin
						xgmii_c <= 8'hfe;
						xgmii_d <= {56'h07_07_07_07_07_07_fd, xgmii_d[63:56]};
					end
					3'h2: begin
						xgmii_c <= 8'hfc;
						xgmii_d <= {48'h07_07_07_07_07_fd, xgmii_d[63:48]};
					end
					3'h3: begin
						xgmii_c <= 8'hf8;
						xgmii_d <= {40'h07_07_07_07_fd, xgmii_d[63:40]};
					end
					3'h4: begin
						xgmii_c <= 8'hf0;
						xgmii_d <= {32'h07_07_07_fd, xgmii_d[63:32]};
					end
				endcase
				fifo_wr_en <= 1'b1;
			end else begin
				xgmii_c <= 8'h01;
				xgmii_d <= 64'hd5_55_55_55_55_55_55_fb;
			end
			rx_count <= VALUE0;
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
