#!/bin/bash -e

base_dir=$1
bin_dir=$2

sdk_dir=$bin_dir/molecube_hw/molecube_hw.sdk
hwspecpath=$sdk_dir/design_1_wrapper.hdf

unset MAKEFLAGS

exec xsdk -batch -source /dev/stdin <<EOF
set_workspace ${sdk_dir}
set_user_repo_path ${sdk_dir}
set hwspecpath ${hwspecpath}
source ${base_dir}/scripts/xsdk.tcl
exit
EOF