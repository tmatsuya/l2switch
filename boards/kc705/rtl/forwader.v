`default_nettype none

module forwader # (
	parameter Port = 2'h0
) (
	input wire         sys_rst,
	input wire         sys_clk,
	// interface
	input wire [1:0]   port_num,
	// input PHY
	input wire [8:0]   dout,
	input wire [63:0]  empty,
	// out FIFO
	output wire [71:0] port0_din,
	input  wire        port0_full,
	input  wire        port0_half,
	output reg         port0_wr_en,
	output wire [71:0] port1_din,
	input  wire        port1_full,
	input  wire        port1_half,
	output reg         port1_wr_en,
	input [127:0]  dest_ip,
	input [47:0]  src_mac,
	input [47:0]  dest_mac,
	input [3:0] forward_port
);

reg [8:0] port_din;

//-----------------------------------
// Analyze and recalculation the frame
//-----------------------------------
reg [9:0] dout01, dout02, dout03, dout04, dout05, dout06, dout07,dout08, dout09, dout10;
reg [9:0] dout11, dout12, dout13, dout14, dout15, dout16, dout17,dout18, dout19, dout20;
reg [9:0] dout21, dout22, dout23, dout24, dout25, dout26, dout27,dout28, dout29, dout30;
reg [9:0] dout31, dout32, dout33, dout34, dout35, dout36, dout37,dout38, dout39, dout40;
reg [9:0] dout41, dout42, dout43, dout44, dout45, dout46, dout47,dout48, dout49, dout50;
reg [9:0] dout51, dout52, dout53, dout54, dout55, dout56, dout57,dout58, dout59, dout60;
reg [9:0] dout61, dout62;
reg [7:0] txd;
reg tx_en;
reg [11:0] counter, counter42;
reg [47:0] eth_dest;
reg [47:0] eth_src;
reg [15:0] eth_type;
reg [3:0] ip_hdrlen;
reg [7:0]  ipv4_tos;
reg [7:0]  ipv4_ttl;
reg [15:0] ipv4_sum;
reg [7:0]  ipv4_protocol;
reg [31:0] ipv4_src_ip, ipv4_dest_ip;
reg [15:0] ipv4_src_port, ipv4_dest_port;
reg [7:0]  ipv6_traffic_class;
reg [7:0]  ipv6_protocol;
reg [7:0]  ipv6_hop_limit;
reg [127:0] ipv6_dest_ip;
reg [3:0] fwd_port, fwd2_port;
reg [3:0]  half_port;
reg half_nic, half_arp;
reg fwd_nic, fwd2_nic, fwd_arp, fwd2_arp;
reg in_frame;
wire frame_type_ipv4 = (eth_type == 16'h0800);
//wire frame_type_ipv6 = (eth_type == 16'h86dd);
wire frame_type_support = (frame_type_ipv4);
wire forward_arp = (eth_type == 16'h0806);
wire forward_nic = 1'b0; // (frame_type_ipv4 && (ipv4_dest_ip == int_ipv4addr || ipv4_dest_ip == 32'h0)) || eth_dest[40] == 1'b1 || frame_type_support == 1'b0;
wire forward_router = 1'b1; // ~forward_nic;
always @(posedge sys_clk) begin
	if (sys_rst) begin
		counter <= 12'h0;
		counter42 <= 12'h0;
		eth_dest <= 48'h0;
		eth_src <= 48'h0;
		eth_type <= 16'h0;
		ip_hdrlen <= 4'h0;
		ipv4_tos <= 8'h0;
		ipv4_ttl <= 8'h0;
		ipv4_sum <= 16'h0;
		ipv4_protocol <= 8'h0;
		ipv4_src_ip <= 32'h0;
		ipv4_dest_ip <= 32'h0;
		ipv4_src_port <= 16'h0;
		ipv4_dest_port <= 16'h0;
		ipv6_dest_ip <= 128'h0;
		port_din <= 9'h0;
		arp_din <= 9'h0;
		nic_din <= 9'h0;
		rd_en <= 1'b0;
		dout01 <=10'h0;dout02 <=10'h0;dout03 <=10'h0;dout04 <=10'h0;dout05 <=10'h0;
		dout06 <=10'h0;dout07 <=10'h0;dout08 <=10'h0;dout09 <=10'h0;dout10 <=10'h0;
		dout11 <=10'h0;dout12 <=10'h0;dout13 <=10'h0;dout14 <=10'h0;dout15 <=10'h0;
		dout16 <=10'h0;dout17 <=10'h0;dout18 <=10'h0;dout19 <=10'h0;dout20 <=10'h0;
		dout21 <=10'h0;dout22 <=10'h0;dout23 <=10'h0;dout24 <=10'h0;dout25 <=10'h0;
		dout26 <=10'h0;dout27 <=10'h0;dout28 <=10'h0;dout29 <=10'h0;dout30 <=10'h0;
		dout31 <=10'h0;dout32 <=10'h0;dout33 <=10'h0;dout34 <=10'h0;dout35 <=10'h0;
		dout36 <=10'h0;dout37 <=10'h0;dout38 <=10'h0;dout39 <=10'h0;dout40 <=10'h0;
		dout41 <=10'h0;dout42 <=10'h0;dout43 <=10'h0;dout44 <=10'h0;dout45 <=10'h0;
		dout46 <=10'h0;dout47 <=10'h0;dout48 <=10'h0;dout49 <=10'h0;dout50 <=10'h0;
		dout51 <=10'h0;dout52 <=10'h0;dout53 <=10'h0;dout54 <=10'h0;dout55 <=10'h0;
		dout56 <=10'h0;dout57 <=10'h0;dout58 <=10'h0;dout59 <=10'h0;dout60 <=10'h0;
		dout61 <=10'h0;dout62 <=10'h0;
		req <= 1'b0;
		search_ip <= 32'h0;
		fwd_port <= 0;
		fwd2_port <= 0;
		fwd_arp <= 1'b0;
		fwd2_arp <= 1'b0;
		fwd_nic <= 1'b0;
		fwd2_nic <= 1'b0;
		half_port <= 4'b0;
		half_arp <= 1'b0;
		half_nic <= 1'b0;
		rd_en <= 1'b0;
		in_frame <= 1'b0;
		port0_wr_en <= 1'b0;
		port1_wr_en <= 1'b0;
		port2_wr_en <= 1'b0;
		port3_wr_en <= 1'b0;
		arp_wr_en   <= 1'b0;
		nic_wr_en   <= 1'b0;
	end else begin
              	rd_en  <= ~empty;
		req <= 1'b0;
		search_ip <= 32'h0;
		port0_wr_en <= 1'b0;
		port1_wr_en <= 1'b0;
		port2_wr_en <= 1'b0;
		port3_wr_en <= 1'b0;
		arp_wr_en   <= 1'b0;
		nic_wr_en   <= 1'b0;
		if ((rd_en == 1'b1 || in_frame == 1'b1) && enable_forwarding == 1'b1) begin
			dout01<={rd_en,dout};dout02<=dout01;dout03<=dout02;dout04<=dout03;dout05<=dout04;
			dout06<=dout05;dout07<=dout06;dout08<=dout07;dout09<=dout08;dout10<=dout09;
			dout11<=dout10;dout12<=dout11;dout13<=dout12;dout14<=dout13;dout15<=dout14;
			dout16<=dout15;dout17<=dout16;dout18<=dout17;dout19<=dout18;dout20<=dout19;
			dout21<=dout20;dout22<=dout21;dout23<=dout22;dout24<=dout23;dout25<=dout24;
			dout26<=dout25;dout27<=dout26;dout28<=dout27;dout29<=dout28;dout30<=dout29;
			dout31<=dout30;dout32<=dout31;dout33<=dout32;dout34<=dout33;dout35<=dout34;
			dout36<=dout35;dout37<=dout36;dout38<=dout37;dout39<=dout38;dout40<=dout39;
			dout41<=dout40;dout42<=dout41;dout43<=dout42;dout44<=dout43;dout45<=dout44;
			dout46<=dout45;dout47<=dout46;dout48<=dout47;dout49<=dout48;dout50<=dout49;
			dout51<=dout50;dout52<=dout51;dout53<=dout52;dout54<=dout53;dout55<=dout54;
			dout56<=dout55;dout57<=dout56;dout58<=dout57;dout59<=dout58;dout60<=dout59;
			dout61<=dout60;dout62<=dout61;
			if (rd_en == 1'b1) begin
				counter <= counter + 12'h1;
				if (dout[8] == 1'b1) begin
					case (counter)
						12'h00: eth_dest[47:40]       <= dout[7:0];
						12'h01: eth_dest[39:32]       <= dout[7:0];
						12'h02: eth_dest[31:24]       <= dout[7:0];
						12'h03: eth_dest[23:16]       <= dout[7:0];
						12'h04: eth_dest[15: 8]       <= dout[7:0];
						12'h05: eth_dest[ 7: 0]       <= dout[7:0];
						12'h06: eth_src[47:40]        <= dout[7:0];
						12'h07: eth_src[39:32]        <= dout[7:0];
						12'h08: eth_src[31:24]        <= dout[7:0];
						12'h09: eth_src[23:16]        <= dout[7:0];
						12'h0a: eth_src[15: 8]        <= dout[7:0];
						12'h0b: eth_src[ 7: 0]        <= dout[7:0];
						12'h0c: eth_type[15:8]        <= dout[7:0];
						12'h0d: eth_type[7:0]         <= dout[7:0];
						12'h0e: begin
							ip_hdrlen[3:0]        <= dout[3:0];
						end
						12'h0f: begin
							ipv4_tos[7:0]         <= dout[7:0];
						end
						12'h16: ipv4_ttl[7:0]         <= dout[7:0];
						12'h17: ipv4_protocol[7:0]    <= dout[7:0];
						12'h18: ipv4_sum[15:8]        <= dout[7:0];
						12'h19: ipv4_sum[7:0]         <= dout[7:0];
						12'h1a: ipv4_src_ip[31:24]    <= dout[7:0];
						12'h1b: ipv4_src_ip[23:16]    <= dout[7:0];
						12'h1c: ipv4_src_ip[15: 8]    <= dout[7:0];
						12'h1d: ipv4_src_ip[ 7: 0]    <= dout[7:0];
						12'h1e: ipv4_dest_ip[31:24]   <= dout[7:0];
						12'h1f: ipv4_dest_ip[23:16]   <= dout[7:0];
						12'h20: ipv4_dest_ip[15: 8]   <= dout[7:0];
						12'h21: begin
							ipv4_dest_ip[ 7: 0]   <= dout[7:0];
							if (forward_router == 1'b1 && bridge_mode == 1'b0) begin
								req <= 1'b1;
								search_ip <= {ipv4_dest_ip[31:8], dout[7:0]};
							end
							fwd_port <= 4'b0000;
							fwd_arp <= forward_arp;
							fwd_nic <= forward_nic;
						end
						12'h22: ipv4_src_port[15: 8]  <= dout[7:0];
						12'h23: ipv4_src_port[ 7: 0]  <= dout[7:0];
						12'h24: ipv4_dest_port[15: 8] <= dout[7:0];
						12'h25: ipv4_dest_port[ 7: 0] <= dout[7:0];
						12'h26: ipv6_dest_ip[127:120] <= dout[7:0];
						12'h27: ipv6_dest_ip[119:112] <= dout[7:0];
						12'h28: ipv6_dest_ip[111:104] <= dout[7:0];
						12'h29: ipv6_dest_ip[103: 96] <= dout[7:0];
						12'h2a: ipv6_dest_ip[ 95: 88] <= dout[7:0];
						12'h2b: ipv6_dest_ip[ 87: 80] <= dout[7:0];
						12'h2c: ipv6_dest_ip[ 79: 72] <= dout[7:0];
						12'h2d: ipv6_dest_ip[ 71: 64] <= dout[7:0];
						12'h2e: ipv6_dest_ip[ 63: 56] <= dout[7:0];
						12'h2f: ipv6_dest_ip[ 55: 48] <= dout[7:0];
						12'h30: ipv6_dest_ip[ 47: 40] <= dout[7:0];
						12'h31: ipv6_dest_ip[ 39: 32] <= dout[7:0];
						12'h32: ipv6_dest_ip[ 31: 24] <= dout[7:0];
						12'h33: ipv6_dest_ip[ 23: 16] <= dout[7:0];
						12'h34: ipv6_dest_ip[ 15:  8] <= dout[7:0];
						12'h35: ipv6_dest_ip[  7:  0] <= dout[7:0];
					endcase
					if (ack == 1'b1 && ipv4_dest_ip == dest_ip[31:0] && forward_port != 4'b0000 && bridge_mode == 1'b0) begin
// packet filter rules are here (forwarding, reject) ipv4_protocol, ipv4_src_ip, ipv4_dest_ip, ipv4_src_ip, ipv4_src_port, ipv4_dest_port
						eth_src <= src_mac;
						eth_dest <= dest_mac;
						if (ipv4_ttl != 8'h0)
							fwd_port <= forward_port;
					end else if (bridge_mode == 1'b1) begin
						case (port_num)
						2'h0: fwd_port <= 4'b1110;
						2'h1: fwd_port <= 4'b1101;
						2'h2: fwd_port <= 4'b1011;
						2'h3: fwd_port <= 4'b0111;
						endcase
					end
				end else begin
					counter <= 12'h0;
				end
			end
			if (dout42[9] == 1'b1) begin
				in_frame <= dout42[8];
				if (dout42[8] == 1'b1)
					counter42 <= counter42 + 12'h1;
				else
					counter42 <= 12'h0;
				if (dout38[8] == 1'b1 && dout42[8] == 1'b1) begin
					case (counter42)
						12'h00: begin
							if (bridge_mode == 1'b0) begin
								ipv4_ttl <= ipv4_ttl-8'h1;
								ipv4_sum[15:8] <= ipv4_sum[15:8] + 8'h1;
							end
							port_din <= {1'b1,eth_dest[47:40]};
							fwd2_port <= fwd_port;
							fwd2_arp <= fwd_arp;
							fwd2_nic <= fwd_nic;
							half_port <= {port3_half, port2_half, port1_half, port0_half};
							half_arp <= arp_half;
							half_nic <= nic_half;
							port0_wr_en <= fwd_port[0] & ~port0_half;
							port1_wr_en <= fwd_port[1] & ~port1_half;
							port2_wr_en <= fwd_port[2] & ~port2_half;
							port3_wr_en <= fwd_port[3] & ~port3_half;
							arp_wr_en <= fwd_arp & ~arp_half;
							nic_wr_en <= fwd_nic & ~nic_half;
						end
						12'h01: port_din <= {1'b1,eth_dest[39:32]};
						12'h02: port_din <= {1'b1,eth_dest[31:24]};
						12'h03: port_din <= {1'b1,eth_dest[23:16]};
						12'h04: port_din <= {1'b1,eth_dest[15: 8]};
						12'h05: port_din <= {1'b1,eth_dest[ 7: 0]};
						12'h06: port_din <= {1'b1,eth_src[47:40]};
						12'h07: port_din <= {1'b1,eth_src[39:32]};
						12'h08: port_din <= {1'b1,eth_src[31:24]};
						12'h09: port_din <= {1'b1,eth_src[23:16]};
						12'h0a: port_din <= {1'b1,eth_src[15: 8]};
						12'h0b: port_din <= {1'b1,eth_src[ 7: 0]};
						12'h0c: port_din <= {1'b1,eth_type[15:8]};
						12'h0d: port_din <= {1'b1,eth_type[7:0]};
						12'h16: port_din <= {1'b1,ipv4_ttl[7:0]};
						12'h18: port_din <= {1'b1,ipv4_sum[15:8]};
						12'h19: port_din <= {1'b1,ipv4_sum[7:0]};
						default: begin
							port_din <= dout42[8:0];
						end
					endcase
					arp_din <= dout42[8:0];
					nic_din <= dout42[8:0];
				end else begin
					port_din <= 9'h0;
					arp_din <= 9'h0;
					nic_din <= 9'h0;
				end
				port0_wr_en <= fwd2_port[0] & ~half_port[0];
				port1_wr_en <= fwd2_port[1] & ~half_port[1];
				port2_wr_en <= fwd2_port[2] & ~half_port[2];
				port3_wr_en <= fwd2_port[3] & ~half_port[3];
				arp_wr_en   <= fwd2_arp & ~half_arp;
				nic_wr_en   <= fwd2_nic & ~half_nic;
			end
		end
	end
end

assign port0_din = port_din;
assign port1_din = port_din;
assign port2_din = port_din;
assign port3_din = port_din;

endmodule
`default_nettype wire
