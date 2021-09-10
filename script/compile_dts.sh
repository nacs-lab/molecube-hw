#!/bin/bash

in=$1
out=$2

indir=$(dirname "$in")

gcc -I "$indir" -E -nostdinc -undef -D__DTS__ -x assembler-with-cpp -o - "$in" | \
    dtc -I dts -O dtb -o "$out" -
