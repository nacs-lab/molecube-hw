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

proc ensure_fileset {arg name} {
    if {[string equal [get_filesets -quiet $name] ""]} {
        create_fileset $arg $name
    }
    return [get_filesets $name]
}

proc ensure_synth_run {name constr} {
    set synth_run [get_runs -quiet $name]
    if {[string equal $synth_run ""]} {
        create_run -name $name -part xc7z020clg484-1 \
            -flow {Vivado Synthesis 2014} \
            -strategy "Vivado Synthesis Defaults" \
            -constrset $constr
        set synth_run [get_runs $name]
    } else {
        set_property strategy "Vivado Synthesis Defaults" $synth_run
        set_property flow "Vivado Synthesis 2014" $synth_run
        set_property part "xc7z020clg484-1" $synth_run
    }

    # set the current synth run
    current_run -synthesis $synth_run
    return $synth_run
}

proc ensure_impl_run {name synth constr} {
    set impl_run [get_runs -quiet $name]
    if {[string equal $impl_run ""]} {
        create_run -name $name \
            -part xc7z020clg484-1 \
            -flow {Vivado Implementation 2014} \
            -strategy "Vivado Implementation Defaults" \
            -constrset $constr \
            -parent_run $synth
        set impl_run [get_runs $name]
    } else {
        set_property strategy "Vivado Implementation Defaults" $impl_run
        set_property flow "Vivado Implementation 2014" $impl_run
        set_property part "xc7z020clg484-1" $impl_run
    }

    # set the current impl run
    current_run -implementation $impl_run
    return $impl_run
}
