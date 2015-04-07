#

proc try_open_project {name dir} {
    open_project -quiet "$dir/$name.xpr"
    return [get_project -quiet $name]
}

proc ensure_project {name dir} {
    set proj [try_open_project $name "$dir"]
    if {[string equal $proj ""]} {
        create_project -quiet $name "$dir"
    }
    return [get_project $name]
}

proc init_project {proj} {
    set_property "board_part" "xilinx.com:zc702:part0:1.1" $proj
    set_property "default_lib" "xil_defaultlib" $proj
    set_property "simulator_language" "Mixed" $proj
}
init_project [ensure_project molecube_hw "$bin_dir/molecube_hw"]

proc ensure_fileset {arg name} {
    if {[string equal [get_filesets -quiet $name] ""]} {
        create_fileset $arg $name
    }
    return [get_filesets $name]
}

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

set synth_run [get_runs -quiet synth_1]
if {[string equal $synth_run ""]} {
    create_run -name synth_1 -part xc7z020clg484-1 \
        -flow {Vivado Synthesis 2014} \
        -strategy "Vivado Synthesis Defaults" \
        -constrset constrs_1
    set synth_run [get_runs synth_1]
} else {
    set_property strategy "Vivado Synthesis Defaults" $synth_run
    set_property flow "Vivado Synthesis 2014" $synth_run
}

# set the current synth run
current_run -synthesis $synth_run

set impl_run [get_runs -quiet impl_1]
if {[string equal $impl_run ""]} {
    create_run -name impl_1 \
        -part xc7z020clg484-1 \
        -flow {Vivado Implementation 2014} \
        -strategy "Vivado Implementation Defaults" \
        -constrset constrs_1 \
        -parent_run synth_1
    set impl_run [get_runs impl_1]
} else {
    set_property strategy "Vivado Implementation Defaults" $impl_run
    set_property flow "Vivado Implementation 2014" $impl_run
}

# set the current impl run
current_run -implementation $impl_run

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
