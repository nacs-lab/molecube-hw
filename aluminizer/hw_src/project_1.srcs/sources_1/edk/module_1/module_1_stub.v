//-----------------------------------------------------------------------------
// module_1_stub.v
//-----------------------------------------------------------------------------

module module_1_stub
  (
    processing_system7_0_MIO,
    processing_system7_0_PS_SRSTB,
    processing_system7_0_PS_CLK,
    processing_system7_0_PS_PORB,
    processing_system7_0_DDR_Clk,
    processing_system7_0_DDR_Clk_n,
    processing_system7_0_DDR_CKE,
    processing_system7_0_DDR_CS_n,
    processing_system7_0_DDR_RAS_n,
    processing_system7_0_DDR_CAS_n,
    processing_system7_0_DDR_WEB_pin,
    processing_system7_0_DDR_BankAddr,
    processing_system7_0_DDR_Addr,
    processing_system7_0_DDR_ODT,
    processing_system7_0_DDR_DRSTB,
    processing_system7_0_DDR_DQ,
    processing_system7_0_DDR_DM,
    processing_system7_0_DDR_DQS,
    processing_system7_0_DDR_DQS_n,
    processing_system7_0_DDR_VRN,
    processing_system7_0_DDR_VRP,
    pulse_io_pin,
    counter0_in_pin,
    dds_addr_pin,
    dds_data_pin,
    dds_control_pin,
    dds_addr2_pin,
    dds_data2_pin,
    dds_control2_pin,
    dds_cs_pin,
    dds_FUD_pin,
    dds_syncI_pin,
    dds_syncO_pin,
    clock_in_pin,
    clock_out1_pin,
    axi_spi_0_SCK_pin,
    axi_spi_0_MISO_pin,
    axi_spi_0_MOSI_pin,
    axi_spi_0_SS_pin,
    axi_spi_1_SCK_pin,
    axi_spi_1_MISO_pin,
    axi_spi_1_MOSI_pin,
    axi_spi_1_SS_pin
  );
  inout [53:0] processing_system7_0_MIO;
  input processing_system7_0_PS_SRSTB;
  input processing_system7_0_PS_CLK;
  input processing_system7_0_PS_PORB;
  inout processing_system7_0_DDR_Clk;
  inout processing_system7_0_DDR_Clk_n;
  inout processing_system7_0_DDR_CKE;
  inout processing_system7_0_DDR_CS_n;
  inout processing_system7_0_DDR_RAS_n;
  inout processing_system7_0_DDR_CAS_n;
  output processing_system7_0_DDR_WEB_pin;
  inout [2:0] processing_system7_0_DDR_BankAddr;
  inout [14:0] processing_system7_0_DDR_Addr;
  inout processing_system7_0_DDR_ODT;
  inout processing_system7_0_DDR_DRSTB;
  inout [31:0] processing_system7_0_DDR_DQ;
  inout [3:0] processing_system7_0_DDR_DM;
  inout [3:0] processing_system7_0_DDR_DQS;
  inout [3:0] processing_system7_0_DDR_DQS_n;
  inout processing_system7_0_DDR_VRN;
  inout processing_system7_0_DDR_VRP;
  output [31:0] pulse_io_pin;
  input [0:0] counter0_in_pin;
  output [6:0] dds_addr_pin;
  inout [15:0] dds_data_pin;
  output [2:0] dds_control_pin;
  output [6:0] dds_addr2_pin;
  inout [15:0] dds_data2_pin;
  output [2:0] dds_control2_pin;
  output [21:0] dds_cs_pin;
  output [1:0] dds_FUD_pin;
  input dds_syncI_pin;
  output dds_syncO_pin;
  input clock_in_pin;
  output clock_out1_pin;
  output axi_spi_0_SCK_pin;
  input axi_spi_0_MISO_pin;
  output axi_spi_0_MOSI_pin;
  output axi_spi_0_SS_pin;
  output axi_spi_1_SCK_pin;
  input axi_spi_1_MISO_pin;
  output axi_spi_1_MOSI_pin;
  output axi_spi_1_SS_pin;

  (* BOX_TYPE = "user_black_box" *)
  module_1
    module_1_i (
      .processing_system7_0_MIO ( processing_system7_0_MIO ),
      .processing_system7_0_PS_SRSTB ( processing_system7_0_PS_SRSTB ),
      .processing_system7_0_PS_CLK ( processing_system7_0_PS_CLK ),
      .processing_system7_0_PS_PORB ( processing_system7_0_PS_PORB ),
      .processing_system7_0_DDR_Clk ( processing_system7_0_DDR_Clk ),
      .processing_system7_0_DDR_Clk_n ( processing_system7_0_DDR_Clk_n ),
      .processing_system7_0_DDR_CKE ( processing_system7_0_DDR_CKE ),
      .processing_system7_0_DDR_CS_n ( processing_system7_0_DDR_CS_n ),
      .processing_system7_0_DDR_RAS_n ( processing_system7_0_DDR_RAS_n ),
      .processing_system7_0_DDR_CAS_n ( processing_system7_0_DDR_CAS_n ),
      .processing_system7_0_DDR_WEB_pin ( processing_system7_0_DDR_WEB_pin ),
      .processing_system7_0_DDR_BankAddr ( processing_system7_0_DDR_BankAddr ),
      .processing_system7_0_DDR_Addr ( processing_system7_0_DDR_Addr ),
      .processing_system7_0_DDR_ODT ( processing_system7_0_DDR_ODT ),
      .processing_system7_0_DDR_DRSTB ( processing_system7_0_DDR_DRSTB ),
      .processing_system7_0_DDR_DQ ( processing_system7_0_DDR_DQ ),
      .processing_system7_0_DDR_DM ( processing_system7_0_DDR_DM ),
      .processing_system7_0_DDR_DQS ( processing_system7_0_DDR_DQS ),
      .processing_system7_0_DDR_DQS_n ( processing_system7_0_DDR_DQS_n ),
      .processing_system7_0_DDR_VRN ( processing_system7_0_DDR_VRN ),
      .processing_system7_0_DDR_VRP ( processing_system7_0_DDR_VRP ),
      .pulse_io_pin ( pulse_io_pin ),
      .counter0_in_pin ( counter0_in_pin[0:0] ),
      .dds_addr_pin ( dds_addr_pin ),
      .dds_data_pin ( dds_data_pin ),
      .dds_control_pin ( dds_control_pin ),
      .dds_addr2_pin ( dds_addr2_pin ),
      .dds_data2_pin ( dds_data2_pin ),
      .dds_control2_pin ( dds_control2_pin ),
      .dds_cs_pin ( dds_cs_pin ),
      .dds_FUD_pin ( dds_FUD_pin ),
      .dds_syncI_pin ( dds_syncI_pin ),
      .dds_syncO_pin ( dds_syncO_pin ),
      .clock_in_pin ( clock_in_pin ),
      .clock_out1_pin ( clock_out1_pin ),
      .axi_spi_0_SCK_pin ( axi_spi_0_SCK_pin ),
      .axi_spi_0_MISO_pin ( axi_spi_0_MISO_pin ),
      .axi_spi_0_MOSI_pin ( axi_spi_0_MOSI_pin ),
      .axi_spi_0_SS_pin ( axi_spi_0_SS_pin ),
      .axi_spi_1_SCK_pin ( axi_spi_1_SCK_pin ),
      .axi_spi_1_MISO_pin ( axi_spi_1_MISO_pin ),
      .axi_spi_1_MOSI_pin ( axi_spi_1_MOSI_pin ),
      .axi_spi_1_SS_pin ( axi_spi_1_SS_pin )
    );

endmodule
