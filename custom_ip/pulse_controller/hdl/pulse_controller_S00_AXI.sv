// AXI4-lite interface:
//   Handle AXI4-lite protocol and translate it to native signals for the timing controller.
//   Keeps track of a few state registers that are directly set by the AXI4-lite protocol.
//   AXI4-lite protocol detail should stay in this file/module.
//   The placement for other logic is not as strict.

// Forward the input to output if the output isn't full.
// Otherwise, discard the input and generate the corresponding of zero outputs
// when the output isn't full anymore.
module overflow_fifo #
  (parameter DATA_WIDTH = 32,
   parameter COUNTER_WIDTH = 32)
   (input clock, input resetn,
    input full,
    output [(DATA_WIDTH - 1):0] out_data,
    output out_en,
    input in_en,
    input [(DATA_WIDTH - 1):0] in_data,
    output reg [(COUNTER_WIDTH - 1):0] overflow_count
    );

   wire has_overflow = overflow_count != 0;

   assign out_en = resetn & (in_en | has_overflow);
   assign out_data = has_overflow ? 0 : in_data;
   always @(posedge clock) begin
      if (~resetn) begin
         overflow_count <= 0;
      end else if (~full) begin
         if (~in_en & has_overflow) begin
            // Condition for decreasing the overflow is when we can write
            // but we are not taking input.
            // Of course we also only decrease overflow when it's non-zero.
            overflow_count <= overflow_count - 1;
         end
      end else if (in_en) begin
         // Output is full but we are still writing.
         overflow_count <= overflow_count + 1;
      end
   end
endmodule

