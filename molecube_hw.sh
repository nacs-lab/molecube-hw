#!/bin/bash

base_dir=$(dirname "$(realpath "${BASH_SOURCE}")")
bin_dir=$(pwd)

vivado -mode batch -source /dev/stdin <<EOF
set base_dir "$base_dir"
set bin_dir "$bin_dir"
source "$base_dir/molecube_hw.tcl"
EOF
