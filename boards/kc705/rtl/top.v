`include "../rtl/setup.v"
`timescale 1ns / 1ps
`default_nettype none

module top (
	input wire xphy0_refclk_p, 
	input wire xphy0_refclk_n, 
	output wire [4:0] sfp_tx_disable, 
	output wire [3:0] sfp_tx_fault, 
	output wire xphy0_txp, 
	output wire xphy0_txn, 
	input wire xphy0_rxp, 
	input wire xphy0_rxn,
	output wire xphy1_txp, 
	output wire xphy1_txn, 
	input wire xphy1_rxp, 
	input wire xphy1_rxn,
`ifdef ENABLE_PHY2
	output wire xphy2_txp, 
	output wire xphy2_txn, 
	input wire xphy2_rxp, 
	input wire xphy2_rxn,
`endif
`ifdef ENABLE_PHY3
	output wire xphy3_txp, 
	output wire xphy3_txn, 
	input wire xphy3_rxp, 
	input wire xphy3_rxn,
`endif
`ifdef ENABLE_PHY4
	input wire xphy4_refclk_p, 
	input wire xphy4_refclk_n, 
	output wire xphy4_txp, 
	output wire xphy4_txn, 
	input wire xphy4_rxp, 
	input wire xphy4_rxn,
`endif
	output wire fmc_ok_led,
	input wire [1:0] fmc_gbtclk0_fsel,
	output wire fmc_clk_312_5,
`ifdef ENABLE_GMII
	input wire sysclk_p,
	input wire sysclk_n,
	input wire sgmiiclk_p,
	input wire sgmiiclk_n,
	output wire gphy0_reset,
	output wire gphy0_mdc,
	output wire gphy0_mdio,
	input wire gphy0_crs,
	input wire gphy0_col,
	input wire gphy0_rxclk,
	input wire gphy0_rxdv,
	input wire gphy0_rxer,
	input wire [7:0] gphy0_rxd,
	output wire gphy0_txclk,
	output wire gphy0_gtxclk,
	output wire gphy0_txen,
	output wire gphy0_txer,
	output wire [7:0] gphy0_txd,
	output wire gphy0_int,
