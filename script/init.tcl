#

set repo ""

while {[llength $argv]} {
    set argv [lassign $argv[set argv {}] flag]

    switch -glob $flag {
        -repo {
            set argv [lassign $argv[set argv {}] repo]
        }
        default {
            return -code error [list {unknown option} $flag]
        }
    }
}

set proj [file join $repo project_molecube/project_molecube.xpr]
open_project $proj
set wrapper [file join $repo design_1/hdl/design_1_wrapper.v];
if {![file exists $wrapper]} {
    make_wrapper -files [get_files [file join $repo design_1/design_1.bd]] -top
}
