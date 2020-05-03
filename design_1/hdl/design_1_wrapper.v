//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
//Date        : Sun May  3 13:37:17 2020
//Host        : yyc.yyc-arch.org running 64-bit Arch Linux
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    clock_in_pin,
    clock_out1_pin,
    dds_FUD_pin,
    dds_addr2_pin,
    dds_addr_pin,
    dds_control2_pin,
    dds_control_pin,
    dds_cs_pin,
    dds_data2_pin,
    dds_data_pin,
    pulse_io_pin,
    spi0_clk,
    spi0_cs,
    spi0_miso,
    spi0_mosi);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  input clock_in_pin;
  output clock_out1_pin;
  output [1:0]dds_FUD_pin;
  output [0:6]dds_addr2_pin;
  output [0:6]dds_addr_pin;
  output [0:2]dds_control2_pin;
  output [0:2]dds_control_pin;
  output [0:21]dds_cs_pin;
  inout [15:0]dds_data2_pin;
  inout [15:0]dds_data_pin;
  output [0:31]pulse_io_pin;
  output spi0_clk;
  output [0:0]spi0_cs;
  input spi0_miso;
  output spi0_mosi;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire clock_in_pin;
  wire clock_out1_pin;
  wire [1:0]dds_FUD_pin;
  wire [0:6]dds_addr2_pin;
  wire [0:6]dds_addr_pin;
  wire [0:2]dds_control2_pin;
  wire [0:2]dds_control_pin;
  wire [0:21]dds_cs_pin;
  wire [15:0]dds_data2_pin;
  wire [15:0]dds_data_pin;
  wire [0:31]pulse_io_pin;
  wire spi0_clk;
  wire [0:0]spi0_cs;
  wire spi0_miso;
  wire spi0_mosi;

  design_1 design_1_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .clock_in_pin(clock_in_pin),
        .clock_out1_pin(clock_out1_pin),
        .dds_FUD_pin(dds_FUD_pin),
        .dds_addr2_pin(dds_addr2_pin),
        .dds_addr_pin(dds_addr_pin),
        .dds_control2_pin(dds_control2_pin),
        .dds_control_pin(dds_control_pin),
        .dds_cs_pin(dds_cs_pin),
        .dds_data2_pin(dds_data2_pin),
        .dds_data_pin(dds_data_pin),
        .pulse_io_pin(pulse_io_pin),
        .spi0_clk(spi0_clk),
        .spi0_cs(spi0_cs),
        .spi0_miso(spi0_miso),
        .spi0_mosi(spi0_mosi));
endmodule
