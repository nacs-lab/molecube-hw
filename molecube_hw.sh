#!/bin/bash -e

base_dir=$(dirname "$(realpath "${BASH_SOURCE}")")
bin_dir=$(pwd)

mkdir -p custom_ip
cp -frs "${base_dir}/custom_ip/"* "$bin_dir/custom_ip"

"$base_dir"/run_vivado_tcl "$base_dir/scripts/pulse_controller.tcl"
"$base_dir"/run_vivado_tcl "$base_dir/scripts/molecube_hw.tcl"

"$base_dir"/scripts/xsdk.sh "${base_dir}" "$bin_dir"
"$base_dir"/scripts/device-tree.sh "${base_dir}" "$bin_dir"
