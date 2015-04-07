#

set design_name design_1

create_bd_design $design_name
current_bd_design $design_name

# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design {parentCell} {
    if {$parentCell eq ""} {
        set parentCell [get_bd_cells /]
    }

    # Get object for parentCell
    set parentObj [get_bd_cells $parentCell]
    if {$parentObj == ""} {
        error "Unable to find parent cell <$parentCell>!"
    }

    # Make sure parentObj is hier blk
    set parentType [get_property TYPE $parentObj]
    if {$parentType ne "hier"} {
        error "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
    }

    # Save current instance; Restore later
    set oldCurInst [current_bd_instance .]

    # Set parent object as current
    current_bd_instance $parentObj

    # Create interface ports
    set DDR \
        [create_bd_intf_port -mode Master \
             -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR]
    set FIXED_IO \
        [create_bd_intf_port -mode Master \
             -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 \
             FIXED_IO]

    # Create ports

    # Create instance: processing_system7_0, and set properties
    set processing_system7_0 \
        [create_bd_cell -type ip \
             -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0]
    set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
                            CONFIG.preset {ZC702*}] $processing_system7_0

    # Create interface connections
    connect_bd_intf_net -intf_net processing_system7_0_DDR \
        [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
    connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO \
        [get_bd_intf_ports FIXED_IO] \
        [get_bd_intf_pins processing_system7_0/FIXED_IO]

    # Create port connections
    connect_bd_net -net processing_system7_0_FCLK_CLK0 \
        [get_bd_pins processing_system7_0/FCLK_CLK0] \
        [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK]

    # Create address segments

    # Restore current instance
    current_bd_instance $oldCurInst

    save_bd_design
}

create_root_design ""
