// Test bench helpers.
// Adapted from https://github.com/TimRudy/ice-chips-verilog
`default_nettype none

`define tbassert(cond, msg) assert (cond) else $error(msg)

`define TBCLK_WAIT_TICK_METHOD(TB_NAME) task TB_NAME; repeat (1) @(posedge CLK); endtask
