#!/bin/bash

src=$1
dst=$2
run_file=$3

cp -frs "${src}" "${dst}"
rm "${dst}/${run_file}"
cp -v "${run_file}" "${dst}/${run_file}"