`endif
	// BUTTON
	input wire button_n,
	input wire button_s,
	input wire button_w,
	input wire button_e,
	input wire button_c,
	// DIP SW
	input wire [3:0] dipsw,
	// Diagnostic LEDs
	output wire [7:0] led	   
);

// Clock and Reset
wire sys_rst;
assign sys_rst = button_c; // 1'b0;

wire clk_200, clk_125;

`ifdef ENABLE_GMII
IBUFDS IBUFDS_clk_200 (
	.I(sysclk_p),
	.IB(sysclk_n),
	.O(clk_200)
);
//IBUFDS IBUFDS_sgmiiclk_1 (
//	.I (sgmiiclk_p),
//	.IB(sgmiiclk_n),
//	.O (clk_125)
//);
assign gphy0_gtxclk = clk_125;
`endif
 
// -------------------
// -- Local Signals --
// -------------------

// Xilinx Hard Core Instantiation

wire		clk156;

wire [63:0]	xgmii0_txd, xgmii1_txd, xgmii2_txd, xgmii3_txd, xgmii4_txd;
wire [7:0]	xgmii0_txc, xgmii1_txc, xgmii2_txc, xgmii3_txc, xgmii4_txc;
wire [63:0]	xgmii0_rxd, xgmii1_rxd, xgmii2_rxd, xgmii3_rxd, xgmii4_rxd;
wire [7:0]	xgmii0_rxc, xgmii1_rxc, xgmii2_rxc, xgmii3_rxc, xgmii4_rxc;
  
wire [7:0]	xphy0_status, xphy1_status, xphy2_status, xphy3_status, xphy4_status;
  

wire		nw0_reset, nw1_reset, nw2_reset, nw3_reset, nw4_reset;
wire		txusrclk;
wire		txusrclk2;
wire		txclk322;
wire		areset_refclk_bufh;
wire		areset_clk156;
wire		mmcm_locked_clk156;
wire		gttxreset_txusrclk2;
wire		gttxreset;
wire		gtrxreset;
wire		txuserrdy;
wire		qplllock;
wire		qplloutclk;
wire		qplloutrefclk;
wire		qplloutclk1;
wire		qplloutclk2;
wire		qplloutrefclk1;
wire		qplloutrefclk2;
wire		reset_counter_done; 
wire		nw0_reset_i, nw1_reset_i, nw2_reset_i, nw3_reset_i, nw4_reset_i;
wire		xphy0_tx_resetdone, xphy1_tx_resetdone, xphy2_tx_resetdone, xphy3_tx_resetdone, xphy4_tx_resetdone;


  
//- Network Path signal declarations
wire [4:0]	xphy0_prtad;
wire		xphy0_signal_detect;
wire [4:0]	xphy1_prtad;
wire		xphy1_signal_detect;
wire [4:0]	xphy2_prtad;
wire		xphy2_signal_detect;
wire [4:0]	xphy3_prtad;
wire		xphy3_signal_detect;
wire [4:0]	xphy4_prtad;
wire		xphy4_signal_detect;
  

wire		xphyrefclk_i;    
wire		dclk_i;		     

wire		gt0_pma_resetout_i;
wire		gt0_pcs_resetout_i;	 
wire		gt0_drpen_i;		
wire		gt0_drpwe_i;		
wire [15:0]	gt0_drpaddr_i;	      
wire [15:0]	gt0_drpdi_i;		
wire [15:0]	gt0_drpdo_i;		
wire		gt0_drprdy_i;	       
wire		gt0_resetdone_i;	    
wire [31:0]	gt0_txd_i;		  
wire [7:0]	gt0_txc_i;		  
wire [31:0]	gt0_rxd_i;		  
wire [7:0]	gt0_rxc_i;		  
wire [2:0]	gt0_loopback_i;	     
wire		gt0_txclk322_i;	     
wire		gt0_rxclk322_i;	     

wire		gt1_pma_resetout_i;
wire		gt1_pcs_resetout_i;	 
wire		gt1_drpen_i;		
wire		gt1_drpwe_i;		
wire [15:0]	gt1_drpaddr_i;	      
wire [15:0]	gt1_drpdi_i;		
wire [15:0]	gt1_drpdo_i;		
wire		gt1_drprdy_i;	       
wire		gt1_resetdone_i;	    
wire [31:0]	gt1_txd_i;		  
wire [7:0]	gt1_txc_i;		  
wire [31:0]	gt1_rxd_i;		  
wire [7:0]	gt1_rxc_i;		  
wire [2:0]	gt1_loopback_i;	     
wire		gt1_txclk322_i;	     
wire		gt1_rxclk322_i;	     

wire		gt2_pma_resetout_i;
wire		gt2_pcs_resetout_i;	 
wire		gt2_drpen_i;		
wire		gt2_drpwe_i;		
wire [15:0]	gt2_drpaddr_i;	      
wire [15:0]	gt2_drpdi_i;		
wire [15:0]	gt2_drpdo_i;		
wire		gt2_drprdy_i;	       
wire		gt2_resetdone_i;	    
wire [31:0]	gt2_txd_i;		  
wire [7:0]	gt2_txc_i;		  
wire [31:0]	gt2_rxd_i;		  
wire [7:0]	gt2_rxc_i;		  
wire [2:0]	gt2_loopback_i;	     
wire		gt2_txclk322_i;	     
wire		gt2_rxclk322_i;	     

wire		gt3_pma_resetout_i;
wire		gt3_pcs_resetout_i;	 
wire		gt3_drpen_i;		
wire		gt3_drpwe_i;		
wire [15:0]	gt3_drpaddr_i;	      
wire [15:0]	gt3_drpdi_i;		
wire [15:0]	gt3_drpdo_i;		
wire		gt3_drprdy_i;	       
wire		gt3_resetdone_i;	    
wire [31:0]	gt3_txd_i;		  
wire [7:0]	gt3_txc_i;		  
wire [31:0]	gt3_rxd_i;		  
wire [7:0]	gt3_rxc_i;		  
wire [2:0]	gt3_loopback_i;	     
wire		gt3_txclk322_i;	     
wire		gt3_rxclk322_i;	     

wire		gt4_pma_resetout_i;
wire		gt4_pcs_resetout_i;	 
wire		gt4_drpen_i;		
wire		gt4_drpwe_i;		
wire [15:0]	gt4_drpaddr_i;	      
wire [15:0]	gt4_drpdi_i;		
wire [15:0]	gt4_drpdo_i;		
wire		gt4_drprdy_i;	       
wire		gt4_resetdone_i;	    
wire [31:0]	gt4_txd_i;		  
wire [7:0]	gt4_txc_i;		  
wire [31:0]	gt4_rxd_i;		  
wire [7:0]	gt4_rxc_i;		  
wire [2:0]	gt4_loopback_i;	     
wire		gt4_txclk322_i;	     
wire		gt4_rxclk322_i;	     
  
// ---------------
// Clock and Reset
// ---------------

wire		gt0_pma_resetout;
wire		gt0_pcs_resetout;
wire		gt0_drpen;
wire		gt0_drpwe;
wire [15:0]	gt0_drpaddr;
wire [15:0]	gt0_drpdi;
wire [15:0]	gt0_drpdo;
wire		gt0_drprdy;
wire		gt0_resetdone;
wire [63:0]	gt0_txd;
wire [7:0]	gt0_txc;
wire [63:0]	gt0_rxd;
wire [7:0]	gt0_rxc;
wire [2:0]	gt0_loopback;

wire		gt1_pma_resetout;
wire		gt1_pcs_resetout;
wire		gt1_drpen;
wire		gt1_drpwe;
wire [15:0]	gt1_drpaddr;
wire [15:0]	gt1_drpdi;
wire [15:0]	gt1_drpdo;
wire		gt1_drprdy;
wire		gt1_resetdone;
wire [63:0]	gt1_txd;
wire [7:0]	gt1_txc;
wire [63:0]	gt1_rxd;
wire [7:0]	gt1_rxc;
wire [2:0]	gt1_loopback;

wire		gt2_pma_resetout;
wire		gt2_pcs_resetout;
wire		gt2_drpen;
wire		gt2_drpwe;
wire [15:0]	gt2_drpaddr;
wire [15:0]	gt2_drpdi;
wire [15:0]	gt2_drpdo;
wire		gt2_drprdy;
wire		gt2_resetdone;
wire [63:0]	gt2_txd;
wire [7:0]	gt2_txc;
wire [63:0]	gt2_rxd;
wire [7:0]	gt2_rxc;
wire [2:0]	gt2_loopback;

wire		gt3_pma_resetout;
wire		gt3_pcs_resetout;
wire		gt3_drpen;
wire		gt3_drpwe;
wire [15:0]	gt3_drpaddr;
wire [15:0]	gt3_drpdi;
wire [15:0]	gt3_drpdo;
wire		gt3_drprdy;
wire		gt3_resetdone;
wire [63:0]	gt3_txd;
wire [7:0]	gt3_txc;
wire [63:0]	gt3_rxd;
wire [7:0]	gt3_rxc;
wire [2:0]	gt3_loopback;

wire		gt4_pma_resetout;
wire		gt4_pcs_resetout;
wire		gt4_drpen;
wire		gt4_drpwe;
wire [15:0]	gt4_drpaddr;
wire [15:0]	gt4_drpdi;
wire [15:0]	gt4_drpdo;
wire		gt4_drprdy;
wire		gt4_resetdone;
wire [63:0]	gt4_txd;
wire [7:0]	gt4_txc;
wire [63:0]	gt4_rxd;
wire [7:0]	gt4_rxc;
wire [2:0]	gt4_loopback;

// ---------------
// GT0 instance
// ---------------
 
assign xphy0_prtad = 5'd0;
assign xphy0_signal_detect = 1'b1;
assign nw0_reset = nw0_reset_i;

network_path network_path_inst_0 (
	//XGEMAC PHY IO
	.txusrclk(txusrclk),
	.txusrclk2(txusrclk2),
	.txclk322(txclk322),
	.areset_refclk_bufh(areset_refclk_bufh),
	.areset_clk156(areset_clk156),
	.mmcm_locked_clk156(mmcm_locked_clk156),
	.gttxreset_txusrclk2(gttxreset_txusrclk2),
	.gttxreset(gttxreset),
	.gtrxreset(gtrxreset),
	.txuserrdy(txuserrdy),
	.qplllock(qplllock),
`ifdef USE_DIFF_QUAD
	.qplloutclk(qplloutclk1),
	.qplloutrefclk(qplloutrefclk1),
