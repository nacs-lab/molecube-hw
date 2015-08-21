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

    # Create instance: axi_dma_0, and set properties
    set axi_dma_0 \
        [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0]
    set_property -dict [list CONFIG.c_include_sg {0}] $axi_dma_0

    # Create instance: axi_mem_intercon, and set properties
    set axi_mem_intercon \
        [create_bd_cell -type ip \
             -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon]
    set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI {3}] \
        $axi_mem_intercon

    # Create instance: axis_data_fifo_0, and set properties
    set axis_data_fifo_0 \
        [create_bd_cell -type ip \
             -vlnv xilinx.com:ip:axis_data_fifo:1.1 axis_data_fifo_0]

    # Create instance: processing_system7_0, and set properties
    set processing_system7_0 \
        [create_bd_cell -type ip \
             -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0]
    set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
                            CONFIG.PCW_IRQ_F2P_INTR {1} \
                            CONFIG.PCW_USE_FABRIC_INTERRUPT {0} \
                            CONFIG.PCW_USE_S_AXI_HP0 {1} \
                            CONFIG.preset {ZC702*}] $processing_system7_0

    # Create instance: processing_system7_0_axi_periph, and set properties
    set processing_system7_0_axi_periph \
        [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 \
             processing_system7_0_axi_periph]
    set_property -dict [list CONFIG.NUM_MI {2} ] \
        $processing_system7_0_axi_periph

    # Create instance: pulse_controller_0, and set properties
    set pulse_controller_0 \
        [create_bd_cell -type ip -vlnv xilinx:user:pulse_controller:5.0 \
             pulse_controller_0]

    # Create instance: rst_processing_system7_0_100M, and set properties
    set rst_processing_system7_0_100M \
        [create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 \
             rst_processing_system7_0_100M]

    # Create interface connections
    connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S \
        [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] \
        [get_bd_intf_pins axis_data_fifo_0/S_AXIS]
    connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S \
        [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] \
        [get_bd_intf_pins axi_mem_intercon/S00_AXI]
    connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM \
        [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] \
        [get_bd_intf_pins axi_mem_intercon/S02_AXI]
    connect_bd_intf_net -intf_net axi_mem_intercon_M00_AXI \
        [get_bd_intf_pins axi_mem_intercon/M00_AXI] \
        [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
    connect_bd_intf_net -intf_net axis_data_fifo_0_M_AXIS \
        [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] \
        [get_bd_intf_pins axis_data_fifo_0/M_AXIS]
    connect_bd_intf_net -intf_net processing_system7_0_DDR \
        [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
    connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO \
        [get_bd_intf_ports FIXED_IO] \
        [get_bd_intf_pins processing_system7_0/FIXED_IO]
    connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 \
        [get_bd_intf_pins processing_system7_0/M_AXI_GP0] \
        [get_bd_intf_pins processing_system7_0_axi_periph/S00_AXI]
    connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M00_AXI \
        [get_bd_intf_pins processing_system7_0_axi_periph/M00_AXI] \
        [get_bd_intf_pins pulse_controller_0/s00_axi]
    connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M01_AXI \
        [get_bd_intf_pins axi_dma_0/S_AXI_LITE] \
        [get_bd_intf_pins processing_system7_0_axi_periph/M01_AXI]

    # Create port connections
    connect_bd_net -net processing_system7_0_FCLK_CLK0 \
        [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] \
        [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] \
        [get_bd_pins axi_dma_0/s_axi_lite_aclk] \
        [get_bd_pins axi_mem_intercon/ACLK] \
        [get_bd_pins axi_mem_intercon/M00_ACLK] \
        [get_bd_pins axi_mem_intercon/S00_ACLK] \
        [get_bd_pins axi_mem_intercon/S01_ACLK] \
        [get_bd_pins axi_mem_intercon/S02_ACLK] \
        [get_bd_pins axis_data_fifo_0/s_axis_aclk] \
        [get_bd_pins processing_system7_0/FCLK_CLK0] \
        [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] \
        [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] \
        [get_bd_pins processing_system7_0_axi_periph/ACLK] \
        [get_bd_pins processing_system7_0_axi_periph/M00_ACLK] \
        [get_bd_pins processing_system7_0_axi_periph/M01_ACLK] \
        [get_bd_pins processing_system7_0_axi_periph/S00_ACLK] \
        [get_bd_pins pulse_controller_0/s00_axi_aclk] \
        [get_bd_pins rst_processing_system7_0_100M/slowest_sync_clk]
    connect_bd_net -net processing_system7_0_FCLK_RESET0_N \
        [get_bd_pins processing_system7_0/FCLK_RESET0_N] \
        [get_bd_pins rst_processing_system7_0_100M/ext_reset_in]
    connect_bd_net -net rst_processing_system7_0_100M_interconnect_aresetn \
        [get_bd_pins axi_mem_intercon/ARESETN] \
        [get_bd_pins processing_system7_0_axi_periph/ARESETN] \
        [get_bd_pins rst_processing_system7_0_100M/interconnect_aresetn]
    connect_bd_net -net rst_processing_system7_0_100M_peripheral_aresetn \
        [get_bd_pins axi_dma_0/axi_resetn] \
        [get_bd_pins axi_mem_intercon/M00_ARESETN] \
        [get_bd_pins axi_mem_intercon/S00_ARESETN] \
        [get_bd_pins axi_mem_intercon/S01_ARESETN] \
        [get_bd_pins axi_mem_intercon/S02_ARESETN] \
        [get_bd_pins axis_data_fifo_0/s_axis_aresetn] \
        [get_bd_pins processing_system7_0_axi_periph/M00_ARESETN] \
        [get_bd_pins processing_system7_0_axi_periph/M01_ARESETN] \
        [get_bd_pins processing_system7_0_axi_periph/S00_ARESETN] \
        [get_bd_pins pulse_controller_0/s00_axi_aresetn] \
        [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]

    # Create address segments
    create_bd_addr_seg -range 0x40000000 -offset 0x0 \
        [get_bd_addr_spaces axi_dma_0/Data_MM2S] \
        [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] \
        SEG_processing_system7_0_HP0_DDR_LOWOCM
    create_bd_addr_seg -range 0x40000000 -offset 0x0 \
        [get_bd_addr_spaces axi_dma_0/Data_S2MM] \
        [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] \
        SEG_processing_system7_0_HP0_DDR_LOWOCM
    create_bd_addr_seg -range 0x10000 -offset 0x40400000 \
        [get_bd_addr_spaces processing_system7_0/Data] \
        [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] \
        SEG_axi_dma_0_Reg
    create_bd_addr_seg -range 0x10000 -offset 0x73000000 \
        [get_bd_addr_spaces processing_system7_0/Data] \
        [get_bd_addr_segs pulse_controller_0/s00_axi/reg0] \
        SEG_pulse_controller_0_reg0

    # Restore current instance
    current_bd_instance $oldCurInst

    save_bd_design
}

create_root_design ""
