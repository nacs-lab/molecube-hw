#!/bin/bash -e

base_dir=$1
bin_dir=$2

. "$base_dir/lib/utils.sh"

sdk_dir=$bin_dir/molecube_hw/molecube_hw.sdk
hwspecpath=$sdk_dir/design_1_wrapper.hdf

sdk_script=xsdk.xml
eval_file "${base_dir}/scripts/xsdk.xml.in" > "$sdk_script"

xsdk -wait -script "$sdk_script" -workspace "$sdk_dir"

MAKEFLAGS=''

xsdk -wait -eclipseargs -nosplash \
     -application org.eclipse.cdt.managedbuilder.core.headlessbuild \
     -build all -data "$sdk_dir" \
     -vmargs -Dorg.eclipse.cdt.core.console=org.eclipse.cdt.core.systemConsole
