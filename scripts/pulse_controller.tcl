source "$base_dir/lib/utils.tcl"

set custom_ip_dir "$bin_dir/custom_ip"
set pulse_ctrl_dir "$custom_ip_dir/pulse_controller_5.0"
set src_dir "$custom_ip_dir/pulse_controller_v5_0.srcs"

set proj [ensure_project pulse_controller_v5_0 "$custom_ip_dir"]
init_project $proj
set_property -name "part" -value "xc7z020clg484-1" -objects $proj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $proj
set_property -name "simulator_language" -value "Mixed" -objects $proj

set src_set [ensure_fileset -srcset sources_1]

# Set IP repository paths
set_property -name "ip_repo_paths" -value "[file normalize "$pulse_ctrl_dir"]" -objects $src_set

set axi_src "$pulse_ctrl_dir/hdl/pulse_controller_v5_0_S00_AXI.sv"
set ctrl_src "$pulse_ctrl_dir/hdl/pulse_controller_v5_0.sv"

set files [list "[file normalize "$axi_src"]"\
               "[file normalize "$ctrl_src"]"]
add_files -norecurse -fileset $src_set $files

# Set 'sources_1' fileset file properties for remote files
set axi_file [get_files -of_objects $src_set [list "*$axi_src"]]
set_property -name "file_type" -value "SystemVerilog" -objects $axi_file
set_property -name "used_in" -value "synthesis simulation" -objects $axi_file
set_property -name "used_in_implementation" -value "0" -objects $axi_file

set ctrl_file [get_files -of_objects $src_set [list "*$ctrl_src"]]
set_property -name "file_type" -value "SystemVerilog" -objects $ctrl_file
set_property -name "used_in" -value "synthesis simulation" -objects $ctrl_file
set_property -name "used_in_implementation" -value "0" -objects $ctrl_file

# Set 'sources_1' fileset properties
set_property -name "top" -value "pulse_controller_v5_0" -objects $src_set

# create_ip -name div_gen -vendor xilinx.com -library ip -version 5.1 \
#     -module_name div_gen_0
# set_property -dict \
#     [list CONFIG.dividend_and_quotient_width {64} \
#          CONFIG.dividend_has_tuser {true} \
#          CONFIG.dividend_tuser_width {4} \
#          CONFIG.divisor_width {32} \
#          CONFIG.FlowControl {Blocking} \
#          CONFIG.OutTready {true} \
#          CONFIG.latency_configuration {Manual} \
#          CONFIG.latency {16} \
#          CONFIG.fractional_width {32}] [get_ips div_gen_0]
# # Generate template (optional)
# set div_gen_file "$src_dir/sources_1/ip/div_gen_0/div_gen_0.xci"
# generate_target {instantiation_template} [get_files $div_gen_file]

ensure_fileset -constrset constrs_1
set sim_set [ensure_fileset -simset sim_1]

# Set 'sim_1' fileset properties
set_property -name "top" -value "pulse_controller_v5_0" -objects $sim_set

ensure_synth_run synth_1 constrs_1
ensure_impl_run impl_1 synth_1 constrs_1

ipx::package_project -root_dir $pulse_ctrl_dir
set cur_core [ipx::current_core]
set_property vendor xilinx $cur_core
set_property taxonomy /UserIP $cur_core
set_property name pulse_controller $cur_core
set_property version 5.0 $cur_core
set_property display_name pulse_controller_v5_0 $cur_core
set_property description {Pulse Controller} $cur_core
set_property taxonomy \
    /Embedded_Processing/AXI_Peripheral/Low_Speed_Peripheral $cur_core
set_property core_revision 2 $cur_core
ipx::create_xgui_files $cur_core
ipx::update_checksums $cur_core
ipx::save_core $cur_core
update_ip_catalog -rebuild -repo_path $pulse_ctrl_dir

write_project_tcl -quiet "$bin_dir/pulse_controller-orig.tcl"
