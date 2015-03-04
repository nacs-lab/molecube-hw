#!/bin/bash

src=$1
dst=$2
run_file=$3

if [[ -f "${dst}/${run_file}" ]]; then
    mv "${dst}/${run_file}" "${dst}/runs.xml.bak"
    cp -frs "${src}" "${dst}"
    rm "${dst}/${run_file}"
    mv "${dst}/runs.xml.bak" "${dst}/${run_file}"
else
    cp -frs "${src}" "${dst}"
    rm "${dst}/${run_file}"
    cp -v "${run_file}" "${dst}/${run_file}"
fi