module pulse_controller_S00_AXI #
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
   parameter integer C_S_AXI_ADDR_WIDTH = 9
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

    input inst_fifo_empty,
    input inst_fifo_almost_empty, // unused
    input [63:0] inst_fifo_rd_data,
    output inst_fifo_rd_en,
    input inst_fifo_full,
    input inst_fifo_almost_full, // unused
    output [31:0] inst_fifo_wr_data,
    output inst_fifo_wr_en,

    input result_fifo_empty,
    input result_fifo_almost_empty, // unused
    input [31:0] result_fifo_rd_data,
    output result_fifo_rd_en,
    input result_fifo_full,
    input result_fifo_almost_full, // unused
    output [31:0] result_fifo_wr_data,
    output result_fifo_wr_en,
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
   localparam integer OPT_MEM_ADDR_BITS = 6;

   //----------------------------------------------------------------------------
   // User logic
   //----------------------------------------------------------------------------

   // Register map.
   //   write means CPU writes to this register
   //   read means CPU reads this register
   // 0: ttl high mask (read write)
   // 1: ttl low mask (read write)
   //
   // 2: status (read)
   //   slv_reg_status[0] <= underflow;
   //   slv_reg_status[2] <= pulses_finished;
   //   slv_reg_status[(RES_STATUS_ADDR_BITS + 3):4] <= result_status_count;
   //
   // 3: control (read write)
   //   slv_reg_ctrl[7] => pulse_controller_hold. nothing happens when this is high
   //   slv_reg_ctrl[8] => init.  toggle at start of sequence for reset
   //
   // 31: -- output of result FIFO (read)
   reg [C_S_AXI_DATA_WIDTH - 1:0] ttl_hi_mask;
   reg [C_S_AXI_DATA_WIDTH - 1:0] ttl_lo_mask;
   // Buffer the output for the status register (use a register instead of a wire)
   // since we don't care about the delay on this
   reg [C_S_AXI_DATA_WIDTH - 1:0] slv_reg_status;
   reg [C_S_AXI_DATA_WIDTH - 1:0] slv_reg_ctrl;
   wire pulse_controller_hold = slv_reg_ctrl[7];
   wire pulse_controller_init = slv_reg_ctrl[8];
   reg [C_S_AXI_DATA_WIDTH - 1:0] slv_reg_loopback;

   // Debug registers
   reg [(C_S_AXI_DATA_WIDTH - 1):0] dbg_inst_word_count;
   wire [(C_S_AXI_DATA_WIDTH - 1):0] dbg_inst_count;
   wire [(C_S_AXI_DATA_WIDTH - 1):0] dbg_ttl_count;
   wire [(C_S_AXI_DATA_WIDTH - 1):0] dbg_dds_count;
   wire [(C_S_AXI_DATA_WIDTH - 1):0] dbg_wait_count;
   wire [(C_S_AXI_DATA_WIDTH - 1):0] dbg_clear_count;
   wire [(C_S_AXI_DATA_WIDTH - 1):0] dbg_loopback_count;
   wire [(C_S_AXI_DATA_WIDTH - 1):0] dbg_clock_count;
   wire [(C_S_AXI_DATA_WIDTH - 1):0] dbg_spi_count;
   wire [(C_S_AXI_DATA_WIDTH - 1):0] dbg_underflow_cycle;
   wire [(C_S_AXI_DATA_WIDTH - 1):0] dbg_inst_cycle;
   wire [(C_S_AXI_DATA_WIDTH - 1):0] dbg_ttl_cycle;
   wire [(C_S_AXI_DATA_WIDTH - 1):0] dbg_wait_cycle;
   wire [(C_S_AXI_DATA_WIDTH - 1):0] dbg_result_overflow_count;
   wire [(C_S_AXI_DATA_WIDTH - 1):0] dbg_result_count;
   reg [(C_S_AXI_DATA_WIDTH - 1):0] dbg_result_generated;
   reg [(C_S_AXI_DATA_WIDTH - 1):0] dbg_result_consumed;

   wire underflow;
   wire pulses_finished;
   wire [7:0] clockout_div;
   // Digital output words
   wire [(U_PULSE_WIDTH - 1):0] ttl_out;

   // assume slave register width == pulse width
   assign pulse_io = (ttl_out | ttl_hi_mask) & (~ttl_lo_mask);

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
   //     RDATA <= <data>
   //     RVALID <= 1
   //     Trigger user logic
   //     Go to phase 1
   // Phase 1: Replied
   //   Wait for `RREADY == 1`
   //     ARREADY <= 1
   //     RVALID <= 0
   //     Go to phase 0

   // Change this version when making backward incompatible changes.
   localparam MAJOR_VER = 5;
   // Change this version when adding new features
   localparam MINOR_VER = 2;

   // Read state:
   //   0: idle
   //   1: wait for master to acknowledge the read
   reg s_axi_read_state;
   // This will assert exactly one cycle per request and is used by result_fifo below.
   wire s_axi_rdvalid = s_axi_read_state == 0 & S_AXI_ARVALID;
   wire [OPT_MEM_ADDR_BITS:0] s_axi_rd_regnum =
                              S_AXI_ARADDR[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];
   assign S_AXI_RRESP = 0;
   always @(posedge S_AXI_ACLK) begin
      if (~S_AXI_ARESETN) begin
         S_AXI_ARREADY <= 1'b1;
         S_AXI_RVALID <= 1'b0;
         S_AXI_RDATA <= 0;
         s_axi_read_state <= 1'b0;
      end else begin
         case (s_axi_read_state)
           1'b0: begin
              // Idle (wait for request)
              if (S_AXI_ARVALID) begin
                 S_AXI_ARREADY <= 1'b0;
                 // Address decoding for reading registers
                 case (s_axi_rd_regnum)
                   7'h00: S_AXI_RDATA <= ttl_hi_mask;
                   7'h01: S_AXI_RDATA <= ttl_lo_mask;
                   7'h02: S_AXI_RDATA <= slv_reg_status;
                   7'h03: S_AXI_RDATA <= slv_reg_ctrl;
                   7'h04: S_AXI_RDATA <= ttl_out;
                   7'h05: begin
                      S_AXI_RDATA[C_S_AXI_DATA_WIDTH - 1:8] <= 0;
                      S_AXI_RDATA[7:0] <= clockout_div;
                   end
                   7'h06: S_AXI_RDATA <= MAJOR_VER;
                   7'h07: S_AXI_RDATA <= MINOR_VER;
                   7'h1E: S_AXI_RDATA <= slv_reg_loopback;
                   7'h1F: // Reading from empty buffer has no effect.
                     S_AXI_RDATA <= ~result_fifo_empty ? result_fifo_rd_data : 0;
                   // Debug registers
                   7'h20: S_AXI_RDATA <= dbg_inst_word_count;
                   7'h21: S_AXI_RDATA <= dbg_inst_count;
                   7'h22: S_AXI_RDATA <= dbg_ttl_count;
                   7'h23: S_AXI_RDATA <= dbg_dds_count;
                   7'h24: S_AXI_RDATA <= dbg_wait_count;
                   7'h25: S_AXI_RDATA <= dbg_clear_count;
                   7'h26: S_AXI_RDATA <= dbg_loopback_count;
                   7'h27: S_AXI_RDATA <= dbg_clock_count;
                   7'h28: S_AXI_RDATA <= dbg_spi_count;
                   7'h29: S_AXI_RDATA <= dbg_underflow_cycle;
                   7'h2a: S_AXI_RDATA <= dbg_inst_cycle;
                   7'h2b: S_AXI_RDATA <= dbg_ttl_cycle;
                   7'h2c: S_AXI_RDATA <= dbg_wait_cycle;
                   7'h2d: S_AXI_RDATA <= dbg_result_overflow_count;
                   7'h2e: S_AXI_RDATA <= dbg_result_count;
                   7'h2f: S_AXI_RDATA <= dbg_result_generated;
                   7'h30: S_AXI_RDATA <= dbg_result_consumed;
                   default: S_AXI_RDATA <= 0;
                 endcase
                 S_AXI_RVALID <= 1'b1;
                 s_axi_read_state <= 1'b1;
              end
           end
           1'b1: begin
              // Replied (wait for acknowledgement)
              if (S_AXI_RREADY) begin
                 S_AXI_ARREADY <= 1'b1;
                 S_AXI_RVALID <= 1'b0;
                 s_axi_read_state <= 1'b0;
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
   //     if write ready:
   //       Write data
   //       BVALID <= 1
   //       Go to phase 2
   //     else:
   //       Go to phase 1
   // Phase 1: Recieved
   //   Wait for write ready
   //     Write data
   //     BVALID <= 1
   //     Go to phase 2
   // Phase 2: Replied
   //   Wait for `BREADY == 1`
   //     AWREADY <= 1
   //     WREADY <= 1
   //     BVALID <= 0
   //     Go to phase 0

   // Write state:
   //   0: idle / waiting for either address or data with the other one latched.
   //   1: wait for instruction FIFO to acknowledge the write
   //   2: wait for master to acknowledge the write reply
   reg [1:0] s_axi_write_state;

   // The caches here are used to handle the case where
   // the data and address do not arrive on the same cycle.
   // Once we acknowledge the read we can't use the input version anymore.
   reg s_axi_write_addr_latched;
   reg s_axi_write_data_latched;
   reg [C_S_AXI_ADDR_WIDTH - 1:0] s_axi_awaddr_l;
   reg [C_S_AXI_DATA_WIDTH - 1:0] s_axi_wdata_l;
   reg [(C_S_AXI_DATA_WIDTH / 8) - 1:0] s_axi_wstrb_l;
   wire [C_S_AXI_ADDR_WIDTH - 1:0] s_axi_awaddr = (s_axi_write_addr_latched ? s_axi_awaddr_l :
                                                   S_AXI_AWADDR);
   wire [OPT_MEM_ADDR_BITS:0] s_axi_wr_regnum =
                              s_axi_awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];
   wire [C_S_AXI_DATA_WIDTH - 1:0] s_axi_wdata = (s_axi_write_data_latched ? s_axi_wdata_l :
                                                  S_AXI_WDATA);
   wire [(C_S_AXI_DATA_WIDTH / 8) - 1:0] s_axi_wstrb = (s_axi_write_data_latched ? s_axi_wstrb_l :
                                                        S_AXI_WSTRB);

   wire s_axi_wrvalid = (s_axi_write_state == 0 ?
                         (S_AXI_AWVALID | s_axi_write_addr_latched) &
                         (S_AXI_WVALID | s_axi_write_data_latched) : s_axi_write_state == 1);
   wire tc_inst_ready;
   // This will de-assert the cycle following the one
   // `tc_inst_ready && tc_inst_valid`
   wire tc_inst_valid = (s_axi_wrvalid & s_axi_wr_regnum == 7'h1F);

   assign S_AXI_BRESP = 0;
   integer byte_index;
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

         ttl_hi_mask <= 0;
         ttl_lo_mask <= 0;
         slv_reg_ctrl <= 0;
         slv_reg_loopback <= 0;
      end else begin
         case (s_axi_write_state)
           2'b00: begin
              // Idle (wait for request)

              // Latch address/data
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
              end else if (S_AXI_AWVALID & ~s_axi_write_addr_latched) begin
                 s_axi_awaddr_l <= S_AXI_AWADDR;
                 s_axi_write_addr_latched <= 1'b1;
              end else if (S_AXI_WVALID && ~s_axi_write_data_latched) begin
                 s_axi_wdata_l <= S_AXI_WDATA;
                 s_axi_wstrb_l <= S_AXI_WSTRB;
                 s_axi_write_data_latched <= 1'b1;
              end

              // We got both the address and the data
              if ((S_AXI_AWVALID | s_axi_write_addr_latched) &
                  (S_AXI_WVALID | s_axi_write_data_latched)) begin
                 if (s_axi_wr_regnum == 7'h1F) begin
                    if (tc_inst_ready)
                      s_axi_write_state <= 2'b10;
                    else
                      s_axi_write_state <= 2'b01;
                    S_AXI_BVALID <= tc_inst_ready;
                 end else begin
                    S_AXI_BVALID <= 1'b1;
                    s_axi_write_state <= 2'b10;
                 end
                 case (s_axi_wr_regnum)
                   7'h00: begin
                      for (byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                           byte_index = byte_index + 1)
                        if (s_axi_wstrb[byte_index] == 1) begin
                           // Respective byte enables are asserted as per write strobes
                           // Slave register 0
                           ttl_hi_mask[(byte_index * 8)+:8] <= s_axi_wdata[(byte_index * 8)+:8];
                        end
                   end
                   7'h01: begin
                      for (byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                           byte_index = byte_index + 1)
                        if (s_axi_wstrb[byte_index] == 1) begin
                           // Respective byte enables are asserted as per write strobes
                           // Slave register 1
                           ttl_lo_mask[(byte_index * 8)+:8] <= s_axi_wdata[(byte_index * 8)+:8];
                        end
                   end
                   7'h03: begin
                      for (byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                           byte_index = byte_index + 1)
                        if (s_axi_wstrb[byte_index] == 1) begin
                           // Respective byte enables are asserted as per write strobes
                           // Slave register 1
                           slv_reg_ctrl[(byte_index * 8)+:8] <= s_axi_wdata[(byte_index * 8)+:8];
                        end
                   end
                   7'h1E: begin
                      for (byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                           byte_index = byte_index + 1)
                        if (s_axi_wstrb[byte_index] == 1) begin
                           // Respective byte enables are asserted as per write strobes
                           // Slave register 1
                           slv_reg_loopback[(byte_index * 8)+:8] <= s_axi_wdata[(byte_index * 8)+:8];
                        end
                   end
                 endcase
              end
           end
           2'b01: begin
              // Recieved (wait for instruction FIFO to acknowledge the write)
              if (tc_inst_ready)
                s_axi_write_state <= 2'b10;
              S_AXI_BVALID <= tc_inst_ready;
           end
           2'b10: begin
              // Replied (wait for acknowledgement)
              if (S_AXI_BREADY) begin
                 S_AXI_AWREADY <= 1;
                 S_AXI_WREADY <= 1;
                 S_AXI_BVALID <= 0;
                 s_axi_write_state <= 2'b00;
                 s_axi_write_addr_latched <= 1'b0;
                 s_axi_write_data_latched <= 1'b0;
              end
           end
         endcase
      end
   end

   // result_fifo. (records DDS, SPI, and loopback results)
   // The CPU can read the fifo from register 31.
   // Register 2 contains a saturated counter in bits `(RES_STATUS_ADDR_BITS+3):4`
   // for the number of results.
   // If the result overflows the buffer, the newest result will be discarded
   // and reading of the result will return zero (we will leave a sufficiently large gap
   // in the fifo to make sure results have a one-to-one match
   // with the requests that generates the results.
   // If the read underflows the buffer, the read will return zero and nothing will happen.

   wire [31:0] result_data;
   wire result_wr_en;
   overflow_fifo#(.DATA_WIDTH(32),
                  .COUNTER_WIDTH(C_S_AXI_DATA_WIDTH))
   result_overflow(.clock(S_AXI_ACLK),
                   .resetn(S_AXI_ARESETN),
                   .full(result_fifo_full),
                   .out_data(result_fifo_wr_data),
                   .out_en(result_fifo_wr_en),
                   .in_en(result_wr_en),
                   .in_data(result_data),
                   .overflow_count(dbg_result_overflow_count)
                   );

   localparam RES_STATUS_ADDR_BITS = 5;
   // This keeps an accurate count of the number of results we are keeping track of.
   // The latest results are in the result fifo whereas the older one could be overflowed.
   reg [31:0] result_count;
   assign dbg_result_count = result_count;
   // A saturated counter for the software to read.
   wire [(RES_STATUS_ADDR_BITS - 1):0] result_status_count =
                                       result_count[31:RES_STATUS_ADDR_BITS] == 0 ?
                                       result_count[(RES_STATUS_ADDR_BITS - 1):0] :
                                       (2**RES_STATUS_ADDR_BITS - 1);
   assign result_fifo_rd_en = S_AXI_ARESETN & s_axi_rdvalid & s_axi_rd_regnum == 7'h1F;
   always @(posedge S_AXI_ACLK) begin
      if (~S_AXI_ARESETN) begin
         result_count <= 0;
      end else begin
         if (result_wr_en) begin
            dbg_result_generated <= dbg_result_generated + 1;
            if (!result_fifo_rd_en) begin
               result_count <= result_count + 1;
            end else begin
               dbg_result_consumed <= dbg_result_consumed + 1;
            end
         end else if (result_fifo_rd_en && result_count != 0) begin
            dbg_result_consumed <= dbg_result_consumed + 1;
            result_count <= result_count - 1;
         end
      end

      if (~S_AXI_ARESETN | pulse_controller_init) begin
         dbg_result_generated <= 0;
         dbg_result_consumed <= 0;
      end
   end

   always @(posedge S_AXI_ACLK) begin
      if (~S_AXI_ARESETN) begin
         slv_reg_status <= 0;
      end else begin
         slv_reg_status[0] <= underflow;
         slv_reg_status[2] <= pulses_finished;
         slv_reg_status[(RES_STATUS_ADDR_BITS + 3):4] <= result_status_count;
      end
   end

   // Instruction fifo write end
   assign inst_fifo_wr_data = s_axi_wdata;
   assign inst_fifo_wr_en = S_AXI_ARESETN & ~pulse_controller_init & tc_inst_valid;
   wire inst_fifo_wr_ready = ~inst_fifo_full;
   // Signal the AXI controller that we've read the data
   assign tc_inst_ready = inst_fifo_wr_ready;
   always @(posedge S_AXI_ACLK) begin
      if (~S_AXI_ARESETN | pulse_controller_init) begin
         dbg_inst_word_count <= 0;
      end else if (inst_fifo_wr_ready & inst_fifo_wr_en) begin
         dbg_inst_word_count <= dbg_inst_word_count + 1;
      end
   end

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
      .result_data(result_data),
      .result_wr_en(result_wr_en),
      .dds_addr(dds_addr),
      .dds_data(dds_data),
      .dds_control(dds_control),
      .dds_addr2(dds_addr2),
      .dds_data2(dds_data2),
      .dds_control2(dds_control2),
      .dds_cs(dds_cs),
      .dds_FUD(dds_FUD),
      .ttl_out(ttl_out),
      .underflow(underflow),
      .spi_cs(spi_cs),
      .spi_mosi(spi_mosi),
      .spi_miso(spi_miso),
      .spi_sclk(spi_sclk),
      .pulses_finished(pulses_finished),
      .pulse_controller_release(inst_fifo_full),
      .pulse_controller_hold(pulse_controller_hold),
      .init(pulse_controller_init),
      .clockout(clockout),
      .clockout_div(clockout_div),

      .inst_fifo_empty(inst_fifo_empty),
      .inst_fifo_almost_empty(inst_fifo_almost_empty),
      .inst_fifo_rd_data(inst_fifo_rd_data),
      .inst_fifo_rd_en(inst_fifo_rd_en),

      // Debug registers
      .dbg_inst_count(dbg_inst_count),
      .dbg_ttl_count(dbg_ttl_count),
      .dbg_dds_count(dbg_dds_count),
      .dbg_wait_count(dbg_wait_count),
      .dbg_clear_count(dbg_clear_count),
      .dbg_loopback_count(dbg_loopback_count),
      .dbg_clock_count(dbg_clock_count),
      .dbg_spi_count(dbg_spi_count),
      .dbg_underflow_cycle(dbg_underflow_cycle),
      .dbg_inst_cycle(dbg_inst_cycle),
      .dbg_ttl_cycle(dbg_ttl_cycle),
      .dbg_wait_cycle(dbg_wait_cycle)
      );
endmodule
