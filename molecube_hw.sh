#!/bin/bash -e

base_dir=$(dirname "$(realpath "${BASH_SOURCE}")")

mkdir -p custom_ip
cp -frs "${base_dir}/custom_ip/"* "$(pwd)/custom_ip"

"$base_dir"/run_vivado_tcl "$base_dir/scripts/pulse_controller.tcl"
"$base_dir"/run_vivado_tcl "$base_dir/scripts/molecube_hw.tcl"
