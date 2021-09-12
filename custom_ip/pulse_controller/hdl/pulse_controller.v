// Shim layer between verilog and system verilog

module pulse_controller #
  (
   // Users to add parameters here
   parameter U_PULSE_WIDTH = 32,
   parameter U_DDS_DATA_WIDTH = 16,
   parameter U_DDS_ADDR_WIDTH = 7,
   parameter U_DDS_CTRL_WIDTH = 3,
   parameter N_DDS = 22,
   parameter N_SPI = 1,
   // User parameters ends
   // Do not modify the parameters beyond this line


   // Parameters of Axi Slave Bus Interface S00_AXI
   parameter integer C_S00_AXI_DATA_WIDTH = 32,
   parameter integer C_S00_AXI_ADDR_WIDTH = 9
   )
   (
    // Users to add ports here
    output [(U_PULSE_WIDTH - 1):0] pulse_io,

    // DDS ports
    output [(U_DDS_ADDR_WIDTH - 1):0] dds_addr,
    output [(U_DDS_ADDR_WIDTH - 1):0] dds_addr2,

    // tri-state for dds_data to allow read & write
    inout [(U_DDS_DATA_WIDTH - 1):0] dds_data,
    inout [(U_DDS_DATA_WIDTH - 1):0] dds_data2,

    output [(U_DDS_CTRL_WIDTH - 1):0] dds_control,
    output [(U_DDS_CTRL_WIDTH - 1):0] dds_control2,

    output [1:0] dds_FUD,
    output [(N_DDS - 1):0] dds_cs,

    // begin: external signals for SPI
    output [(N_SPI - 1):0] spi_cs,
    output spi_mosi, spi_sclk,
    input spi_miso,
    // end: external signals for SPI

    output clockout,
    // User ports ends
    // Do not modify the ports beyond this line


    // Ports of Axi Slave Bus Interface S00_AXI
    input wire s00_axi_aclk,
    input wire s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH - 1:0] s00_axi_awaddr,
    input wire [2:0] s00_axi_awprot,
    input wire s00_axi_awvalid,
    output wire s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH - 1:0] s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH / 8) - 1:0] s00_axi_wstrb,
    input wire s00_axi_wvalid,
    output wire s00_axi_wready,
    output wire [1:0] s00_axi_bresp,
    output wire s00_axi_bvalid,
    input wire s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH - 1:0] s00_axi_araddr,
    input wire [2:0] s00_axi_arprot,
    input wire s00_axi_arvalid,
    output wire s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH - 1:0] s00_axi_rdata,
    output wire [1:0] s00_axi_rresp,
    output wire s00_axi_rvalid,
    input wire s00_axi_rready
    );

   // Instantiation of Axi Bus Interface S00_AXI
   pulse_controller_S00_AXI # (.N_SPI(N_SPI),
                               .N_DDS(N_DDS),
                               .U_DDS_DATA_WIDTH(U_DDS_DATA_WIDTH),
                               .U_DDS_ADDR_WIDTH(U_DDS_ADDR_WIDTH),
                               .U_DDS_CTRL_WIDTH(U_DDS_CTRL_WIDTH),
                               .U_PULSE_WIDTH(U_PULSE_WIDTH),
                               .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
                               .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
                               ) pulse_controller_S00_AXI_inst
     (
      .pulse_io(pulse_io),
      .dds_addr(dds_addr),
      .dds_addr2(dds_addr2),

      .dds_data(dds_data),
      .dds_data2(dds_data2),

      .dds_control(dds_control),
      .dds_control2(dds_control2),

      .dds_FUD(dds_FUD),
      .dds_cs(dds_cs),

      .spi_cs(spi_cs),
      .spi_mosi(spi_mosi),
      .spi_sclk(spi_sclk),
      .spi_miso(spi_miso),
      .clockout(clockout),

      .S_AXI_ACLK(s00_axi_aclk),
      .S_AXI_ARESETN(s00_axi_aresetn),
      .S_AXI_AWADDR(s00_axi_awaddr),
      .S_AXI_AWPROT(s00_axi_awprot),
      .S_AXI_AWVALID(s00_axi_awvalid),
      .S_AXI_AWREADY(s00_axi_awready),
      .S_AXI_WDATA(s00_axi_wdata),
      .S_AXI_WSTRB(s00_axi_wstrb),
      .S_AXI_WVALID(s00_axi_wvalid),
      .S_AXI_WREADY(s00_axi_wready),
      .S_AXI_BRESP(s00_axi_bresp),
      .S_AXI_BVALID(s00_axi_bvalid),
      .S_AXI_BREADY(s00_axi_bready),
      .S_AXI_ARADDR(s00_axi_araddr),
      .S_AXI_ARPROT(s00_axi_arprot),
      .S_AXI_ARVALID(s00_axi_arvalid),
      .S_AXI_ARREADY(s00_axi_arready),
      .S_AXI_RDATA(s00_axi_rdata),
      .S_AXI_RRESP(s00_axi_rresp),
      .S_AXI_RVALID(s00_axi_rvalid),
      .S_AXI_RREADY(s00_axi_rready)
      );

   // Add user logic here

   // User logic ends

endmodule
