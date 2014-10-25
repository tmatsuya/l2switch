`default_nettype none
module afifo72_12w (
	input wire rst,
	input wire wr_clk,
	input wire rd_clk,
	input wire [71:0] din,
	input wire wr_en,
	input wire rd_en,
	output wire [71:0] dout,
	output wire full,
	output wire empty,
	output wire prog_full
);

asfifo # (
	.DATA_WIDTH(72),
	.ADDRESS_WIDTH(12)
) asfifo_inst (
	.dout(dout), 
	.empty(empty),
	.rd_en(rd_en),
	.rd_clk(rd_clk),        
	.din(din),  
	.full(full),
	.wr_en(wr_en),
	.wr_clk(wr_clk),
	.rst(rst)
);

assign prog_full = 1'b0;

endmodule
`default_nettype wire
