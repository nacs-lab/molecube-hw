`timescale 1 ns / 1 ps

module pulse_controller_v5_0_S00_AXI #
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

   // Width of S_AXI data bus
   parameter integer C_S_AXI_DATA_WIDTH = 32,
   // Width of S_AXI address bus
   parameter integer C_S_AXI_ADDR_WIDTH = 7
   )
   (
    // Users to add ports here
    output [0:(U_PULSE_WIDTH - 1)] pulse_io,

    // DDS ports
    output [0:(U_DDS_ADDR_WIDTH - 1)] dds_addr,
    output [0:(U_DDS_ADDR_WIDTH - 1)] dds_addr2,

    // tri-state for dds_data to allow read & write
    output [0:(U_DDS_DATA_WIDTH - 1)] dds_data_O,
    input [0:(U_DDS_DATA_WIDTH - 1)] dds_data_I,
    output [0:(U_DDS_DATA_WIDTH - 1)] dds_data2_O,
    input [0:(U_DDS_DATA_WIDTH - 1)] dds_data2_I,
    output dds_data_T, dds_data2_T,

    output [0:(U_DDS_CTRL_WIDTH - 1)] dds_control,
    output [0:(U_DDS_CTRL_WIDTH - 1)] dds_control2,

    output [1:0] dds_FUD,
    output [0:(N_DDS - 1)] dds_cs,

    // begin: external signals for SPI
    output [(N_SPI - 1):0] spi_cs,
    output spi_mosi, spi_clk,
    input spi_miso,
    // end: external signals for SPI

    output clock_out,

    input inst_fifo_empty_n,
    input [63:0] inst_fifo_rd_data,
    output inst_fifo_rd_en,
    input inst_fifo_full_n,
    output [63:0] inst_fifo_wr_data,
    output inst_fifo_wr_en,
    // User ports ends
    // Do not modify the ports beyond this line

    // Global Clock Signal
    input wire S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire S_AXI_ARESETN,
    // Write address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH - 1:0] S_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
    // privilege and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    input wire [2:0] S_AXI_AWPROT, // Unused
    // Write address valid. This signal indicates that the master signaling
    // valid write address and control information.
    input wire S_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
    // to accept an address and associated control signals.
    output reg S_AXI_AWREADY,
    // Write data (issued by master, acceped by Slave)
    input wire [C_S_AXI_DATA_WIDTH - 1:0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
    // valid data. There is one write strobe bit for each eight
    // bits of the write data bus.
    input wire [(C_S_AXI_DATA_WIDTH / 8) - 1:0] S_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
    // data and strobes are available.
    input wire S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
    // can accept the write data.
    output reg S_AXI_WREADY,
    // Write response. This signal indicates the status
    // of the write transaction.
    output wire [1:0] S_AXI_BRESP, // Always 0 (unused)
    // Write response valid. This signal indicates that the channel
    // is signaling a valid write response.
    output reg S_AXI_BVALID,
    // Response ready. This signal indicates that the master
    // can accept a write response.
    input wire S_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH - 1:0] S_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether the
    // transaction is a data access or an instruction access.
    input wire [2:0] S_AXI_ARPROT, // Unused
    // Read address valid. This signal indicates that the channel
    // is signaling valid read address and control information.
    input wire S_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
    // ready to accept an address and associated control signals.
    output reg S_AXI_ARREADY,
    // Read data (issued by slave)
    output reg [C_S_AXI_DATA_WIDTH - 1:0] S_AXI_RDATA,
    // Read response. This signal indicates the status of the
    // read transfer.
    output wire [1:0] S_AXI_RRESP, // Always 0 (unused)
    // Read valid. This signal indicates that the channel is
    // signaling the required read data.
    output reg S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
    // accept the read data and response information.
    input wire S_AXI_RREADY
    );

   // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
   // ADDR_LSB is used for addressing 32 / 64 bit registers/memories
   // ADDR_LSB = 2 for 32 bits (n downto 2)
   // ADDR_LSB = 3 for 64 bits (n downto 3)
   localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH / 32) + 1;
   localparam integer OPT_MEM_ADDR_BITS = 4;

   // Read signals
   // Inputs:
   //   ARADDR: Read address
   //   ARVALID: Read address valid
   //   RREADY: Read ready
   // Outputs:
   //   ARREADY: Read address ready
   //   RDATA: Read data
   //   RVALID: Read valid

   // Sequence:
   // Reset:
   //   Condition: `ARESETN == 0`
   //   Action:
   //     ARREADY <= 1
   //     RDATA <= 0
   //     RVALID <= 0
   //     Go to phase 0
   // Phase 0: Idle
   //   Wait for `ARVALID == 1`:
   //     Latch ARADDR
   //     ARREADY <= 0
   //     Trigger user logic
   //     Go to phase 1
   // User logic:
   //   When ready, write to `RDATA` and assert `RVALID`
   // Phase 1: Request
   //   Wait for user logic ready (`RVALID == 1`) && `RREADY == 1`
   //     ARREADY <= 1
   //     RVALID <= 0
   //     Go to phase 0
   //   Wait for user logic ready (`RVALID == 1`)
   //     Go to phase 2
   // Phase 2: Reply
   //   Wait for user logic ready (`RVALID == 1`) && `RREADY == 1`
   //     ARREADY <= 1
   //     RVALID <= 0
   //     Go to phase 0
   reg [1:0] s_axi_read_state;
   reg [C_S_AXI_ADDR_WIDTH - 1:0] s_axi_araddr_l;
   wire [C_S_AXI_ADDR_WIDTH - 1:0] s_axi_araddr =
                                   s_axi_read_state == 0 ? S_AXI_ARADDR : s_axi_araddr_l;
   // `s_axi_rdvalid` become 1 on the cycle `S_AXI_ARVALID == 1`
   // which is also the cycle `s_axi_araddr` become valid.
   // As soon as a reply is generated (the same cycle) it should reset to 0 on the next cycle.
   wire s_axi_rdvalid = (s_axi_read_state == 0 ? S_AXI_ARVALID :
                         s_axi_read_state == 1 ? ~S_AXI_RVALID : 1'b0);
   assign S_AXI_RRESP = 0;
   always @(posedge S_AXI_ACLK) begin
      if (~S_AXI_ARESETN) begin
         S_AXI_ARREADY <= 1'b1;
         S_AXI_RDATA <= 0;
         S_AXI_RVALID <= 1'b0;
         s_axi_read_state <= 2'b00;
      end else begin
         case (s_axi_read_state)
           2'b00: begin
              // Idle (wait for request)
              if (S_AXI_ARVALID) begin
                 s_axi_araddr_l <= S_AXI_ARADDR;
                 S_AXI_ARREADY <= 1'b0;
                 s_axi_read_state <= 2'b01; // Trigger user logic
              end
           end
           2'b01: begin
              // Requested (wait for reply and acknowledgement)
              if (S_AXI_RVALID & S_AXI_RREADY) begin
                 S_AXI_ARREADY <= 1'b1;
                 S_AXI_RVALID <= 1'b0;
                 s_axi_read_state <= 2'b00;
              end else if (S_AXI_RVALID) begin
                 s_axi_read_state <= 2'b10;
              end
           end
           2'b10: begin
              // Replied (wait for acknowledgement)
              if (S_AXI_RREADY) begin
                 S_AXI_ARREADY <= 1'b1;
                 S_AXI_RVALID <= 1'b0;
                 s_axi_read_state <= 2'b00;
              end
           end
         endcase
      end
   end

   // Write signals
   // Inputs:
   //   AWADDR: Write address
   //   AWVALID: Write address valid
   //   WSTRB: Write strobes
   //   WDATA: Write data
   //   WVALID: Write valid
   //   BREADY: Response ready
   // Outputs:
   //   AWREADY: Write address ready
   //   WREADY: Write ready
   //   BVALID: Write response valid

   // Sequence:
   // Reset:
   //   Condition: `ARESETN == 0`
   //   Action:
   //     AWREADY <= 1
   //     WREADY <= 1
   //     BVALID <= 0
   //     Go to phase 0
   // Phase 0: Idle
   //   Wait for `AWVALID == 1` || `WVALID == 1`:
   //     Latch AWADDR and/or (WSTRB && WDATA)
   //     AWREADY <= 0 and/or WREADY <= 0
   //     Trigger user logic
   //     Go to phase 1
   // User logic:
   //   When ready, assert `BVALID`
   // Phase 1: Request
   //   Wait for user logic ready (`BVALID`)
   //     Go to phase 2
   // Phase 2: Reply
   //   Wait for `BREADY == 1`
   //     AWREADY <= 1
   //     WREADY <= 1
   //     BVALID <= 0
   //     Go to phase 0
   reg [1:0] s_axi_write_state;
   reg s_axi_write_addr_latched;
   reg s_axi_write_data_latched;
   reg [C_S_AXI_ADDR_WIDTH - 1:0] s_axi_awaddr_l;
   reg [C_S_AXI_DATA_WIDTH - 1:0] s_axi_wdata_l;
   reg [(C_S_AXI_DATA_WIDTH / 8) - 1:0] s_axi_wstrb_l;

   wire [C_S_AXI_ADDR_WIDTH - 1:0] s_axi_awaddr = (s_axi_write_addr_latched ? s_axi_awaddr_l :
                                                   S_AXI_AWADDR);
   wire [C_S_AXI_DATA_WIDTH - 1:0] s_axi_wdata = (s_axi_write_data_latched ? s_axi_wdata_l :
                                                  S_AXI_WDATA);
   wire [(C_S_AXI_DATA_WIDTH / 8) - 1:0] s_axi_wstrb = (s_axi_write_data_latched ? s_axi_wstrb_l :
                                                        S_AXI_WSTRB);

   wire s_axi_wrvalid = (s_axi_write_state == 0 ?
                         (S_AXI_AWVALID | s_axi_write_addr_latched) &
                         (S_AXI_WVALID | s_axi_write_data_latched) :
                         s_axi_write_state == 1 ? ~S_AXI_BVALID : 1'b0);
   assign S_AXI_BRESP = 0;
   always @(posedge S_AXI_ACLK) begin
      if (~S_AXI_ARESETN) begin
         S_AXI_AWREADY <= 1;
         S_AXI_WREADY <= 1;
         S_AXI_BVALID <= 0;
         s_axi_write_state <= 2'b00;
         s_axi_write_addr_latched <= 1'b0;
         s_axi_write_data_latched <= 1'b0;
         s_axi_awaddr_l <= 0;
         s_axi_wdata_l <= 0;
         s_axi_wstrb_l <= 0;
      end else begin
         case (s_axi_write_state)
           2'b00: begin
              // Idle (wait for request)
              if (S_AXI_AWVALID & S_AXI_WVALID) begin
                 if (~s_axi_write_addr_latched) begin
                    s_axi_awaddr_l <= S_AXI_AWADDR;
                 end
                 if (~s_axi_write_data_latched) begin
                    s_axi_wdata_l <= S_AXI_WDATA;
                    s_axi_wstrb_l <= S_AXI_WSTRB;
                 end
                 s_axi_write_addr_latched <= 1'b1;
                 s_axi_write_data_latched <= 1'b1;
                 s_axi_write_state <= 2'b01; // Trigger user logic
              end else if (S_AXI_AWVALID & ~s_axi_write_addr_latched) begin
                 s_axi_awaddr_l <= S_AXI_AWADDR;
                 s_axi_write_addr_latched <= 1'b1;
                 if (s_axi_write_data_latched) begin
                    s_axi_write_state <= 2'b01; // Trigger user logic
                 end
              end else if (S_AXI_WVALID && ~s_axi_write_data_latched) begin
                 s_axi_wdata_l <= S_AXI_WDATA;
                 s_axi_wstrb_l <= S_AXI_WSTRB;
                 s_axi_write_data_latched <= 1'b1;
                 if (~s_axi_write_addr_latched) begin
                    s_axi_write_state <= 2'b01; // Trigger user logic
                 end
              end
           end
           2'b01: begin
              // Requested (wait for reply and acknowledgement)
              if (S_AXI_BVALID & S_AXI_BREADY) begin
                 S_AXI_AWREADY <= 1;
                 S_AXI_WREADY <= 1;
                 S_AXI_BVALID <= 0;
                 s_axi_write_state <= 2'b00;
                 s_axi_write_addr_latched <= 1'b0;
                 s_axi_write_data_latched <= 1'b0;
              end else if (S_AXI_BVALID) begin
                 s_axi_write_state <= 2'b10;
                 s_axi_write_addr_latched <= 1'b0;
                 s_axi_write_data_latched <= 1'b0;
              end
           end
           2'b10: begin
              // Replied (wait for acknowledgement)
              if (S_AXI_BREADY) begin
                 S_AXI_AWREADY <= 1;
                 S_AXI_WREADY <= 1;
                 S_AXI_BVALID <= 0;
                 s_axi_write_state <= 2'b00;
              end
           end
         endcase
      end
   end

   //----------------------------------------------------------------------------
   // User logic
   //----------------------------------------------------------------------------

   // rFIFO = results FIFO. Access by reading slave register 31
   // If using register 31, must check that there is a value in the FIFO to read.
   // Otherwise things will get messed up.
   // Check that slv_reg_status[(rFIFO_ADDR_BITS+3):4] (rFIFO_fill) > 0
   // Register 2 contains rFIFO occupancy. There is no overflow protection,
   // so don't stuff more than rFIFO_DEPTH results

   localparam rFIFO_DEPTH = 32;
   localparam rFIFO_ADDR_BITS = 5;
   reg [31:0] rFIFO [0:(rFIFO_DEPTH - 1)];
   reg [(rFIFO_ADDR_BITS - 1):0] rFIFO_write_addr;
   reg [(rFIFO_ADDR_BITS - 1):0] rFIFO_read_addr;
   reg [(rFIFO_ADDR_BITS - 1):0] rFIFO_fill;

   // rFIFO = result FIFO (records DDS, SPI, and loopback results)
   // push a word onto rFIFO on rising edges of rFIFO_WrReq
   wire rFIFO_WrReq;
   reg rFIFO_WrReqPrev;
   wire rFIFO_WrReqPosEdge = rFIFO_WrReq & ~rFIFO_WrReqPrev;
   wire rFIFO_RdReq;

   // Register map.
   //   write means CPU writes to this register
   //   read means CPU reads this register
   // 0: ttl high mask (read write)
   // 1: ttl low mask (read write)
   //
   // 2: status (read)
   //   slv_reg_status[0] <= underflow;
   //   slv_reg_status[2] <= pulses_finished;
   //   slv_reg_status[(rFIFO_ADDR_BITS + 3):4] <= rFIFO_fill;
   //
   // 3: control (read write)
   //   slv_reg_ctrl[7] => pulse_controller_hold. nothing happens when this is high
   //   slv_reg_ctrl[8] => init.  toggle at start of sequence for reset
   //
   // 31: -- output of result FIFO (read)
   reg [C_S_AXI_DATA_WIDTH - 1:0] ttl_hi_mask;
   reg [C_S_AXI_DATA_WIDTH - 1:0] ttl_lo_mask;
   reg [C_S_AXI_DATA_WIDTH - 1:0] slv_reg_status;
   reg [C_S_AXI_DATA_WIDTH - 1:0] slv_reg_ctrl;
   reg [C_S_AXI_DATA_WIDTH - 1:0] slv_reg_dummy;

   // active-high reset
   wire [0:(C_S_AXI_DATA_WIDTH-1)] result;
   wire underflow;
   wire pulses_finished;
   wire [7:0] clock_out_div;
   // Digital output words
   wire [(U_PULSE_WIDTH - 1):0] ttl_out;

   // assume slave register width == pulse width
   assign pulse_io = (ttl_out | ttl_hi_mask) & (~ttl_lo_mask);

   always @(posedge S_AXI_ACLK) begin
      if (S_AXI_ARESETN && s_axi_rdvalid) begin
         // Address decoding for reading registers
         case (s_axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB])
           5'h00: begin
              S_AXI_RDATA <= ttl_hi_mask;
              S_AXI_RVALID <= 1'b1;
           end
           5'h01: begin
              S_AXI_RDATA <= ttl_lo_mask;
              S_AXI_RVALID <= 1'b1;
           end
           5'h02: begin
              S_AXI_RDATA <= slv_reg_status;
              S_AXI_RVALID <= 1'b1;
           end
           5'h03: begin
              S_AXI_RDATA <= slv_reg_ctrl;
              S_AXI_RVALID <= 1'b1;
           end
           5'h04: begin
              S_AXI_RDATA <= ttl_out;
              S_AXI_RVALID <= 1'b1;
           end
           5'h05: begin
              S_AXI_RDATA[C_S_AXI_DATA_WIDTH - 1:8] <= 0;
              S_AXI_RDATA[7:0] <= clock_out_div;
              S_AXI_RVALID <= 1'b1;
           end
           5'h1E: begin
              S_AXI_RDATA <= slv_reg_dummy;
              S_AXI_RVALID <= 1'b1;
           end
           5'h1F: begin
              S_AXI_RDATA <= rFIFO[rFIFO_read_addr];
              S_AXI_RVALID <= 1'b1;
           end
           default: begin
              S_AXI_RDATA <= 0;
              S_AXI_RVALID <= 1'b1;
           end
         endcase
      end
   end

   integer byte_index;
   wire tc_inst_ready;
   always @(posedge S_AXI_ACLK) begin
      if (~S_AXI_ARESETN) begin
         ttl_hi_mask <= 0;
         ttl_lo_mask <= 0;
         slv_reg_status <= 0;
         slv_reg_ctrl <= 0;
         slv_reg_dummy <= 0;
      end else begin
         if (s_axi_wrvalid) begin
            case (s_axi_awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB])
              5'h00: begin
                 for (byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                      byte_index = byte_index + 1)
                   if (s_axi_wstrb[byte_index] == 1) begin
                      // Respective byte enables are asserted as per write strobes
                      // Slave register 0
                      ttl_hi_mask[(byte_index * 8)+:8] <= s_axi_wdata[(byte_index * 8)+:8];
                   end
                 S_AXI_BVALID <= 1'b1;
              end
              5'h01: begin
                 for (byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                      byte_index = byte_index + 1)
                   if (s_axi_wstrb[byte_index] == 1) begin
                      // Respective byte enables are asserted as per write strobes
                      // Slave register 1
                      ttl_lo_mask[(byte_index * 8)+:8] <= s_axi_wdata[(byte_index * 8)+:8];
                   end
                 S_AXI_BVALID <= 1'b1;
              end
              5'h03: begin
                 for (byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                      byte_index = byte_index + 1)
                   if (s_axi_wstrb[byte_index] == 1) begin
                      // Respective byte enables are asserted as per write strobes
                      // Slave register 1
                      slv_reg_ctrl[(byte_index * 8)+:8] <= s_axi_wdata[(byte_index * 8)+:8];
                   end
                 S_AXI_BVALID <= 1'b1;
              end
              5'h1E: begin
                 for (byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                      byte_index = byte_index + 1)
                   if (s_axi_wstrb[byte_index] == 1) begin
                      // Respective byte enables are asserted as per write strobes
                      // Slave register 1
                      slv_reg_dummy[(byte_index * 8)+:8] <= s_axi_wdata[(byte_index * 8)+:8];
                   end
                 S_AXI_BVALID <= 1'b1;
              end
              5'h1F: begin
                 S_AXI_BVALID <= tc_inst_ready;
              end
              default: begin
                 S_AXI_BVALID <= 1'b1;
              end
            endcase
         end
         slv_reg_status[0] <= underflow;
         slv_reg_status[2] <= pulses_finished;
         slv_reg_status[(rFIFO_ADDR_BITS + 3):4] <= rFIFO_fill;
      end
   end

   // rFIFO
   // Assumes that this only assert a single cycle
   assign rFIFO_RdReq = s_axi_rdvalid &&
                        s_axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB] == 5'h1F;
   always @(posedge S_AXI_ACLK) begin
      if (~S_AXI_ARESETN | slv_reg_ctrl[8]) begin
         rFIFO_fill <= 0;
         rFIFO_read_addr <= 0;
         rFIFO_write_addr <= 0;
         rFIFO_WrReqPrev <= 0;
      end else begin
         rFIFO_WrReqPrev <= rFIFO_WrReq;

         if (rFIFO_WrReqPosEdge) begin
            rFIFO[rFIFO_write_addr] <= result;
            rFIFO_write_addr <= rFIFO_write_addr + 1;
         end

         if (rFIFO_RdReq) // rFIFO_RdReq should de-assert after one cycle.
             rFIFO_read_addr <= rFIFO_read_addr + 1;

         // increment fill counter if writing & not reading
         if (rFIFO_WrReqPosEdge & !rFIFO_RdReq)
           rFIFO_fill <= rFIFO_fill + 1;

         // decrement fill counter if reading & not writing
         if (!rFIFO_WrReqPosEdge & rFIFO_RdReq)
           rFIFO_fill <= rFIFO_fill + ~(5'b0);
      end
   end

   wire tc_inst_valid = (s_axi_wrvalid &
                         s_axi_awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB] == 5'h1F);
   timing_controller
     #(.N_SPI(N_SPI),
       .N_DDS(N_DDS),
       .U_DDS_DATA_WIDTH(U_DDS_DATA_WIDTH),
       .U_DDS_ADDR_WIDTH(U_DDS_ADDR_WIDTH),
       .U_DDS_CTRL_WIDTH(U_DDS_CTRL_WIDTH),
       .BUS_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
       .RESULT_WIDTH(C_S_AXI_DATA_WIDTH))
   tc(.clock(S_AXI_ACLK),
      .resetn(S_AXI_ARESETN),
      .bus_data(s_axi_wdata),
      .bus_data_valid(tc_inst_valid),
      .bus_data_ready(tc_inst_ready),
      .rFIFO_data(result),
      .rFIFO_WrReq(rFIFO_WrReq),
      .dds_addr(dds_addr),
      .dds_data_I(dds_data_I),
      .dds_data_O(dds_data_O),
      .dds_data_T(dds_data_T),
      .dds_control(dds_control),
      .dds_addr2(dds_addr2),
      .dds_data2_I(dds_data2_I),
      .dds_data2_O(dds_data2_O),
      .dds_data2_T(dds_data2_T),
      .dds_control2(dds_control2),
      .dds_cs(dds_cs),
      .dds_FUD(dds_FUD),
      .ttl_out(ttl_out),
      .underflow(underflow),
      .spi_cs(spi_cs),
      .spi_mosi(spi_mosi),
      .spi_miso(spi_miso),
      .spi_clk(spi_clk),
      .pulses_finished(pulses_finished),
      .pulse_controller_hold(slv_reg_ctrl[7]),
      .init(slv_reg_ctrl[8]),
      .clock_out(clock_out),
      .clock_out_div(clock_out_div),
      .inst_fifo_empty_n(inst_fifo_empty_n),
      .inst_fifo_rd_data(inst_fifo_rd_data),
      .inst_fifo_rd_en(inst_fifo_rd_en),
      .inst_fifo_full_n(inst_fifo_full_n),
      .inst_fifo_wr_data(inst_fifo_wr_data),
      .inst_fifo_wr_en(inst_fifo_wr_en)
      );
endmodule
