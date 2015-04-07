#!/bin/bash

base_dir=$(dirname "$(realpath "${BASH_SOURCE}")")

exec "$base_dir"/run_vivado_tcl "$base_dir/scripts/molecube_hw.tcl"
