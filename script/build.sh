#!/bin/bash -e

dir="$(dirname "${BASH_SOURCE}")/.."
script_dir=$dir/script
device_tree_dir=$dir/boot/device-tree
u_boot_dir=$dir/boot/u-boot

outputdir=${1:-"$dir/build"}

# Initialize
vivado -mode batch -nolog -source "$script_dir/init.tcl" -tclargs -repo "$dir/"

# Build
vivado -mode batch -nolog -source "$script_dir/build.tcl" -tclargs \
       -proj "$dir/project_molecube/project_molecube.xpr" \
       -bit "$outputdir/system.bit.bit" \
       -hw "$outputdir/system.xsa"

# Device tree
xsct "$script_dir/gen_dts.tcl" -hw "$outputdir/system.xsa" \
     -repo_dir "$device_tree_dir" -out_dir "$outputdir/dts/"
"$dir/script/compile_dts.sh" "$outputdir/dts/system-top.dts" "$outputdir/dts/system.dtb"

# FSBL
xsct "$script_dir/gen_fsbl.tcl" -hw "$outputdir/system.xsa" -out_dir "$outputdir/fsbl/"
make -j1 -C "$outputdir/fsbl/"

# uboot
(
    export DEVICE_TREE=zynq-zc702
    conf_target=xilinx_zynq_virt_defconfig
    make -C "$u_boot_dir" ${conf_target} \
         ARCH=arm CROSS_COMPILE=armv7l-linux-gnueabihf- \
         KCFLAGS='-march=armv7-a+nofp'
    echo 'CONFIG_ENV_OVERWRITE=y' >> "$u_boot_dir"/.config
    make -C "$u_boot_dir" \
         ARCH=arm CROSS_COMPILE=armv7l-linux-gnueabihf- \
         KCFLAGS='-march=armv7-a+nofp'
)

# boot.bin
mkdir -p "$outputdir/boot/"
cp "$dir/boot/boot.bif" "$outputdir/boot/boot.bif"
cp "$outputdir/fsbl/executable.elf" "$outputdir/boot/fsbl.elf"
cp "$u_boot_dir/u-boot.elf" "$outputdir/boot/u-boot.elf"
armv7l-linux-gnueabihf-strip "$outputdir/boot/u-boot.elf"
(cd "$outputdir/boot" && bootgen -image boot.bif -w -o boot.bin)

# boot.scr
"$u_boot_dir/tools/mkimage" -A arm -T script -d \
                            "$dir/boot/boot.cmd" "$outputdir/boot/boot.scr"
