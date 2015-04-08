#

create_project -type hw -name molecube_hw_platform -hwspec $hwspecpath
create_project -type app -name FSBL -hwproject molecube_hw_platform \
    -proc ps7_cortexa9_0 -bsp BSP -os standalone -app "Zynq FSBL" -lang c
build all
