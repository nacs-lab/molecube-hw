# Main I/O

############################### FMC1 ######################################
# FMC1, column H
# CLK0_M2C_P / FMC1_H04
set_property PACKAGE_PIN L18 [get_ports {pulse_io_pin[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[0]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[0]}]
# CLK0_M2C_N / FMC1_H05
# set_property PACKAGE_PIN L19 [get_ports {pulse_io_pin[4]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[4]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[4]}]
# La02_P / FMC1_H07
# set_property PACKAGE_PIN L21 [get_ports axi_spi_5_MOSI_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports axi_spi_5_MOSI_pin]
# set_property DRIVE 8 [get_ports axi_spi_5_MOSI_pin]
# LA02_N / FMC1_H08
# set_property PACKAGE_PIN L22 [get_ports axi_spi_5_SCK_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports axi_spi_5_SCK_pin]
# set_property DRIVE 8 [get_ports axi_spi_5_SCK_pin]
# LA04_P / FMC1_H10
set_property PACKAGE_PIN M21 [get_ports {dds_data_pin[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_pin[14]}]
set_property DRIVE 4 [get_ports {dds_data_pin[14]}]
# LA04_N / FMC1_H11
set_property PACKAGE_PIN M22 [get_ports {dds_data_pin[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_pin[12]}]
set_property DRIVE 4 [get_ports {dds_data_pin[12]}]
# LA07_P / FMC1_H13
set_property PACKAGE_PIN J15 [get_ports {dds_data_pin[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_pin[10]}]
set_property DRIVE 4 [get_ports {dds_data_pin[10]}]
# LA07_N / FMC1_H14
set_property PACKAGE_PIN K15 [get_ports {dds_data_pin[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_pin[8]}]
set_property DRIVE 4 [get_ports {dds_data_pin[8]}]
# LA11_P / FMC1_H16
set_property PACKAGE_PIN R20 [get_ports {dds_data_pin[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_pin[6]}]
set_property DRIVE 4 [get_ports {dds_data_pin[6]}]
# LA11_N / FMC1_H17
set_property PACKAGE_PIN R21 [get_ports {dds_data_pin[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_pin[4]}]
set_property DRIVE 4 [get_ports {dds_data_pin[4]}]
# LA15_P / FMC1_H19
set_property PACKAGE_PIN P20 [get_ports {dds_data_pin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_pin[2]}]
set_property DRIVE 4 [get_ports {dds_data_pin[2]}]
# LA15_N / FMC1_H20
set_property PACKAGE_PIN P21 [get_ports {dds_data_pin[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_pin[0]}]
set_property DRIVE 4 [get_ports {dds_data_pin[0]}]
# LA19_P / FMC1_H22
set_property PACKAGE_PIN E19 [get_ports {dds_addr_pin[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_addr_pin[5]}]
set_property DRIVE 4 [get_ports {dds_addr_pin[5]}]
# LA19_N / FMC1_H23
set_property PACKAGE_PIN E20 [get_ports {dds_addr_pin[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_addr_pin[3]}]
set_property DRIVE 4 [get_ports {dds_addr_pin[3]}]
# LA21_P / FMC1_H25
set_property PACKAGE_PIN F21 [get_ports {dds_addr_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_addr_pin[1]}]
set_property DRIVE 4 [get_ports {dds_addr_pin[1]}]
# LA21_N / FMC1_H26 / FUD
set_property PACKAGE_PIN F22 [get_ports {dds_FUD_pin[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_FUD_pin[0]}]
set_property DRIVE 4 [get_ports {dds_FUD_pin[0]}]
# LA24_P / FMC1_H28 / WRB
set_property PACKAGE_PIN A21 [get_ports {dds_control_pin[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_control_pin[0]}]
set_property DRIVE 4 [get_ports {dds_control_pin[0]}]
# LA24_N / FMC1_H29
set_property PACKAGE_PIN A22 [get_ports {dds_cs_pin[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[0]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[0]}]
# LA28_P / FMC1_H31
set_property PACKAGE_PIN D22 [get_ports {dds_cs_pin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[2]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[2]}]
# LA28_N / FMC1_H32
set_property PACKAGE_PIN C22 [get_ports {dds_cs_pin[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[4]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[4]}]
# LA30_P / FMC1_H34
set_property PACKAGE_PIN E21 [get_ports {dds_cs_pin[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[6]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[6]}]
# LA30_N / FMC1_H35
set_property PACKAGE_PIN D21 [get_ports {dds_cs_pin[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[8]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[8]}]

# FMC1, column G
# CLK1_M2C_P / FMC1_G02
# set_property PACKAGE_PIN M19 [get_ports {pulse_io_pin[8]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[8]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[8]}]
# CLK1_M2C_N / FMC1_G03
# set_property PACKAGE_PIN M20 [get_ports {pulse_io_pin[12]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[12]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[12]}]
# LA00_P_CC / FMC1_G06
# set_property PACKAGE_PIN K19 [get_ports axi_spi_5_SS_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports axi_spi_5_SS_pin]
# set_property DRIVE 8 [get_ports axi_spi_5_SS_pin]
# LA00_N_CC / FMC1_G07
# set_property PACKAGE_PIN K20 [get_ports axi_spi_5_MISO_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports axi_spi_5_MISO_pin]
# LA03_P / FMC1_G09
set_property PACKAGE_PIN J20 [get_ports {dds_data_pin[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_pin[15]}]
set_property DRIVE 4 [get_ports {dds_data_pin[15]}]
# LA03_N / FMC1_G10
set_property PACKAGE_PIN K21 [get_ports {dds_data_pin[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_pin[13]}]
set_property DRIVE 4 [get_ports {dds_data_pin[13]}]
# LA08_P / FMC1_G12
set_property PACKAGE_PIN J21 [get_ports {dds_data_pin[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_pin[11]}]
set_property DRIVE 4 [get_ports {dds_data_pin[11]}]
# LA08_N / FMC1_G13
set_property PACKAGE_PIN J22 [get_ports {dds_data_pin[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_pin[9]}]
set_property DRIVE 4 [get_ports {dds_data_pin[9]}]
# LA12_P / FMC1_G15
set_property PACKAGE_PIN N22 [get_ports {dds_data_pin[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_pin[7]}]
set_property DRIVE 4 [get_ports {dds_data_pin[7]}]
# LA12_N / FMC1_G16
set_property PACKAGE_PIN P22 [get_ports {dds_data_pin[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_pin[5]}]
set_property DRIVE 4 [get_ports {dds_data_pin[5]}]
# LA16_P / FMC1_G18
set_property PACKAGE_PIN N15 [get_ports {dds_data_pin[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_pin[3]}]
set_property DRIVE 4 [get_ports {dds_data_pin[3]}]
# LA16_N / FMC1_G19
set_property PACKAGE_PIN P15 [get_ports {dds_data_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_pin[1]}]
set_property DRIVE 4 [get_ports {dds_data_pin[1]}]
# LA20_P / FMC1_G21
set_property PACKAGE_PIN G20 [get_ports {dds_addr_pin[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_addr_pin[6]}]
set_property DRIVE 4 [get_ports {dds_addr_pin[6]}]
# LA20_N / FMC1_G22
set_property PACKAGE_PIN G21 [get_ports {dds_addr_pin[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_addr_pin[4]}]
set_property DRIVE 4 [get_ports {dds_addr_pin[4]}]
# LA22_P / FMC1_G24
set_property PACKAGE_PIN G17 [get_ports {dds_addr_pin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_addr_pin[2]}]
set_property DRIVE 4 [get_ports {dds_addr_pin[2]}]
# LA22_N / FMC1_G25
set_property PACKAGE_PIN F17 [get_ports {dds_addr_pin[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_addr_pin[0]}]
set_property DRIVE 4 [get_ports {dds_addr_pin[0]}]
# LA25_P / FMC1_G27 / RESET
set_property PACKAGE_PIN C15 [get_ports {dds_control_pin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_control_pin[2]}]
set_property DRIVE 8 [get_ports {dds_control_pin[2]}]
# LA25_N / FMC1_G28 / RDB
set_property PACKAGE_PIN B15 [get_ports {dds_control_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_control_pin[1]}]
set_property DRIVE 8 [get_ports {dds_control_pin[1]}]
# LA29_P / FMC1_G30
set_property PACKAGE_PIN B16 [get_ports {dds_cs_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[1]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[1]}]
# LA29_N / FMC1_G31
set_property PACKAGE_PIN B17 [get_ports {dds_cs_pin[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[3]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[3]}]
# LA31_P / FMC1_G33
set_property PACKAGE_PIN A16 [get_ports {dds_cs_pin[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[5]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[5]}]
# LA31_N / FMC1_G34
set_property PACKAGE_PIN A17 [get_ports {dds_cs_pin[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[7]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[7]}]
# LA33_P / FMC1_G36
set_property PACKAGE_PIN A18 [get_ports {dds_cs_pin[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[9]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[9]}]
# LA33_N / FMC1_G37
set_property PACKAGE_PIN A19 [get_ports {dds_cs_pin[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[10]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[10]}]

# FMC1, column D
# LA01_CC_P / FMC1_D08
# set_property PACKAGE_PIN N19 [get_ports axi_spi_4_SCK_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports axi_spi_4_SCK_pin]
# set_property DRIVE 8 [get_ports axi_spi_4_SCK_pin]
# LA01_CC_P / FMC1_D09
# set_property PACKAGE_PIN N20 [get_ports axi_spi_4_MISO_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports axi_spi_4_MISO_pin]
# LA05_P / FMC1_D11
# set_property PACKAGE_PIN N17 [get_ports <pin_name>]
# set_property IOSTANDARD LVCMOS33 [get_ports <pin_name>]
# LA05_N / FMC1_D12
# set_property PACKAGE_PIN N18 [get_ports clock_in_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports clock_in_pin]
# LA09_P / FMC1_D14
# set_property PACKAGE_PIN M15 [get_ports sync_counter1_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports sync_counter1_pin]
# LA09_N / FMC1_D15
# NC
# set_property PACKAGE_PIN M16 [get_ports {pulse_io_pin[29]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[29]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[29]}]
set_property PACKAGE_PIN M16 [get_ports {pulse_io_pin[31]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[31]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[31]}]
# LA13_P / FMC1_D17
# NC
# set_property PACKAGE_PIN P16 [get_ports {pulse_io_pin[30]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[30]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[30]}]
set_property PACKAGE_PIN P16 [get_ports spi0_clk]
set_property IOSTANDARD LVCMOS33 [get_ports spi0_clk]
set_property DRIVE 8 [get_ports spi0_clk]
# LA13_N / FMC1_D18
# set_property PACKAGE_PIN R16 [get_ports spi0_clk]
# set_property IOSTANDARD LVCMOS33 [get_ports spi0_clk]
# set_property DRIVE 8 [get_ports spi0_clk]
set_property PACKAGE_PIN R16 [get_ports {pulse_io_pin[30]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[30]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[30]}]
# LA17_CC_P / FMC1_D20: new 28
# set_property PACKAGE_PIN B19 [get_ports spi0_mosi]
# set_property IOSTANDARD LVCMOS33 [get_ports spi0_mosi]
# set_property DRIVE 8 [get_ports spi0_mosi]
set_property PACKAGE_PIN B19 [get_ports {pulse_io_pin[28]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[28]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[28]}]
# LA17_CC_N / FMC1_D21
set_property PACKAGE_PIN B20 [get_ports {spi0_cs[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi0_cs[0]}]
set_property DRIVE 8 [get_ports {spi0_cs[0]}]
# LA23_P / FMC1_D23
# set_property PACKAGE_PIN G15 [get_ports axi_spi_1_MOSI_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports axi_spi_1_MOSI_pin]
# set_property DRIVE 8 [get_ports axi_spi_1_MOSI_pin]
set_property PACKAGE_PIN G15 [get_ports {pulse_io_pin[20]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[20]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[20]}]
# LA23_N / FMC1_D24
# set_property PACKAGE_PIN G16 [get_ports axi_spi_1_SS_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports axi_spi_1_SS_pin]
# set_property DRIVE 8 [get_ports axi_spi_1_SS_pin]
set_property PACKAGE_PIN G16 [get_ports {pulse_io_pin[24]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[24]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[24]}]
# LA26_P / FMC1_D26
# set_property PACKAGE_PIN F18 [get_ports axi_spi_2_MISO_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports axi_spi_2_MISO_pin]
set_property PACKAGE_PIN F18 [get_ports {pulse_io_pin[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[4]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[4]}]
# LA26_N / FMC1_D27
# set_property PACKAGE_PIN E18 [get_ports axi_spi_2_SS_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports axi_spi_2_SS_pin]
# set_property DRIVE 8 [get_ports axi_spi_2_SS_pin]
set_property PACKAGE_PIN E18 [get_ports {pulse_io_pin[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[12]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[12]}]

# FMC1, column C
# LA06_P / FMC1_C10
# Removed
# set_property PACKAGE_PIN J18 [get_ports <pin_name>]
# set_property IOSTANDARD LVDS_25 [get_ports <pin_name>]
# LA06_N / FMC1_C11
# set_property PACKAGE_PIN K18 [get_ports axi_spi_4_SS_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports axi_spi_4_SS_pin]
# set_property DRIVE 8 [get_ports axi_spi_4_SS_pin]
# LA10_P / FMC1_C14
# set_property PACKAGE_PIN L17 [get_ports axi_spi_3_MISO_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports axi_spi_3_MISO_pin]
# LA10_N / FMC1_C15
# NC input
# set_property PACKAGE_PIN M17 [get_ports {pulse_io_pin[28]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[28]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[28]}]
set_property PACKAGE_PIN M17 [get_ports spi0_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports spi0_mosi]
set_property DRIVE 8 [get_ports spi0_mosi]
# LA14_P / FMC1_C18
# NC
# set_property PACKAGE_PIN J16 [get_ports {pulse_io_pin[31]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[31]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[31]}]
set_property PACKAGE_PIN J16 [get_ports spi0_miso]
set_property IOSTANDARD LVCMOS33 [get_ports spi0_miso]
# LA14_N / FMC1_C19
# set_property PACKAGE_PIN J17 [get_ports spi0_miso]
# set_property IOSTANDARD LVCMOS33 [get_ports spi0_miso]
set_property PACKAGE_PIN J17 [get_ports {pulse_io_pin[29]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[29]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[29]}]
# LA18_CC_P / FMC1_C22
# set_property PACKAGE_PIN D20 [get_ports axi_spi_1_SCK_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports axi_spi_1_SCK_pin]
# set_property DRIVE 8 [get_ports axi_spi_1_SCK_pin]
# LA18_CC_N / FMC1_C23
# set_property PACKAGE_PIN C20 [get_ports axi_spi_1_MISO_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports axi_spi_1_MISO_pin]
set_property PACKAGE_PIN C20 [get_ports {pulse_io_pin[16]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[16]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[16]}]
# LA27_P / FMC1_C26
# set_property PACKAGE_PIN C17 [get_ports axi_spi_2_SCK_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports axi_spi_2_SCK_pin]
# set_property DRIVE 8 [get_ports axi_spi_2_SCK_pin]
# LA27_N / FMC1_C27
# set_property PACKAGE_PIN C18 [get_ports axi_spi_2_MOSI_pin]
# set_property IOSTANDARD LVCMOS33 [get_ports axi_spi_2_MOSI_pin]
# set_property DRIVE 8 [get_ports axi_spi_2_MOSI_pin]
set_property PACKAGE_PIN C18 [get_ports {pulse_io_pin[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[8]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[8]}]


############################### FMC2 ######################################
# FMC2, column H
# CLK0_M2C_P / FMC2_H04
set_property PACKAGE_PIN Y18 [get_ports clock_out1_pin]
set_property IOSTANDARD LVCMOS33 [get_ports clock_out1_pin]
set_property DRIVE 4 [get_ports clock_out1_pin]
# CLK0_M2C_N / FMC2_H05
# set_property PACKAGE_PIN AA18 [get_ports {pulse_io_pin[16]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[16]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[16]}]
# LA02_P / FMC2_H07
set_property PACKAGE_PIN V14 [get_ports {pulse_io_pin[26]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[26]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[26]}]
# LA02_N / FMC2_H08
# input:
# set_property PACKAGE_PIN V15 [get_ports {pulse_io_pin[24]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[24]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[24]}]
# LA04_P / FMC2_H10
set_property PACKAGE_PIN V13 [get_ports {dds_data2_pin[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data2_pin[14]}]
set_property DRIVE 4 [get_ports {dds_data2_pin[14]}]
# LA04_N / FMC2_H11
set_property PACKAGE_PIN W13 [get_ports {dds_data2_pin[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data2_pin[12]}]
set_property DRIVE 4 [get_ports {dds_data2_pin[12]}]
# LA07_P / FMC2_H13
set_property PACKAGE_PIN T21 [get_ports {dds_data2_pin[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data2_pin[10]}]
set_property DRIVE 4 [get_ports {dds_data2_pin[10]}]
# LA07_N / FMC2_H14
set_property PACKAGE_PIN U21 [get_ports {dds_data2_pin[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data2_pin[8]}]
set_property DRIVE 4 [get_ports {dds_data2_pin[8]}]
# LA11_P / FMC2_H16
set_property PACKAGE_PIN Y14 [get_ports {dds_data2_pin[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data2_pin[6]}]
set_property DRIVE 4 [get_ports {dds_data2_pin[6]}]
# LA11_N / FMC2_H17
set_property PACKAGE_PIN AA14 [get_ports {dds_data2_pin[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data2_pin[4]}]
set_property DRIVE 4 [get_ports {dds_data2_pin[4]}]
# LA15_P / FMC2_H19
set_property PACKAGE_PIN Y13 [get_ports {dds_data2_pin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data2_pin[2]}]
set_property DRIVE 4 [get_ports {dds_data2_pin[2]}]
# LA15_N / FMC2_H20
set_property PACKAGE_PIN AA13 [get_ports {dds_data2_pin[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data2_pin[0]}]
set_property DRIVE 4 [get_ports {dds_data2_pin[0]}]
# LA19_P / FMC2_H22
set_property PACKAGE_PIN R6 [get_ports {dds_addr2_pin[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_addr2_pin[5]}]
set_property DRIVE 4 [get_ports {dds_addr2_pin[5]}]
# LA19_N / FMC2_H23
set_property PACKAGE_PIN T6 [get_ports {dds_addr2_pin[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_addr2_pin[3]}]
set_property DRIVE 4 [get_ports {dds_addr2_pin[3]}]
# LA21_P / FMC2_H25
set_property PACKAGE_PIN V5 [get_ports {dds_addr2_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_addr2_pin[1]}]
set_property DRIVE 4 [get_ports {dds_addr2_pin[1]}]
# LA21_N / FMC2_H26 / FUD
set_property PACKAGE_PIN V4 [get_ports {dds_FUD_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_FUD_pin[1]}]
set_property DRIVE 4 [get_ports {dds_FUD_pin[1]}]
# LA24_P / FMC2_H28 / WRB
set_property PACKAGE_PIN U6 [get_ports {dds_control2_pin[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_control2_pin[0]}]
set_property DRIVE 4 [get_ports {dds_control2_pin[0]}]
# LA24_N / FMC2_H29
set_property PACKAGE_PIN U5 [get_ports {dds_cs_pin[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[11]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[11]}]
# LA28_P / FMC2_H31
set_property PACKAGE_PIN AB5 [get_ports {dds_cs_pin[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[13]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[13]}]
# LA28_N / FMC2_H32
set_property PACKAGE_PIN AB4 [get_ports {dds_cs_pin[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[15]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[15]}]
# LA30_P / FMC2_H34
set_property PACKAGE_PIN AB7 [get_ports {dds_cs_pin[17]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[17]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[17]}]
# LA30_N / FMC2_H35
set_property PACKAGE_PIN AB6 [get_ports {dds_cs_pin[19]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[19]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[19]}]

# FMC2, column G
# CLK1_M2C_P / FMC2_G02
# set_property PACKAGE_PIN Y6 [get_ports {pulse_io_pin[20]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[20]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[20]}]
# CLK1_M2C_N / FMC2_G03
# set_property PACKAGE_PIN Y5 [get_ports {pulse_io_pin[24]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[24]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[24]}]
# LA00_P_CC / FMC2_G06
set_property PACKAGE_PIN Y19 [get_ports {pulse_io_pin[27]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[27]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[27]}]
# LA00_N_CC / FMC2_G07
set_property PACKAGE_PIN AA19 [get_ports {pulse_io_pin[25]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[25]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[25]}]
# LA03_P / FMC2_G09
set_property PACKAGE_PIN AA16 [get_ports {dds_data2_pin[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data2_pin[15]}]
set_property DRIVE 4 [get_ports {dds_data2_pin[15]}]
# LA03_N / FMC2_G10
set_property PACKAGE_PIN AB16 [get_ports {dds_data2_pin[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data2_pin[13]}]
set_property DRIVE 4 [get_ports {dds_data2_pin[13]}]
# LA08_P / FMC2_G12
set_property PACKAGE_PIN AA17 [get_ports {dds_data2_pin[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data2_pin[11]}]
set_property DRIVE 4 [get_ports {dds_data2_pin[11]}]
# LA08_N / FMC2_G13
set_property PACKAGE_PIN AB17 [get_ports {dds_data2_pin[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data2_pin[9]}]
set_property DRIVE 4 [get_ports {dds_data2_pin[9]}]
# LA12_P / FMC2_G15
set_property PACKAGE_PIN W15 [get_ports {dds_data2_pin[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data2_pin[7]}]
set_property DRIVE 4 [get_ports {dds_data2_pin[7]}]
# LA12_N / FMC2_G16
set_property PACKAGE_PIN Y15 [get_ports {dds_data2_pin[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data2_pin[5]}]
set_property DRIVE 4 [get_ports {dds_data2_pin[5]}]
# LA16_P / FMC2_G18
set_property PACKAGE_PIN AB14 [get_ports {dds_data2_pin[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data2_pin[3]}]
set_property DRIVE 4 [get_ports {dds_data2_pin[3]}]
# LA16_N / FMC2_G19
set_property PACKAGE_PIN AB15 [get_ports {dds_data2_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data2_pin[1]}]
set_property DRIVE 4 [get_ports {dds_data2_pin[1]}]
# LA20_P / FMC2_G21
set_property PACKAGE_PIN T4 [get_ports {dds_addr2_pin[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_addr2_pin[6]}]
set_property DRIVE 4 [get_ports {dds_addr2_pin[6]}]
# LA20_N / FMC2_G22
set_property PACKAGE_PIN U4 [get_ports {dds_addr2_pin[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_addr2_pin[4]}]
set_property DRIVE 4 [get_ports {dds_addr2_pin[4]}]
# LA22_P / FMC2_G24
set_property PACKAGE_PIN U10 [get_ports {dds_addr2_pin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_addr2_pin[2]}]
set_property DRIVE 4 [get_ports {dds_addr2_pin[2]}]
# LA22_N / FMC2_G25
set_property PACKAGE_PIN U9 [get_ports {dds_addr2_pin[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_addr2_pin[0]}]
set_property DRIVE 4 [get_ports {dds_addr2_pin[0]}]
# LA25_P / FMC2_G27 / RESET
set_property PACKAGE_PIN AA12 [get_ports {dds_control2_pin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_control2_pin[2]}]
set_property DRIVE 8 [get_ports {dds_control2_pin[2]}]
# LA25_N / FMC2_G28 / RDB
set_property PACKAGE_PIN AB12 [get_ports {dds_control2_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_control2_pin[1]}]
set_property DRIVE 8 [get_ports {dds_control2_pin[1]}]
# LA29_P / FMC2_G30
set_property PACKAGE_PIN AA11 [get_ports {dds_cs_pin[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[12]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[12]}]
# LA29_N / FMC2_G31
set_property PACKAGE_PIN AB11 [get_ports {dds_cs_pin[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[14]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[14]}]
# LA31_P / FMC2_G33
set_property PACKAGE_PIN AB10 [get_ports {dds_cs_pin[16]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[16]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[16]}]
# LA31_N / FMC2_G34
set_property PACKAGE_PIN AB9 [get_ports {dds_cs_pin[18]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[18]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[18]}]
# LA33_P / FMC2_G36
set_property PACKAGE_PIN Y11 [get_ports {dds_cs_pin[20]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[20]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[20]}]
# LA33_P / FMC2_G37
set_property PACKAGE_PIN Y10 [get_ports {dds_cs_pin[21]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_cs_pin[21]}]
set_property DRIVE 4 [get_ports {dds_cs_pin[21]}]

# FMC2, column D
# LA01_CC_P / FMC2_D08
# input:
# set_property PACKAGE_PIN W16 [get_ports {pulse_io_pin[20]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[20]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[20]}]
# LA01_CC_P / FMC2_D09
set_property PACKAGE_PIN Y16 [get_ports {pulse_io_pin[21]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[21]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[21]}]
# LA05_P / FMC2_D11
set_property PACKAGE_PIN AB19 [get_ports {pulse_io_pin[19]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[19]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[19]}]
# LA05_N / FMC2_D12
set_property PACKAGE_PIN AB20 [get_ports {pulse_io_pin[18]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[18]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[18]}]
# LA09_P / FMC2_D14
# input:
# set_property PACKAGE_PIN U15 [get_ports {pulse_io_pin[16]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[16]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[16]}]
# LA09_N / FMC2_D15
set_property PACKAGE_PIN U16 [get_ports {pulse_io_pin[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[13]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[13]}]
# LA13_P / FMC2_D17
set_property PACKAGE_PIN V22 [get_ports {pulse_io_pin[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[14]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[14]}]
# LA13_N / FMC2_D18
set_property PACKAGE_PIN W22 [get_ports {pulse_io_pin[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[11]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[11]}]
# LA17_CC_P / FMC2_D20
set_property PACKAGE_PIN AA7 [get_ports {pulse_io_pin[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[9]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[9]}]
# LA17_CC_N / FMC2_D21
# input:
# set_property PACKAGE_PIN AA6 [get_ports {pulse_io_pin[08]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[08]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[08]}]
# LA23_P / FMC2_D23
set_property PACKAGE_PIN V12 [get_ports {pulse_io_pin[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[6]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[6]}]
# LA23_N / FMC2_D24
set_property PACKAGE_PIN W12 [get_ports {pulse_io_pin[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[7]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[7]}]
# LA26_P / FMC2_D26
set_property PACKAGE_PIN U12 [get_ports {pulse_io_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[1]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[1]}]
# LA26_N / FMC2_D27
set_property PACKAGE_PIN U11 [get_ports {pulse_io_pin[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[3]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[3]}]

# FMC2, column C
# LA06_P / FMC2_C10
set_property PACKAGE_PIN U17 [get_ports {pulse_io_pin[22]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[22]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[22]}]
# LA06_N / FMC2_C11
set_property PACKAGE_PIN V17 [get_ports {pulse_io_pin[23]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[23]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[23]}]
# LA10_P / FMC2_C14
set_property PACKAGE_PIN Y20 [get_ports {pulse_io_pin[17]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[17]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[17]}]
# LA10_N / FMC2_C15
# input:
# set_property PACKAGE_PIN Y21 [get_ports {pulse_io_pin[12]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[12]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[12]}]
# LA14_P / FMC2_C18
set_property PACKAGE_PIN T22 [get_ports {pulse_io_pin[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[15]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[15]}]
# LA14_N / FMC2_C19
set_property PACKAGE_PIN U22 [get_ports {pulse_io_pin[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[10]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[10]}]
# LA18_CC_P / FMC2_C22
# input:
# set_property PACKAGE_PIN AA9 [get_ports {pulse_io_pin[04]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[04]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[04]}]
# LA18_CC_N / FMC2_C23
set_property PACKAGE_PIN AA8 [get_ports {pulse_io_pin[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[5]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[5]}]
# LA27_P / FMC2_C26
# input:
# set_property PACKAGE_PIN AB2 [get_ports {pulse_io_pin[00]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[00]}]
# set_property DRIVE 4 [get_ports {pulse_io_pin[00]}]
# LA27_N / FMC2_C27
set_property PACKAGE_PIN AB1 [get_ports {pulse_io_pin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pulse_io_pin[2]}]
set_property DRIVE 4 [get_ports {pulse_io_pin[2]}]
