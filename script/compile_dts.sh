#!/bin/bash

in=$1
out=$2

indir=$(dirname "$in")

# Patch the pulse controller version to remove the minor version
# We'll bump the major version when the compatibility with the kernel driver is broken.

gcc -I "$indir" -E -nostdinc -undef -D__DTS__ -x assembler-with-cpp -o - "$in" | \
    sed -e 's/\(xlnx,pulse-controller-[0-9]*\)\.[0-9]*/\1/' | \
    dtc -I dts -O dtb -o "$out" -
