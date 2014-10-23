`default_nettype none

module xgmii2gmii (
	input  wire        sys_rst,
	input  wire        xgmii_clk,
	input  wire [ 7:0] xgmii_txc,
	input  wire [63:0] xgmii_txd,
	input  wire        gmii_clk,
	output wire        gmii_en,
	output wire [ 7:0] gmii_txd
);

//-----------------------------------
// AFIFO
//-----------------------------------
wire [71:0] rx0_phyq_din, rx0_phyq_dout;
wire rx0_phyq_full, rx0_phyq_wr_en;
wire rx0_phyq_empty;
reg rx0_phyq_rd_en;

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
reg [2:0] col = 3'd0;
reg [1:0] gmii_state = 2'b0;

parameter GMII_STATE_IDLE = 2'b00;
parameter GMII_STATE_DV   = 2'b01;
parameter GMII_STATE_IFG  = 2'b10;

always @(posedge gmii_clk) begin
	if (sys_rst) begin
		rx_dv <= 1'b0;
		rx_ctl <= 1'b1;
		rx_data <= 8'h07;
		col <= 3'd0;
		gmii_state <= GMII_STATE_IDLE;
	end else begin
		rx_ctl <= 1'b1;
		col <= col + 3'd1;
		case (gmii_state)
			GMII_STATE_IDLE: begin
				col <= 3'd0;
				if (gmii_dv) begin
					rx_dv <= 1'b1;
					rx_data <= 8'hfb;
					col <= 3'd0;
					gmii_state <= GMII_STATE_DV;
				end else
					rx_dv <= 1'b0;
			end
			GMII_STATE_DV: begin
				if (gmii_dv) begin
					rx_ctl <= 1'b0;
					rx_data <= gmii_rxd;
				end else begin
					rx_data <= 8'hfd;
					gmii_state <= GMII_STATE_IFG;
				end
			end
			GMII_STATE_IFG: begin
				rx_data <= 8'h07;
				if (col == 3'd7) begin
					gmii_state <= GMII_STATE_IDLE;
				end
			end
		endcase
	end
end

reg [7:0] xgmii_c;
reg [63:0] xgmii_d;
reg fifo_wr_en;
reg [2:0] rx_count;
reg gmii_frame_end;

always @(posedge gmii_clk) begin
	if (sys_rst) begin
		rx_count <= 3'd0;
		xgmii_c <= 8'hff;
		xgmii_d <= 64'h07_07_07_07_07_07_07_07;
		fifo_wr_en <= 1'b0;
		gmii_frame_end <= 1'b0;
	end else begin
		fifo_wr_en <= 1'b0;
		gmii_frame_end <= 1'b0;
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
				gmii_frame_end <= 1'b1;
				fifo_wr_en <= 1'b1;
				rx_count <= rx_count + 3'd1;
			end
		end
	end
end

assign rx0_phyq_wr_en = fifo_wr_en;
assign rx0_phyq_din = {xgmii_c, xgmii_d};

//-----------------------------------
// count GMII frame
//-----------------------------------
reg [7:0] gmii_packet_count;		// receive GMII packet count
reg [3:0] prev_gmii_end;
always @(posedge xgmii_clk) begin
	if (sys_rst) begin
		gmii_packet_count <= 8'h0;
		prev_gmii_end <= 4'b0000;
	end else begin
		prev_gmii_end <= {gmii_frame_end, prev_gmii_end[3:1]};
		if (prev_gmii_end == 4'b0001)
			gmii_packet_count <= gmii_packet_count + 8'd1;
	end
end

//-----------------------------------
// write to XGMII logic
//-----------------------------------
reg [7:0] xgmii_packet_count;		// transmit XGMII packet count
reg xgmii_find_data = 1'b0;
reg [1:0] xgmii_state = 2'b0;

parameter XGMII_STATE_IDLE = 2'b00;
parameter XGMII_STATE_SEND = 2'b01;
parameter XGMII_STATE_IFG  = 2'b10;
always @(posedge xgmii_clk) begin
	if (sys_rst) begin
		rx0_phyq_rd_en <= 1'b0;
		xgmii_packet_count <= 8'h0;
		xgmii_rxc <= 8'hff;
		xgmii_rxd <= 64'h07_07_07_07_07_07_07_07;
		xgmii_find_data <= 1'b0;
		xgmii_state <= XGMII_STATE_IDLE;
	end else begin
		rx0_phyq_rd_en <= 1'b0;
		xgmii_rxc <= 8'hff;
		xgmii_rxd <= 64'h07_07_07_07_07_07_07_07;
		case (xgmii_state)
			XGMII_STATE_IDLE: begin
				if (gmii_packet_count != xgmii_packet_count) begin
					xgmii_find_data <= 1'b0;
					xgmii_state <= XGMII_STATE_SEND;
				end
			end
			XGMII_STATE_SEND: begin
				rx0_phyq_rd_en <= ~rx0_phyq_empty;
				if (rx0_phyq_rd_en) begin
					xgmii_rxc <= rx0_phyq_dout[71:64];
					xgmii_rxd <= rx0_phyq_dout[63: 0];
					if (rx0_phyq_dout[71:64] == 8'hff) begin
						if (xgmii_find_data)
							xgmii_state <= XGMII_STATE_IFG;
					end else
						xgmii_find_data <= 1'b1;
				end
			end
			XGMII_STATE_IFG: begin
				xgmii_packet_count <= xgmii_packet_count + 8'd1;
				xgmii_state <= XGMII_STATE_IDLE;
			end
		endcase
	end
end

endmodule
`default_nettype wire
