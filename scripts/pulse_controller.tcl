source "$base_dir/lib/utils.tcl"

set custom_ip_dir "$bin_dir/custom_ip"
set pulse_ctrl_dir "$custom_ip_dir/pulse_controller_5.0"

init_project [ensure_project pulse_controller_v5_0 "$custom_ip_dir"]

set src_set [ensure_fileset -srcset sources_1]

# Set IP repository paths
set_property "ip_repo_paths" "[file normalize "$pulse_ctrl_dir"]" $src_set

set axi_src "$pulse_ctrl_dir/hdl/pulse_controller_v5_0_S00_AXI.v"
set ctrl_src "$pulse_ctrl_dir/hdl/pulse_controller_v5_0.v"

set files [list "[file normalize "$axi_src"]"\
               "[file normalize "$ctrl_src"]"]
add_files -norecurse -fileset $src_set $files

# Set 'sources_1' fileset file properties for remote files
set_property "used_in_implementation" "0" \
    [get_files -of_objects $src_set [list "*$axi_src"]]

set_property "used_in_implementation" "0" \
    [get_files -of_objects $src_set [list "*$ctrl_src"]]

# Set 'sources_1' fileset properties
set_property "top" "pulse_controller_v5_0" $src_set

ensure_fileset -constrset constrs_1
set sim_set [ensure_fileset -simset sim_1]

# Set 'sim_1' fileset properties
set_property "top" "pulse_controller_v5_0" $sim_set

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
