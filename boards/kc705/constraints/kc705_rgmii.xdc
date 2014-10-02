#sysclk (200MHz)
set_property PACKAGE_PIN AD12 [get_ports sysclk_p]
set_property IOSTANDARD LVDS [get_ports sysclk_p]
set_property PACKAGE_PIN AD11 [get_ports sysclk_n]
set_property IOSTANDARD LVDS [get_ports sysclk_n]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_200]

#sgmiiclk (125MHz)
#set_property PACKAGE_PIN G8 [get_ports sgmiiclk_p]
#set_property IOSTANDARD LVDS [get_ports sgmiiclk_p]
#set_property PACKAGE_PIN G7 [get_ports sgmiiclk_n]
#set_property IOSTANDARD LVDS [get_ports sgmiiclk_n]

set_property PACKAGE_PIN L20 [get_ports gphy0_reset]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_reset]

set_property PACKAGE_PIN R23 [get_ports gphy0_mdc]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_mdc]
set_property PACKAGE_PIN J21 [get_ports gphy0_mdio]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_mdio]

set_property PACKAGE_PIN R30 [get_ports gphy0_crs]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_crs]
set_property PACKAGE_PIN W19 [get_ports gphy0_col]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_col]

set_property PACKAGE_PIN U27 [get_ports gphy0_rxclk]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_rxclk]

set_property PACKAGE_PIN R28 [get_ports gphy0_rxdv]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_rxdv]
set_property PACKAGE_PIN V26 [get_ports gphy0_rxer]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_rxer]

set_property PACKAGE_PIN T28 [get_ports gphy0_rxd[7]]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_rxd[7]]
set_property PACKAGE_PIN T26 [get_ports gphy0_rxd[6]]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_rxd[6]]
set_property PACKAGE_PIN T27 [get_ports gphy0_rxd[5]]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_rxd[5]]
set_property PACKAGE_PIN R19 [get_ports gphy0_rxd[4]]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_rxd[4]]
set_property PACKAGE_PIN U28 [get_ports gphy0_rxd[3]]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_rxd[3]]
set_property PACKAGE_PIN T25 [get_ports gphy0_rxd[2]]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_rxd[2]]
set_property PACKAGE_PIN U25 [get_ports gphy0_rxd[1]]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_rxd[1]]
set_property PACKAGE_PIN U30 [get_ports gphy0_rxd[0]]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_rxd[0]]

set_property PACKAGE_PIN M28 [get_ports gphy0_txclk]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_txclk]
set_property PACKAGE_PIN K30 [get_ports gphy0_gtxclk]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_gtxclk]

set_property PACKAGE_PIN M27 [get_ports gphy0_txen]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_txen]
set_property PACKAGE_PIN N29 [get_ports gphy0_txer]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_txer]

set_property PACKAGE_PIN J28 [get_ports gphy0_txd[7]]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_txd[7]]
set_property PACKAGE_PIN L30 [get_ports gphy0_txd[6]]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_txd[6]]
set_property PACKAGE_PIN K26 [get_ports gphy0_txd[5]]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_txd[5]]
set_property PACKAGE_PIN J26 [get_ports gphy0_txd[4]]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_txd[4]]
set_property PACKAGE_PIN L28 [get_ports gphy0_txd[3]]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_txd[3]]
set_property PACKAGE_PIN M29 [get_ports gphy0_txd[2]]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_txd[2]]
set_property PACKAGE_PIN N25 [get_ports gphy0_txd[1]]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_txd[1]]
set_property PACKAGE_PIN N27 [get_ports gphy0_txd[0]]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_txd[0]]

set_property PACKAGE_PIN N30 [get_ports gphy0_int]
set_property IOSTANDARD LVCMOS25 [get_ports gphy0_int]
