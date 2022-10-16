// Test bench helpers.
// Adapted from https://github.com/TimRudy/ice-chips-verilog
`default_nettype none

`define TBSETUP reg tb_all_asserts_ok = 1'b1;
`ifdef TB_SET_EXIT_CODE
`define TBDONE $finish_and_return(!tb_all_asserts_ok);
`else
`define TBDONE $finish;
`endif

`ifdef TBVERBOSE
  `define TB_IS_VERBOSE 1
`else
  `define TB_IS_VERBOSE 0
`endif

`define TBASSERT(cond, msg) assert (cond) \
  begin \
    if(`TB_IS_VERBOSE) $display("ok: ", msg); \
  end \
  else \
  begin \
    tb_all_asserts_ok = 1'b0; \
    $error("fail: ", msg); \
  end

`define TBCLK_WAIT_TICK_METHOD(TB_NAME) task TB_NAME; repeat (1) @(posedge CLK); endtask

`define TBPROLOGUE \
module testbench #( \
  parameter DELAY_RISE = 10, DELAY_FALL = 10, DUMP_FILENAME = "testbench.vcd" \
); \
  reg CLK; \
  `TBSETUP \
  `TBCLK_WAIT_TICK_METHOD(wait_tick) \
  initial CLK = 1'b0; \
  always #($max(1, 20 * DELAY_RISE)) CLK = ~CLK;

`define TBBEGIN \
  initial \
  begin \
    $dumpfile(DUMP_FILENAME); \
    $dumpvars;

// Delay for N gate delays
`define TBDELAY(N) #($max(1, $max(DELAY_RISE, DELAY_FALL)) * N)

// Delay until next clock tick
`define TBTICK wait_tick();

`define TBEND \
    `TBDELAY(2) \
    `TBDONE \
  end \
  endmodule
