# Create project
create_project -quiet molecube_hw "$bin_dir/molecube_hw"

# Set project properties
set proj [get_projects molecube_hw]
set_property "board_part" "xilinx.com:zc702:part0:1.1" $proj
set_property "default_lib" "xil_defaultlib" $proj
set_property "simulator_language" "Mixed" $proj

proc ensure_fileset {arg name} {
    if {[string equal [get_filesets -quiet $name] ""]} {
        create_fileset $arg $name
    }
}

ensure_fileset -srcset sources_1
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
