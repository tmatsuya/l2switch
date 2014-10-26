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
wire tx0_phyq_empty;
reg tx0_phyq_rd_en;
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

//-----------------------------------
// write to GMII logic
//-----------------------------------
reg [1:0] gmii_state = 2'b0;

parameter GMII_STATE_IDLE = 2'b00;
parameter GMII_STATE_SEND = 2'b01;
parameter GMII_STATE_IFG  = 2'b10;

reg [2:0] tx_count = 3'd0;
reg [63:0] tx_data = 64'h0;
reg [7:0] tx_en = 8'h0;

assign gmii_en  = tx_en[0];
assign gmii_txd = tx_data[7:0];

always @(posedge gmii_clk) begin
	if (sys_rst) begin
		tx0_phyq_rd_en <= 1'b0;
		tx_en <= 1'b0;
		tx_data <= 8'h00;
		tx_count <= 3'd0;
		gmii_state <= GMII_STATE_IDLE;
	end else begin
		tx0_phyq_rd_en <= 1'b0;
		case (gmii_state)
			GMII_STATE_IDLE: begin
				if (tx0_phyq_rd_en) begin
					if (tx0_phyq_dout == 72'h01_d5_55_55_55_55_55_55_fb) begin
						tx_en   <= 8'hff;
						tx_data <= 64'hd5_55_55_55_55_55_55_55;
						tx_count <= 3'd0;
						gmii_state <= GMII_STATE_SEND;
					end
				end else
					tx0_phyq_rd_en <= ~tx0_phyq_empty;
			end
			GMII_STATE_SEND: begin
				tx_en <= {1'b0, tx_en[7:1]};
				tx_data <= {8'h00, tx_data[63:8]};
				tx_count <= tx_count + 3'd1;
				if (tx0_phyq_rd_en) begin
					if (tx0_phyq_dout[71:64] != 8'hff) begin
						tx_en   <= ~tx0_phyq_dout[71:64];
						tx_data <= tx0_phyq_dout[63:0];
					end else begin
						gmii_state <= GMII_STATE_IFG;
					end
				end else if (tx_count == 3'd6)
					tx0_phyq_rd_en <= 1'b1;
			end
			GMII_STATE_IFG: begin
				tx_en <= 1'b0;
				tx_data <= 8'h00;
				gmii_state <= GMII_STATE_IDLE;
			end
		endcase
	end
end

endmodule
`default_nettype wire
