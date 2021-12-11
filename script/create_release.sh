#!/bin/bash -e

ver=$1
rm -rf build/molecube-hw-$ver
mkdir build/molecube-hw-$ver
cp build/system.bit.bin build/molecube-hw-$ver/
cp build/dts/system.dtb build/molecube-hw-$ver/devicetree.dtb
cp build/boot/boot.bin build/molecube-hw-$ver/

tar --owner=0 --group=0 -cf build/molecube-hw-$ver.tar.zst --zstd -C build/ molecube-hw-$ver

gh release create $ver --notes "Release $ver" build/molecube-hw-$ver.tar.zst
