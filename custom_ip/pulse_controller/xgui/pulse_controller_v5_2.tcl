# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_S00_AXI_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S00_AXI_HIGHADDR" -parent ${Page_0}

  ipgui::add_param $IPINST -name "U_PULSE_WIDTH"

}

proc update_PARAM_VALUE.N_DDS { PARAM_VALUE.N_DDS } {
	# Procedure called to update N_DDS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_DDS { PARAM_VALUE.N_DDS } {
	# Procedure called to validate N_DDS
	return true
}

proc update_PARAM_VALUE.N_SPI { PARAM_VALUE.N_SPI } {
	# Procedure called to update N_SPI when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_SPI { PARAM_VALUE.N_SPI } {
	# Procedure called to validate N_SPI
	return true
}

proc update_PARAM_VALUE.U_DDS_ADDR_WIDTH { PARAM_VALUE.U_DDS_ADDR_WIDTH } {
	# Procedure called to update U_DDS_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.U_DDS_ADDR_WIDTH { PARAM_VALUE.U_DDS_ADDR_WIDTH } {
	# Procedure called to validate U_DDS_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.U_DDS_CTRL_WIDTH { PARAM_VALUE.U_DDS_CTRL_WIDTH } {
	# Procedure called to update U_DDS_CTRL_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.U_DDS_CTRL_WIDTH { PARAM_VALUE.U_DDS_CTRL_WIDTH } {
	# Procedure called to validate U_DDS_CTRL_WIDTH
	return true
}

proc update_PARAM_VALUE.U_DDS_DATA_WIDTH { PARAM_VALUE.U_DDS_DATA_WIDTH } {
	# Procedure called to update U_DDS_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.U_DDS_DATA_WIDTH { PARAM_VALUE.U_DDS_DATA_WIDTH } {
	# Procedure called to validate U_DDS_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.U_PULSE_WIDTH { PARAM_VALUE.U_PULSE_WIDTH } {
	# Procedure called to update U_PULSE_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.U_PULSE_WIDTH { PARAM_VALUE.U_PULSE_WIDTH } {
	# Procedure called to validate U_PULSE_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_BASEADDR { PARAM_VALUE.C_S00_AXI_BASEADDR } {
	# Procedure called to update C_S00_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_BASEADDR { PARAM_VALUE.C_S00_AXI_BASEADDR } {
	# Procedure called to validate C_S00_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_HIGHADDR { PARAM_VALUE.C_S00_AXI_HIGHADDR } {
	# Procedure called to update C_S00_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_HIGHADDR { PARAM_VALUE.C_S00_AXI_HIGHADDR } {
	# Procedure called to validate C_S00_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.U_PULSE_WIDTH { MODELPARAM_VALUE.U_PULSE_WIDTH PARAM_VALUE.U_PULSE_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.U_PULSE_WIDTH}] ${MODELPARAM_VALUE.U_PULSE_WIDTH}
}

proc update_MODELPARAM_VALUE.U_DDS_DATA_WIDTH { MODELPARAM_VALUE.U_DDS_DATA_WIDTH PARAM_VALUE.U_DDS_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.U_DDS_DATA_WIDTH}] ${MODELPARAM_VALUE.U_DDS_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.U_DDS_ADDR_WIDTH { MODELPARAM_VALUE.U_DDS_ADDR_WIDTH PARAM_VALUE.U_DDS_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.U_DDS_ADDR_WIDTH}] ${MODELPARAM_VALUE.U_DDS_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.U_DDS_CTRL_WIDTH { MODELPARAM_VALUE.U_DDS_CTRL_WIDTH PARAM_VALUE.U_DDS_CTRL_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.U_DDS_CTRL_WIDTH}] ${MODELPARAM_VALUE.U_DDS_CTRL_WIDTH}
}

proc update_MODELPARAM_VALUE.N_DDS { MODELPARAM_VALUE.N_DDS PARAM_VALUE.N_DDS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_DDS}] ${MODELPARAM_VALUE.N_DDS}
}

proc update_MODELPARAM_VALUE.N_SPI { MODELPARAM_VALUE.N_SPI PARAM_VALUE.N_SPI } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_SPI}] ${MODELPARAM_VALUE.N_SPI}
}

