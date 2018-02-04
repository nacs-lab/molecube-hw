#

createhw -name molecube_hw_platform -hwspec $hwspecpath
createapp -name FSBL -hwproject molecube_hw_platform \
    -proc ps7_cortexa9_0 -bsp BSP -os standalone -app "Zynq FSBL" -lang c
projects -build
