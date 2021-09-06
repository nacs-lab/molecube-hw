/**
 * timing_controller: precise timing FIFO to control experiments
 *
 * The FIFO is attached to an AXI bus for writing.  The timing controller reads
 * words from the FIFO in a precisely timed manner for digital control in a
 * laboratory. The controller can output TTL words for a variable number of
 * clock cycles, and write to a bank of attached DDS modules (AD9858 and AD9914).
 * A flag can be set to count photons (# of rising edges on an input).
 * The phase of the photon arrival times with respect to a sync clock can be
 * tracked.
 *
 * SPI communications can be performed as part of the pulse sequence.
 *
 * DDS, photon counts, and SPI results can be read back via a second read FIFO.
 *
 * Underflow of the write FIFO (timing failure) can be detected.
 *
 * This is implemented as a finite state machine (FSM) with attached
 * DDS control
 *
 * bits 63...60, instruction
 *
 * Current instructions:
 *
 * 0 TIMED_OUTPUT (6 cycles minimum, 2^24 - 1 = 16,777,215 maximum)
 *   bits 55...32 = duration (in clock cycles, must be at least 6)
 *   bits 31...0  = output word
 *
 * 1 DDS_CONTROL (50 cycles, purposely slowed because the external DDS bus is
 *   not so fast)
 *   bits 47...32 = DDS opcode (read and write freq/phase/amplitude/registers)
 *   bits 31...0  = DDS operand (phase/frequency/amplitude/register value)
 *
 * 2 WAIT (pulse output remains unchanged)
 *   bits 55...32 = duration (in clock cycles, must be at least 6)
 *
 * 3 CLEAR_UNDERFLOW (5 cycles)
 *
 * 4 PUSH_DATA (variable # cycles)
 *   bits 55...32 = duration (in clock cycles)
 *   push bits 31...0 onto result fifo for loop-back testing
 *
 * 5 ENABLE CLOCK OUT
 *   period - 1 = bits 7...0. disabled when bits 7...0 = 255
 *
 * 6 SPI COMMAND
 *   bits 55...48 = duration (x4, in clock cycles, up to 4 x 2.55us)
 *   bits 47...32 = SPI opcode (see spi_controller.v)
 *   bits 31... 0 = SPI output data (bit 31 is emitted first)
 *
 * bit 59, disable underflow flag.  Prevents underflow from going high.
 *
 * Post-PAR timing for Zynq ZC702 speed -1:
 * Minimum period:   4.916ns{1}   (Maximum frequency: 203.417MHz)
 */

module clockout_controller(input clock, input reset, input [7:0] div,
                            output reg out);
   reg [7:0] counter;
   always @(posedge clock, posedge reset) begin
      if (reset | div == 255) begin
         // reset
         out <= 0;
         counter <= 0;
      end else begin
         // emit divided clock with period 2 x (div + 1)
         if (counter == div) begin
            counter <= 0;
            out <= ~out;
         end else begin
            counter <= counter + 1;
         end
      end
   end
endmodule

