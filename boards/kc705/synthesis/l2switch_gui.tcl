# PlanAhead Launch Script
set design_top top
set sim_top board
set device xc7k325t-2-ffg900
set proj_dir runs 
set impl_const ../constraints/l2switch.xdc

create_project -name ${design_top} -force -dir "./${proj_dir}" -part ${device}

# Project Settings

set_property top ${design_top} [current_fileset]
set_property verilog_define {{USE_VIVADO=1}} [current_fileset]

add_files -fileset constrs_1 -norecurse ../constraints/kc705_rgmii.xdc
set_property used_in_synthesis true [get_files ../constraints/kc705_rgmii.xdc]
add_files -fileset constrs_1 -norecurse ./${impl_const}
set_property used_in_synthesis true [get_files ./${impl_const}]

# Project Design Files from IP Catalog (comment out IPs using legacy Coregen cores)
import_ip -files {../ip_catalog/ten_gig_eth_pcs_pma_ip.xci} -name ten_gig_eth_pcs_pma_ip
import_ip -files {../ip_catalog/sfifo72_10.xci} -name sfifo72_10
import_ip -files {../ip_catalog/afifo72_11r.xci} -name afifo72_11r
import_ip -files {../ip_catalog/afifo72_12w.xci} -name afifo72_12w

set_property USED_IN {synthesis implementation} [get_files ../synthesis/runs/top.srcs/sources_1/ip/ten_gig_eth_pcs_pma_ip/ten_gig_eth_pcs_pma_ip.xci]
set_property USED_IN {synthesis implementation} [get_files ../synthesis/runs/top.srcs/sources_1/ip/sfifo72_10/sfifo72_10.xci]
#set_property USED_IN {synthesis implementation} [get_files /home/tmatsuya/l2switch/boards/kc705/synthesis/runs/top.srcs/sources_1/ip/ten_gig_eth_pcs_pma_ip/ten_gig_eth_pcs_pma_ip.xci]
#set_property USED_IN {synthesis implementation} [get_files /home/tmatsuya/l2switch/boards/kc705/synthesis/runs/top.srcs/sources_1/ip/sfifo72_10/sfifo72_10.xci]

# Other Custom logic sources/rtl files
read_verilog "../rtl/network_path/xgbaser_gt_diff_quad_wrapper.v"
read_verilog "../rtl/network_path/xgbaser_gt_same_quad_wrapper.v"
read_verilog "../rtl/network_path/network_path.v"
read_verilog "../rtl/network_path/ten_gig_eth_pcs_pma_ip_GT_Common_wrapper.v"
read_verilog "../rtl/top.v"
read_verilog "../rtl/l2switch.v"
read_verilog "../rtl/xgmii2fifo72.v"
read_verilog "../rtl/fifo72toxgmii.v"
read_verilog "../../../cores/gmii2xgmii/rtl/gmii2xgmii.v"
read_verilog "../../../cores/xgmii2gmii/rtl/xgmii2gmii.v"

set_property USED_IN {synthesis implementation} [get_files ../rtl/top.v]
set_property USED_IN {synthesis implementation} [get_files ../rtl/network_path/xgbaser_gt_diff_quad_wrapper.v]
set_property USED_IN {synthesis implementation} [get_files ../rtl/network_path/xgbaser_gt_same_quad_wrapper.v]
set_property USED_IN {synthesis implementation} [get_files ../rtl/network_path/network_path.v]
set_property USED_IN {synthesis implementation} [get_files ../rtl/network_path/ten_gig_eth_pcs_pma_ip_GT_Common_wrapper.v]


# NGC files
#read_edif "../ip_cores/dma/netlist/eval/dma_back_end_axi.ngc"

#Setting Rodin Sythesis options
set_property flow {Vivado Synthesis 2014} [get_runs synth_1]
set_property steps.phys_opt_design.is_enabled true [get_runs impl_1]

set_property flow {Vivado Implementation 2014} [get_runs impl_1]

####################
# Set up Simulations
# Get the current working directory
#set CurrWrkDir [pwd]
#
#if [info exists env(MODELSIM)] {
#  puts "MODELSIM env pointing to ini exists..."
#} elseif {[file exists $CurrWrkDir/modelsim.ini] == 1} {
#  set env(MODELSIM) $CurrWrkDir/modelsim.ini
#  puts "Setting \$MODELSIM to modelsim.ini"
#} else {
#  puts "\n\nERROR! modelsim.ini not found!"
#  exit
#}

#set_property target_simulator ModelSim [current_project]
#set_property -name modelsim.vlog_more_options -value +acc -objects [get_filesets sim_1]
#set_property -name modelsim.vsim_more_options -value {+notimingchecks -do "../../../../wave.do; run -all" +TESTNAME=basic_test -GSIM_COLLISION_CHECK=NONE } -objects [get_filesets sim_1]
#set_property compxlib.compiled_library_dir {} [current_project]
#
#set_property include_dirs { ../testbench ../testbench/dsport ../include } [get_filesets sim_1]
#

read_verilog "../test/l2switch_tb.v"
set_property USED_IN simulation [get_files ../test/l2switch_tb.v]

