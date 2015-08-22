#!/bin/bash -e

base_dir=$1
bin_dir=$2

sdk_dir=$bin_dir/molecube_hw/molecube_hw.sdk
hwspecpath=$sdk_dir/design_1_wrapper.hdf

unset MAKEFLAGS

_fetch_git() {
    url=$1
    dest=$2
    branch=$3

    if [ -d "$dest/.git" ]; then
        pushd "$dest"
        git reset --hard HEAD
        git clean -fdx
        git fetch --force --update-head-ok \
            "$url" "$branch:$branch" --
        git checkout "$branch" --
        git reset --hard "$branch"
        git clean -fdx
        popd
    else
        git clone --single-branch --branch "$branch" \
            "$url" "$dest"
    fi
}

_fetch_git git://github.com/Xilinx/device-tree-xlnx \
           ${sdk_dir}/device-tree-xlnx master

hsi -mode batch -source /dev/stdin <<EOF
open_hw_design ${hwspecpath}
set_repo_path ${sdk_dir}/device-tree-xlnx
create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0
generate_target -dir ${sdk_dir}/dts
exit
EOF

dtc -I dts -O dtb -o $bin_dir/molecube.dtb ${sdk_dir}/dts/system.dts
