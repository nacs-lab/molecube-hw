#

sdk create_hw_project -name molecube_hw_platform -hwspec $hwspecpath
sdk create_app_project -name FSBL -hwproject molecube_hw_platform \
    -proc ps7_cortexa9_0 -bsp BSP -os standalone -app "Zynq FSBL" -lang c
sdk build_project all