module timing_controller
  #(parameter N_DDS = 8,
    parameter U_DDS_DATA_WIDTH = 16,
    parameter U_DDS_ADDR_WIDTH = 7,
    parameter U_DDS_CTRL_WIDTH = 3,

    parameter N_SPI = 1,

    parameter BUS_DATA_WIDTH = 32,
    parameter RESULT_WIDTH = 32,

    localparam TTL_WIDTH = 32)
   (input clock,
    input resetn,

    output [(RESULT_WIDTH - 1):0] result_data,
    output result_wr_en,

    // dds_data*: tri-state for dds_data to allow read & write.
    output [(U_DDS_ADDR_WIDTH - 1):0] dds_addr,
    inout [(U_DDS_DATA_WIDTH - 1):0] dds_data,
    output [(U_DDS_CTRL_WIDTH - 1):0] dds_control,
    output [(U_DDS_ADDR_WIDTH - 1):0] dds_addr2,
    inout [(U_DDS_DATA_WIDTH - 1):0] dds_data2,
    output [(U_DDS_CTRL_WIDTH - 1):0] dds_control2,

    output [(N_DDS - 1):0] dds_cs,
    output [1:0] dds_FUD,

    output reg [(TTL_WIDTH - 1):0] ttl_out,
    output reg underflow,

    output [(N_SPI - 1):0] spi_cs,
    output spi_mosi,
    input spi_miso,
    output spi_sclk,

    output reg pulses_finished,
    // pulses wait until this goes low
    input pulse_controller_hold,
    input pulse_controller_release,
    // init is like reset, but hold the current TTL outputs toggle this at
    // the start of the sequence.
    input init,
    output clockout,
    output reg [7:0] clockout_div,

    input inst_fifo_empty,
    input inst_fifo_almost_empty, // unused
    input [63:0] inst_fifo_rd_data,
    output inst_fifo_rd_en,
    output inst_fifo_wr_en,

    output reg [(BUS_DATA_WIDTH - 1):0] dbg_inst_count,
    output reg [(BUS_DATA_WIDTH - 1):0] dbg_ttl_count,
    output reg [(BUS_DATA_WIDTH - 1):0] dbg_dds_count,
    output reg [(BUS_DATA_WIDTH - 1):0] dbg_wait_count,
    output reg [(BUS_DATA_WIDTH - 1):0] dbg_clear_count,
    output reg [(BUS_DATA_WIDTH - 1):0] dbg_loopback_count,
    output reg [(BUS_DATA_WIDTH - 1):0] dbg_clock_count,
    output reg [(BUS_DATA_WIDTH - 1):0] dbg_spi_count,
    output reg [(BUS_DATA_WIDTH - 1):0] dbg_underflow_cycle,
    output reg [(BUS_DATA_WIDTH - 1):0] dbg_inst_cycle,
    output reg [(BUS_DATA_WIDTH - 1):0] dbg_ttl_cycle,
    output reg [(BUS_DATA_WIDTH - 1):0] dbg_wait_cycle
    );

   wire reset = ~resetn;

   clockout_controller clockout_ctrl(.clock(clock),
                                       .reset(reset),
                                       .out(clockout),
                                       .div(clockout_div));

   localparam DDS_OPCODE_WIDTH = 16;
   localparam DDS_OPERAND_WIDTH = 32;
   reg dds_we;
   reg [(DDS_OPCODE_WIDTH - 1):0] dds_opcode;
   reg [(DDS_OPERAND_WIDTH - 1):0] dds_operand;
   wire dds_WrReq;
   wire [31:0] dds_result;

   dds_controller#(.N_DDS(N_DDS),
                   .DDS_OPCODE_WIDTH(DDS_OPCODE_WIDTH),
                   .DDS_OPERAND_WIDTH(DDS_OPERAND_WIDTH),
                   .U_DDS_DATA_WIDTH(U_DDS_DATA_WIDTH),
                   .U_DDS_ADDR_WIDTH(U_DDS_ADDR_WIDTH),
                   .U_DDS_CTRL_WIDTH(U_DDS_CTRL_WIDTH))
   dds_controller_inst(.clock(clock),
                       .reset(reset),
                       .write_enable(dds_we),
                       .opcode(dds_opcode),
                       .operand(dds_operand),
                       .dds_addr(dds_addr),
                       .dds_data(dds_data),
                       .dds_control(dds_control),
                       .dds_addr2(dds_addr2),
                       .dds_data2(dds_data2),
                       .dds_control2(dds_control2),
                       .dds_cs(dds_cs),
                       .dds_FUD(dds_FUD),
                       .result_data(dds_result),
                       .result_WrReq(dds_WrReq));

   reg [31:0] loopback_data;
   reg loopback_WrReq;
   // allow DDS_controller or loop back to write into the result fifo
   // Write one word when result_wr_en is high.
   // Data should be valid during the cycle and they can have arbitrary value otherwise.
   assign result_wr_en = dds_WrReq | loopback_WrReq;
   // each data (dds, loopback, result) is only valid when the respective wrreq is high.
   assign result_data = loopback_WrReq ? loopback_data : dds_result;

   localparam INSTRUCTION_BITA = 63;
   localparam INSTRUCTION_BITB = 60;
   localparam ENABLE_TIMING_CHECK_BIT = 63 - 4; // 0x08000000
   localparam TIMER_WIDTH = 24;
   localparam TIMER_BITA = 63 - 8;
   localparam TIMER_BITB = TIMER_BITA - TIMER_WIDTH + 1;
   localparam TTL_BITA = 31;
   localparam TTL_BITB = 0;

   reg [(TIMER_WIDTH - 1):0] wait_timer;
   reg waiting;
   reg timing_check;
   // goes high when `pulse_controller_release` is true.
   reg force_released;
   // `pulses_controller_hold` will be released if FIFO is full or `pulse_controller_hold` is
   // low once released, the controller runs until it is done.
   // The last condition on `pulse_controller_release` makes sure this is released
   // as soon as the FIFO is full. (we could also use almost_full for this if we want)
   wire pulses_hold = pulse_controller_hold & ~force_released & ~pulse_controller_release;

   // The following condition must be consistent with how the fifo is read below.
   assign inst_fifo_rd_en = ~init & ~reset & ~waiting & ~pulses_hold;
   // Swap the word order since the FIFO generater
   // fills the MSB first whereas we want the LSB first.
   wire [63:0] instruction = {inst_fifo_rd_data[31:0], inst_fifo_rd_data[63:32]};

   localparam SPI_OPCODE_WIDTH = 16;
   localparam SPI_OPERAND_WIDTH = 18;
   reg spi_we;
   reg [(SPI_OPCODE_WIDTH - 1):0] spi_opcode;
   reg [(SPI_OPERAND_WIDTH - 1):0] spi_operand;
   wire spi_WrReq;
   wire [31:0] spi_result;

   spi_controller#(.N_SPI(N_SPI),
                   .SPI_OPCODE_WIDTH(SPI_OPCODE_WIDTH),
                   .SPI_OPERAND_WIDTH(SPI_OPERAND_WIDTH))
   spi_controller_inst(.clock(clock),
                       .reset(reset),
                       .write_enable(spi_we),
                       .opcode(spi_opcode),
                       .operand(spi_operand),
                       .spi_cs(spi_cs),
                       .spi_mosi(spi_mosi),
                       .spi_miso(spi_miso),
                       .spi_sclk(spi_sclk),
                       .result_data(spi_result),
                       .result_WrReq(spi_WrReq));

   reg is_ttl;
   reg is_wait;

   always @(posedge clock, posedge reset) begin
      if (reset | init) begin
         if (reset) begin
            ttl_out <= 0;
         end

         waiting <= 0;
         wait_timer <= 0;
         dds_we <= 0;
         timing_check <= 0;
         underflow <= 0;
         pulses_finished <= 1;
         loopback_WrReq <= 0;
         clockout_div <= 255;
         force_released <= 0;

         dbg_inst_count <= 0;
         dbg_ttl_count <= 0;
         dbg_dds_count <= 0;
         dbg_wait_count <= 0;
         dbg_clear_count <= 0;
         dbg_loopback_count <= 0;
         dbg_clock_count <= 0;
         dbg_spi_count <= 0;
         dbg_underflow_cycle <= 0;
         dbg_inst_cycle <= 0;
         dbg_ttl_cycle <= 0;
         dbg_wait_cycle <= 0;
      end else begin
         if (pulse_controller_release)
           force_released <= 1;

         // `waiting`:
         // 0: Fetch and dispatch instruction from instruction FIFO
         // 1: Wait for the instruction to finish
         if (!waiting) begin
            if (inst_fifo_empty | ~inst_fifo_rd_en) begin
               pulses_finished <= 1;
               if (timing_check) begin
                  dbg_underflow_cycle <= dbg_underflow_cycle + 1;
                  // underflow bit is sticky
                  underflow <= 1;
               end
            end else begin
               // Note that this is the only block where `instruction` is valid.
               // All necessary data fields must be cached in a different register
               // if it needs to be accessible later.
               // default values, may be overwritten below.
               is_ttl <= 0;
               is_wait <= 0;
               waiting <= 1;
               pulses_finished <= 0;
               dbg_inst_count <= dbg_inst_count + 1;
               dbg_inst_cycle <= dbg_inst_cycle + 1;
               timing_check <= instruction[ENABLE_TIMING_CHECK_BIT];
               case (instruction[INSTRUCTION_BITA:INSTRUCTION_BITB])
                 0 : begin // set digital output for given duration
                    is_ttl <= 1;
                    dbg_ttl_count <= dbg_ttl_count + 1;
                    dbg_ttl_cycle <= dbg_ttl_cycle + 1;
                    if (instruction[TIMER_BITA:TIMER_BITB] == 1 ||
                        instruction[TIMER_BITA:TIMER_BITB] == 0)
                      waiting <= 0; // 1 cycle pulse, go to next instruction immediately
                    wait_timer <= instruction[TIMER_BITA:TIMER_BITB];
                    ttl_out <= instruction[TTL_BITA:TTL_BITB];
                 end
                 1 : begin // DDS instruction
                    dbg_dds_count <= dbg_dds_count + 1;
                    dds_opcode <= instruction[47:32];
                    dds_operand <= instruction[31:0];
                    dds_we <= 1; // write to DDS
                    wait_timer <= 50; // instruction takes 320 ns. Allocate 500 ns.
                 end
                 2 : begin // wait
                    is_wait <= 1;
                    dbg_wait_count = dbg_wait_count + 1;
                    dbg_wait_cycle = dbg_wait_cycle + 1;
                    if (instruction[TIMER_BITA:TIMER_BITB] == 1 ||
                        instruction[TIMER_BITA:TIMER_BITB] == 0)
                      waiting <= 0; // 1 cycle pulse, go to next instruction immediately
                    wait_timer <= instruction[TIMER_BITA:TIMER_BITB];
                 end
                 3 : begin // clear underflow
                    dbg_clear_count = dbg_clear_count + 1;
                    underflow <= 0;
                    dbg_underflow_cycle <= 0;
                    wait_timer <= 5;
                 end
                 4 : begin // loop-back data
                    dbg_loopback_count = dbg_loopback_count + 1;
                    loopback_data <= instruction[31:0];
                    loopback_WrReq <= 1;
                    wait_timer <= 5;
                 end
                 5 : begin // enable/disable clockout
                    dbg_clock_count = dbg_clock_count + 1;
                    clockout_div <= instruction[7:0];
                    wait_timer <= 5;
                 end
                 // SPI communication.
                 6 : begin
                    dbg_spi_count = dbg_spi_count + 1;
                    spi_opcode <= instruction[47:32];
                    spi_operand <= instruction[(SPI_OPERAND_WIDTH - 1):0];
                    spi_we <= 1; // write to SPI
                    wait_timer <= 45;
                 end
                 default : wait_timer <= 1000;
               endcase
            end
         end else begin
            // Waiting
            loopback_WrReq <= 0;
            dds_we <= 0;
            spi_we <= 0;
            // Although we knew the length of each instruction in the previous step
            // doing the counting like this should be more robust against off-by-one error
            // and also hopefully reduce the maximum amount of work in a single step.
            dbg_inst_cycle <= dbg_inst_cycle + 1;
            if (is_ttl)
              dbg_ttl_cycle = dbg_ttl_cycle + 1;
            if (is_wait)
              dbg_wait_cycle = dbg_wait_cycle + 1;
            // The `wait_timer` includes the fetch/decoding cycle
            // to avoid doing an unnecessary `- 1`
            // (we should just change the interface to store cycle - 1
            // in the instruction though since a wait time of `0` is never legal anyway).
            // Unfortunately that's a breaking change so we can't do that for now...
            // Therefore, we should wait here for `wait_timer - 1` cycles.
            // (i.e. end condition is `2` on entry)
            // 1 cycle wait/ttl pulse bypasses this step.
            if (wait_timer == 2) begin
               waiting <= 0;
            end else begin
               wait_timer <= wait_timer - 1; // decrement timer
            end
         end
      end
   end
endmodule
