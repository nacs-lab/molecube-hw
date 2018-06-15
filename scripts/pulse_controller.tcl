#

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
set clk_src "$pulse_ctrl_dir/hdl/clock_controller.sv"
set spi_src "$pulse_ctrl_dir/hdl/spi_controller.sv"
set ctrl_src "$pulse_ctrl_dir/hdl/pulse_controller_v5_0.v"

set files [list "[file normalize "$axi_src"]" \
               "[file normalize "$clk_src"]" \
               "[file normalize "$spi_src"]" \
               "[file normalize "$ctrl_src"]"]
add_files -norecurse -fileset $src_set $files

# Set 'sources_1' fileset file properties for remote files
foreach src [list "$axi_src" "$clk_src" "$spi_src"] {
    set file [get_files -of_objects $src_set [list "*$src"]]
    set_property -name "file_type" -value "SystemVerilog" -objects $file
    set_property -name "used_in" -value "synthesis simulation" -objects $file
    set_property -name "used_in_implementation" -value "0" -objects $file
}

# Set 'sources_1' fileset properties
set_property -name "top" -value "pulse_controller_v5_0" -objects $src_set

ensure_fileset -constrset constrs_1
set sim_set [ensure_fileset -simset sim_1]

# Set 'sim_1' fileset properties
set_property -name "top" -value "pulse_controller_v5_0" -objects $sim_set

ensure_synth_run synth_1 constrs_1
ensure_impl_run impl_1 synth_1 constrs_1

ipx::package_project -root_dir $pulse_ctrl_dir
set cur_core [ipx::current_core]
set_property vendor nigrp.org $cur_core
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

write_project_tcl -force -quiet "$base_dir/gen/pulse_controller-orig.tcl"
exec "$base_dir/scripts/clean_proj_tcl.sh" "$base_dir/gen/pulse_controller-orig.tcl"
