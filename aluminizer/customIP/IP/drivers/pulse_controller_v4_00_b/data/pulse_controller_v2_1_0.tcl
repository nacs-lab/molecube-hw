##############################################################################
## Description:       Microprocess Driver Command (tcl)
## Date:              Sat Jul 14 14:34:13 2012 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "pulse_controller" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR"
}
