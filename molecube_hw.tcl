#

source "$base_dir/lib/utils.tcl"

init_project [ensure_project molecube_hw "$bin_dir/molecube_hw"]

set src_set [ensure_fileset -srcset sources_1]
source "$base_dir/design_1.tcl"
set design_dir "$bin_dir/molecube_hw/molecube_hw.srcs/sources_1/bd/design_1"
set design_file "$design_dir/design_1.bd"

set file_obj [get_files -of_objects $src_set [list "*$design_file"]]
if {![get_property "is_locked" $file_obj]} {
    set_property "generate_synth_checkpoint" "0" $file_obj
}

ensure_fileset -constrset constrs_1
ensure_fileset -simset sim_1

ensure_synth_run synth_1 constrs_1
ensure_impl_run impl_1 synth_1 constrs_1

# hdl wrapper
make_wrapper -files [get_files "$design_file"] -top
add_files -norecurse "$design_dir/hdl/design_1_wrapper.v"
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

write_bd_tcl -quiet "$bin_dir/$design_name-orig.tcl"
write_project_tcl -quiet "$bin_dir/molecube_hw-orig.tcl"

# Synthesis
reset_run synth_1
launch_runs -runs synth_1
wait_on_run synth_1

reset_run impl_1
launch_runs -runs impl_1
wait_on_run impl_1

open_run impl_1
write_bitstream -force -bin_file "$bin_dir/system.bit"
