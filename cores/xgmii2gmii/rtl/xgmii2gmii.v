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
wire [71:0] tx0_phyq_din, tx0_phyq_dout;
wire tx0_phyq_full;
reg tx0_phyq_wr_en;
wire tx0_phyq_empty, tx0_phyq_rd_en;

afifo72_11r afifo72_11r_0 (
	.rst(sys_rst),
	.wr_clk(xgmii_clk),
	.rd_clk(gmii_clk),
	.din(tx0_phyq_din),
	.wr_en(tx0_phyq_wr_en),
	.rd_en(tx0_phyq_rd_en),
	.dout(tx0_phyq_dout),
	.full(tx0_phyq_full),
	.empty(tx0_phyq_empty)
);

//-----------------------------------
// read from XGMII logic
//-----------------------------------
reg tx_en = 1'b0;
reg [7:0] tx_data = 8'h00;
reg [2:0] col = 3'd0;
reg [1:0] xgmii_state = 2'b00;

parameter XGMII_STATE_IDLE = 2'b00;
parameter XGMII_STATE_DV   = 2'b01;
parameter XGMII_STATE_IFG  = 2'b10;

`ifdef NO

always @(posedge xgmii_clk) begin
	if (sys_rst) begin
		tx0_phyq_wr_en <= 1'b0;
		xgmii_state <= XGMII_STATE_IDLE;
	end else begin
		case (xgmii_state)
			XGMII_STATE_IDLE: begin
				if (xgmii_txc == 8'h01 && xgmii_txd == 64'h07_07_07_07_07_07_07_fb) begin
					xgmii_state <= XGMII_STATE_DV;
				end
			end
			XGMII_STATE_DV: begin
				if (xgmii_dv) begin
					rx_ctl <= 1'b0;
					rx_data <= xgmii_rxd;
				end else begin
					rx_data <= 8'hfd;
					xgmii_state <= XGMII_STATE_IFG;
				end
			end
			XGMII_STATE_IFG: begin
				rx_data <= 8'h07;
				if (col == 3'd7) begin
					xgmii_state <= XGMII_STATE_IDLE;
				end
			end
		endcase
	end
end

reg [7:0] gmii_c;
reg [63:0] gmii_d;
reg fifo_wr_en;
reg [2:0] rx_count;
reg xgmii_frame_end;

always @(posedge xgmii_clk) begin
	if (sys_rst) begin
		rx_count <= 3'd0;
		gmii_c <= 8'hff;
		gmii_d <= 64'h07_07_07_07_07_07_07_07;
		fifo_wr_en <= 1'b0;
		xgmii_frame_end <= 1'b0;
	end else begin
		fifo_wr_en <= 1'b0;
		xgmii_frame_end <= 1'b0;
		if (rx_dv) begin
			rx_count <= rx_count + 3'd1;
			if (rx_count == 3'd7) begin
				fifo_wr_en <= 1'b1;
			end
			gmii_c <= {rx_ctl, gmii_c[7:1]};
			gmii_d <= {rx_data, gmii_d[63:8]};
		end else begin
			gmii_c <= 8'hff;
			gmii_d <= 64'h07_07_07_07_07_07_07_07;
			if (rx_count != 3'd0) begin
				xgmii_frame_end <= 1'b1;
				fifo_wr_en <= 1'b1;
				rx_count <= rx_count + 3'd1;
			end
		end
	end
end

assign tx0_phyq_wr_en = fifo_wr_en;
assign tx0_phyq_din = {gmii_c, gmii_d};

//-----------------------------------
// count GMII frame
//-----------------------------------
reg [7:0] xgmii_packet_count;		// receive GMII packet count
reg [3:0] prev_xgmii_end;
always @(posedge gmii_clk) begin
	if (sys_rst) begin
		xgmii_packet_count <= 8'h0;
		prev_xgmii_end <= 4'b0000;
	end else begin
		prev_xgmii_end <= {xgmii_frame_end, prev_xgmii_end[3:1]};
		if (prev_xgmii_end == 4'b0001)
			xgmii_packet_count <= xgmii_packet_count + 8'd1;
	end
end

//-----------------------------------
// write to XGMII logic
//-----------------------------------
reg [7:0] gmii_packet_count;		// transmit XGMII packet count
reg gmii_find_data = 1'b0;
reg [1:0] gmii_state = 2'b0;

parameter GMII_STATE_IDLE = 2'b00;
parameter GMII_STATE_SEND = 2'b01;
parameter GMII_STATE_IFG  = 2'b10;
always @(posedge gmii_clk) begin
	if (sys_rst) begin
		tx0_phyq_rd_en <= 1'b0;
		gmii_packet_count <= 8'h0;
		gmii_rxc <= 8'hff;
		gmii_rxd <= 64'h07_07_07_07_07_07_07_07;
		gmii_find_data <= 1'b0;
		gmii_state <= GMII_STATE_IDLE;
	end else begin
		tx0_phyq_rd_en <= 1'b0;
		gmii_rxc <= 8'hff;
		gmii_rxd <= 64'h07_07_07_07_07_07_07_07;
		case (gmii_state)
			GMII_STATE_IDLE: begin
				if (xgmii_packet_count != gmii_packet_count) begin
					gmii_find_data <= 1'b0;
					gmii_state <= GMII_STATE_SEND;
				end
			end
			GMII_STATE_SEND: begin
				tx0_phyq_rd_en <= ~tx0_phyq_empty;
				if (tx0_phyq_rd_en) begin
					gmii_rxc <= tx0_phyq_dout[71:64];
					gmii_rxd <= tx0_phyq_dout[63: 0];
					if (tx0_phyq_dout[71:64] == 8'hff) begin
						if (gmii_find_data)
							gmii_state <= GMII_STATE_IFG;
					end else
						gmii_find_data <= 1'b1;
				end
			end
			GMII_STATE_IFG: begin
				gmii_packet_count <= gmii_packet_count + 8'd1;
				gmii_state <= GMII_STATE_IDLE;
			end
		endcase
	end
end
`endif

endmodule
`default_nettype wire
