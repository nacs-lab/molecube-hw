#

set jobn 1
set proj ""
set bitfile ""

while {[llength $argv]} {
    set argv [lassign $argv[set argv {}] flag]

    switch -glob $flag {
        -j {
            set argv [lassign $argv[set argv {}] jobn]
        }
        -proj {
            set argv [lassign $argv[set argv {}] proj]
        }
        -bit {
            set argv [lassign $argv[set argv {}] bitfile]
        }
        default {
            return -code error [list {unknown option} $flag]
        }
    }
}

puts [format "Compiling project %s to %s with %d processes" $proj $bitfile $jobn]

open_project $proj
update_compile_order -fileset sources_1
set synth [get_runs synth_1]
if {[get_property NEEDS_REFRESH $synth] ||
    [get_property PROGRESS $synth] ne "100%"
} then {
    reset_run synth_1
    launch_runs synth_1 -jobs $jobn
    wait_on_run synth_1
}
set impl [get_runs impl_1]
if {[get_property NEEDS_REFRESH $impl] ||
    [get_property PROGRESS $impl] ne "100%"
} then {
    reset_run impl_1
    launch_runs impl_1 -jobs $jobn
    wait_on_run impl_1
}
open_run impl_1
set path [file dirname $bitfile]
file mkdir $path
write_bitstream -force -bin_file $bitfile
