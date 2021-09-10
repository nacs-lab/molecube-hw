#

# path to the exported xsa file
set hwfile ""
# output path
set outdir ""

while {[llength $argv]} {
    set argv [lassign $argv[set argv {}] flag]

    switch -glob $flag {
        -hw {
            set argv [lassign $argv[set argv {}] hwfile]
        }
        -out_dir {
            set argv [lassign $argv[set argv {}] outdir]
        }
        default {
            return -code error [list {unknown option} $flag]
        }
    }
}

hsi open_hw_design $hwfile
hsi generate_app -os standalone -proc ps7_cortexa9_0 -app zynq_fsbl -sw fsbl -dir $outdir