`else
	.qplloutclk(qplloutclk),
	.qplloutrefclk(qplloutrefclk),
`endif
	.reset_counter_done(reset_counter_done), 
	.txp(xphy0_txp),
	.txn(xphy0_txn),
	.rxp(xphy0_rxp),
	.rxn(xphy0_rxn),
	.tx_resetdone(xphy0_tx_resetdone),
    
	.signal_detect(xphy0_signal_detect),
	.tx_fault(sfp_tx_fault[0]),
	.prtad(xphy0_prtad),
	.xphy_status(xphy0_status),
	.clk156(clk156),
	.soft_reset(),
	.sys_rst((sys_rst & ~mmcm_locked_clk156)),
	.nw_rst_out(nw0_reset_i),   
	.dclk(dclk_i),
	.xgmii_txd(xgmii0_txd),
	.xgmii_txc(xgmii0_txc),
	.xgmii_rxd(xgmii0_rxd),
	.xgmii_rxc(xgmii0_rxc)
); 


// ---------------
// GT1 instance
// ---------------

assign xphy1_prtad  = 5'd1;
assign xphy1_signal_detect = 1'b1;
assign nw1_reset = nw1_reset_i;
 
network_path network_path_inst_1 (
	//XGEMAC PHY IO
	.txusrclk(txusrclk),
	.txusrclk2(txusrclk2),
	.txclk322(),
	.areset_refclk_bufh(areset_refclk_bufh),
	.areset_clk156(areset_clk156),
	.mmcm_locked_clk156(mmcm_locked_clk156),
	.gttxreset_txusrclk2(gttxreset_txusrclk2),
	.gttxreset(gttxreset),
	.gtrxreset(gtrxreset),
	.txuserrdy(txuserrdy),
	.qplllock(qplllock),
`ifdef USE_DIFF_QUAD
	.qplloutclk(qplloutclk2),
	.qplloutrefclk(qplloutrefclk2),
`else
	.qplloutclk(qplloutclk),
	.qplloutrefclk(qplloutrefclk),
`endif
	.reset_counter_done(reset_counter_done), 
	.txp(xphy1_txp),
	.txn(xphy1_txn),
	.rxp(xphy1_rxp),
	.rxn(xphy1_rxn),
	.tx_resetdone(xphy1_tx_resetdone),
    
	.signal_detect(xphy1_signal_detect),
	.tx_fault(sfp_tx_fault[1]),
	.prtad(xphy1_prtad),
	.xphy_status(xphy1_status),
	.clk156(clk156),
	.soft_reset(),
	.sys_rst((sys_rst & ~mmcm_locked_clk156)),
	.nw_rst_out(nw1_reset_i),   
	.dclk(dclk_i), 
	.xgmii_txd(xgmii1_txd),
	.xgmii_txc(xgmii1_txc),
	.xgmii_rxd(xgmii1_rxd),
	.xgmii_rxc(xgmii1_rxc)
); 

`ifdef ENABLE_PHY2
// ---------------
// GT2 instance
// ---------------

assign xphy2_prtad  = 5'd2;
assign xphy2_signal_detect = 1'b1;
assign nw2_reset = nw2_reset_i;
 
network_path network_path_inst_2 (
	//XGEMAC PHY IO
	.txusrclk(txusrclk),
	.txusrclk2(txusrclk2),
	.txclk322(),
	.areset_refclk_bufh(areset_refclk_bufh),
	.areset_clk156(areset_clk156),
	.mmcm_locked_clk156(mmcm_locked_clk156),
	.gttxreset_txusrclk2(gttxreset_txusrclk2),
	.gttxreset(gttxreset),
	.gtrxreset(gtrxreset),
	.txuserrdy(txuserrdy),
	.qplllock(qplllock),
`ifdef USE_DIFF_QUAD
	.qplloutclk(qplloutclk2),
	.qplloutrefclk(qplloutrefclk2),
`else
	.qplloutclk(qplloutclk),
	.qplloutrefclk(qplloutrefclk),
`endif
	.reset_counter_done(reset_counter_done), 
	.txp(xphy2_txp),
	.txn(xphy2_txn),
	.rxp(xphy2_rxp),
	.rxn(xphy2_rxn),
	.tx_resetdone(xphy2_tx_resetdone),
    
	.signal_detect(xphy2_signal_detect),
	.tx_fault(sfp_tx_fault[2]),
	.prtad(xphy2_prtad),
	.xphy_status(xphy2_status),
	.clk156(clk156),
	.soft_reset(),
	.sys_rst((sys_rst & ~mmcm_locked_clk156)),
	.nw_rst_out(nw2_reset_i),   
	.dclk(dclk_i), 
	.xgmii_txd(xgmii2_txd),
	.xgmii_txc(xgmii2_txc),
	.xgmii_rxd(xgmii2_rxd),
	.xgmii_rxc(xgmii2_rxc)
); 
`endif

`ifdef ENABLE_PHY3
// ---------------
// GT3 instance
// ---------------

assign xphy3_prtad  = 5'd3;
assign xphy3_signal_detect = 1'b1;
assign nw3_reset = nw3_reset_i;
 
network_path network_path_inst_3 (
	//XGEMAC PHY IO
	.txusrclk(txusrclk),
	.txusrclk2(txusrclk2),
	.txclk322(),
	.areset_refclk_bufh(areset_refclk_bufh),
	.areset_clk156(areset_clk156),
	.mmcm_locked_clk156(mmcm_locked_clk156),
	.gttxreset_txusrclk2(gttxreset_txusrclk2),
	.gttxreset(gttxreset),
	.gtrxreset(gtrxreset),
	.txuserrdy(txuserrdy),
	.qplllock(qplllock),
`ifdef USE_DIFF_QUAD
	.qplloutclk(qplloutclk2),
	.qplloutrefclk(qplloutrefclk2),
`else
	.qplloutclk(qplloutclk),
	.qplloutrefclk(qplloutrefclk),
`endif
	.reset_counter_done(reset_counter_done), 
	.txp(xphy3_txp),
	.txn(xphy3_txn),
	.rxp(xphy3_rxp),
	.rxn(xphy3_rxn),
	.tx_resetdone(xphy3_tx_resetdone),
    
	.signal_detect(xphy3_signal_detect),
	.tx_fault(sfp_tx_fault[3]),
	.prtad(xphy3_prtad),
	.xphy_status(xphy3_status),
	.clk156(clk156),
	.soft_reset(),
	.sys_rst((sys_rst & ~mmcm_locked_clk156)),
	.nw_rst_out(nw3_reset_i),   
	.dclk(dclk_i), 
	.xgmii_txd(xgmii3_txd),
	.xgmii_txc(xgmii3_txc),
	.xgmii_rxd(xgmii3_rxd),
	.xgmii_rxc(xgmii3_rxc)
); 
`endif

`ifdef ENABLE_PHY4
// ---------------
// GT4 instance
// ---------------

assign xphy4_prtad  = 5'd4;
assign xphy4_signal_detect = 1'b1;
assign nw4_reset = nw4_reset_i;
 
network_path network_path_inst_4 (
	//XGEMAC PHY IO
	.txusrclk(txusrclk),
	.txusrclk2(txusrclk2),
	.txclk322(txclk322),
	.areset_refclk_bufh(areset_refclk_bufh),
	.areset_clk156(areset_clk156),
	.mmcm_locked_clk156(mmcm_locked_clk156),
	.gttxreset_txusrclk2(gttxreset_txusrclk2),
	.gttxreset(gttxreset),
	.gtrxreset(gtrxreset),
	.txuserrdy(txuserrdy),
	.qplllock(qplllock),
`ifdef USE_DIFF_QUAD
	.qplloutclk(qplloutclk2),
	.qplloutrefclk(qplloutrefclk2),
`else
	.qplloutclk(qplloutclk),
	.qplloutrefclk(qplloutrefclk),
`endif
	.reset_counter_done(reset_counter_done), 
	.txp(xphy4_txp),
	.txn(xphy4_txn),
	.rxp(xphy4_rxp),
	.rxn(xphy4_rxn),
	.tx_resetdone(xphy4_tx_resetdone),
    
	.signal_detect(xphy4_signal_detect),
	.tx_fault(sfp_tx_fault[3]),
	.prtad(xphy4_prtad),
	.xphy_status(xphy4_status),
	.clk156(clk156),
	.soft_reset(),
	.sys_rst((sys_rst & ~mmcm_locked_clk156)),
	.nw_rst_out(nw4_reset_i),   
	.dclk(dclk_i), 
	.xgmii_txd(xgmii4_txd),
	.xgmii_txc(xgmii4_txc),
	.xgmii_rxd(xgmii4_rxd),
	.xgmii_rxc(xgmii4_rxc)
); 
`endif    //ENABLE_XGMII4

`ifdef USE_DIFF_QUAD
xgbaser_gt_diff_quad_wrapper xgbaser_gt_wrapper_inst_0 (
	.areset(sys_rst),
	.refclk_p(xphy0_refclk_p),
	.refclk_n(xphy0_refclk_n),
	.txclk322(txclk322),
	.gt0_tx_resetdone(xphy0_tx_resetdone),
	.gt1_tx_resetdone(xphy1_tx_resetdone),

	.areset_refclk_bufh(areset_refclk_bufh),
	.areset_clk156(areset_clk156),
	.mmcm_locked_clk156(mmcm_locked_clk156),
	.gttxreset_txusrclk2(gttxreset_txusrclk2),
	.gttxreset(gttxreset),
	.gtrxreset(gtrxreset),
	.txuserrdy(txuserrdy),
	.reset_counter_done(reset_counter_done),
	.txusrclk(txusrclk),
	.txusrclk2(txusrclk2),
	.clk156(clk156),
	.dclk(dclk_i),
	.qpllreset(),
	.qplllock(qplllock),
	.qplloutclk1(qplloutclk1), 
	.qplloutrefclk1(qplloutrefclk1), 
	.qplloutclk2(qplloutclk2), 
	.qplloutrefclk2(qplloutrefclk2) 
);
`else
xgbaser_gt_same_quad_wrapper xgbaser_gt_wrapper_inst_0 (
	.areset(sys_rst),
	.refclk_p(xphy0_refclk_p),
	.refclk_n(xphy0_refclk_n),
	.txclk322(txclk322),
	.gt0_tx_resetdone(xphy0_tx_resetdone),
	.gt1_tx_resetdone(xphy1_tx_resetdone),

	.areset_refclk_bufh(areset_refclk_bufh),
	.areset_clk156(areset_clk156),
	.mmcm_locked_clk156(mmcm_locked_clk156),
	.gttxreset_txusrclk2(gttxreset_txusrclk2),
	.gttxreset(gttxreset),
	.gtrxreset(gtrxreset),
	.txuserrdy(txuserrdy),
	.reset_counter_done(reset_counter_done),
	.txusrclk(txusrclk),
	.txusrclk2(txusrclk2),
	.clk156(clk156),
	.dclk(dclk_i),
	.qpllreset(),
	.qplllock(qplllock),
	.qplloutclk(qplloutclk), 
	.qplloutrefclk(qplloutrefclk) 
);
`endif    //USE_DIFF_QUAD



// ---------------
// L2 switch
// ---------------
l2switch l2switch_inst (
	.sys_rst(sys_rst),
	.sys_clk(clk156),

	.xgmii_0_txd(xgmii0_txd),
	.xgmii_0_txc(xgmii0_txc),
	.xgmii_0_rxd(xgmii0_rxd),
	.xgmii_0_rxc(xgmii0_rxc),
	.xphy_0_status(xphy0_status),

	.xgmii_1_txd(xgmii1_txd),
	.xgmii_1_txc(xgmii1_txc),
	.xgmii_1_rxd(xgmii1_rxd),
	.xgmii_1_rxc(xgmii1_rxc),
	.xphy_1_status(xphy1_status),

`ifdef ENABLE_PHY2
	.xgmii_2_txd(xgmii2_txd),
	.xgmii_2_txc(xgmii2_txc),
	.xgmii_2_rxd(xgmii2_rxd),
	.xgmii_2_rxc(xgmii2_rxc),
	.xphy_2_status(xphy2_status),
`endif

`ifdef ENABLE_PHY3
	.xgmii_3_txd(xgmii3_txd),
	.xgmii_3_txc(xgmii3_txc),
	.xgmii_3_rxd(xgmii3_rxd),
	.xgmii_3_rxc(xgmii3_rxc),
	.xphy_3_status(xphy3_status),
`endif

	.button_n(button_n),
	.button_s(button_s),
	.button_w(button_w),
	.button_e(button_e),
	.button_c(button_c),
	.dipsw(dipsw),
	.led()
);

assign led[0] = xphy0_status[0]; 
assign led[1] = xphy1_status[0]; 
assign led[2] = xphy2_status[0]; 
assign led[3] = xphy3_status[0]; 
assign led[4] = 1'b0;
assign led[5] = 1'b0;
assign led[6] = 1'b0;
assign led[7] = 1'b0;

//- Tie off related to SFP+
assign sfp_tx_disable = 5'b10000;	// all ports enable

//- This LED indicates FMC connected OK
assign fmc_ok_led = 1'b1;
//- This LED indicates FMC GBTCLK0 programmed OK
assign fmc_clk_312_5 = (fmc_gbtclk0_fsel == 2'b11) ? 1'b1 : 1'b0;

endmodule
`default_nettype wire
