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
           ${bin_dir}/device-tree-xlnx master
_fetch_git git://github.com/Xilinx/linux-xlnx \
           ${bin_dir}/linux-xlnx master

hsi -mode batch -source /dev/stdin <<EOF
open_hw_design ${hwspecpath}
set_repo_path ${bin_dir}/device-tree-xlnx
create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0
generate_target -dir ${sdk_dir}/dts
exit
EOF

dts_name=${sdk_dir}/dts/system.dts
pl_dtsi_name=${sdk_dir}/dts/pl.dtsi
dtd_name=${bin_dir}/molecube.dtb

# The dts file generated is missing some important values possibly
# because of the version mismatch
# Also add dmatest in the device tree
julia -f "${base_dir}/scripts/fix_pl_dtsi.jl" \
      "${pl_dtsi_name}" "${pl_dtsi_name}.new"

base_dts_dir=${bin_dir}/linux-xlnx/arch/arm/boot/dts

mv -v "${pl_dtsi_name}.new" "${pl_dtsi_name}"

for fpath in "${sdk_dir}/dts/"*; do
    fname=$(basename "${fpath}")
    if ! [[ -f "${base_dts_dir}/${fname}" ]]; then
        cp -v "${fpath}" "${base_dts_dir}"
    fi
done

perl -p -i -e \
     '$_ .= qq(/include/ "pl.dtsi"\n) if /\/include\/ "zynq-7000.dtsi"/' \
     "${base_dts_dir}/zynq-zc702.dts"

dtc -I dts -O dtb -o "$dtd_name" "${base_dts_dir}/zynq-zc702.dts"
