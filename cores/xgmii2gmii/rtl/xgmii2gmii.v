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
wire tx0_phyq_prog_full;

afifo72_12w afifo72_12w_0 (
	.rst(sys_rst),
	.wr_clk(xgmii_clk),
	.rd_clk(gmii_clk),
	.din(tx0_phyq_din),
	.wr_en(tx0_phyq_wr_en),
	.rd_en(tx0_phyq_rd_en),
	.dout(tx0_phyq_dout),
	.full(tx0_phyq_full),
	.empty(tx0_phyq_empty),
	.prog_full(tx0_phyq_prog_full)
);


//-----------------------------------
// write XGMII to tx_FIFO
//-----------------------------------
reg tx0_phyq_enough = 1'b0;
reg [1:0] xgmii_state = 2'b00;
reg [1:0] xgmii_next_state = 2'b00;

parameter XGMII_STATE_IDLE = 2'b00;
parameter XGMII_STATE_DV   = 2'b01;
parameter XGMII_STATE_IFG  = 2'b10;

assign tx0_phyq_din = {xgmii_txc[7:0], xgmii_txd[63:0]};

always @(posedge xgmii_clk) begin
	if (sys_rst) begin
		xgmii_state <= XGMII_STATE_IDLE;
	end else begin
		xgmii_state <= xgmii_next_state;
	end
end

always @(*) begin
	if (sys_rst) begin
		tx0_phyq_enough = 1'b0;
		tx0_phyq_wr_en = 1'b0;
		xgmii_next_state = XGMII_STATE_IDLE;
	end else begin
		tx0_phyq_wr_en = 1'b0;
		case (xgmii_state)
			XGMII_STATE_IDLE: begin
				if (xgmii_txc == 8'h01 && xgmii_txd == 64'hd5_55_55_55_55_55_55_fb) begin
					tx0_phyq_enough = ~tx0_phyq_prog_full;
					tx0_phyq_wr_en = 1'b1;
					xgmii_next_state = XGMII_STATE_DV;
				end
			end
			XGMII_STATE_DV: begin
				tx0_phyq_wr_en = tx0_phyq_enough;
				if (xgmii_txc == 8'hff) begin
					xgmii_next_state = XGMII_STATE_IFG;
				end
			end
			XGMII_STATE_IFG: begin
				tx0_phyq_wr_en = tx0_phyq_enough;
				xgmii_next_state = XGMII_STATE_IDLE;
			end
		endcase
	end
end

`ifdef NO
//-----------------------------------
// write to GMII logic
//-----------------------------------
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
