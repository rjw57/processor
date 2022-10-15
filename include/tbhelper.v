// Test bench helpers.
// Adapted from https://github.com/TimRudy/ice-chips-verilog

`timescale 1ns/1ps
`default_nettype none

`define TBASSERT_METHOD(TB_NAME) reg [512:0] tbassertLastPassed = ""; task TB_NAME(input condition, input [512:0] s); if (condition === 1'bx) $display("-Failed === x value: %-s", s); else if (condition == 0) $display("-Failed: %-s", s); else if (s != tbassertLastPassed) begin $display("Passed: %-s", s); tbassertLastPassed = s; end endtask

`define TBCLK_WAIT_TICK_METHOD(TB_NAME) task TB_NAME; repeat (1) @(posedge CLK); endtask
