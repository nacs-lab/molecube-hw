#

# path to the exported xsa file
set hwfile ""
# path to the device-tree-xlnx repo
set repodir ""
# output path
set outdir ""

while {[llength $argv]} {
    set argv [lassign $argv[set argv {}] flag]

    switch -glob $flag {
        -hw {
            set argv [lassign $argv[set argv {}] hwfile]
        }
        -repo_dir {
            set argv [lassign $argv[set argv {}] repodir]
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
hsi set_repo_path $repodir
hsi create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0
hsi generate_target -dir $outdir
