// two stage ALU
//
// The result of ALU for a given input will be available *two* clock cycles
// after the input appears on LHS, RHS.
//
// After one clock cycle, bitwise operations and shifting has been performed.
// After two clock cycles, addition has been performed.
//
// Output flags relate to the input from two cycles ago. (This *includes* the
// logical carry flag which is latched internally.)
//
// Addition carry in selection for addition applies on the next clock cycle and
// so one should speciy carry selection one clock cycle *after* the LHS and RHS
// inputs are given. Addition carry in selection is:
//
//  | CARRY_SEL | adddition carry in      |
//  |-----------|-------------------------|
//  | 2'b00     | 1'b0                    |
//  | 2'b01     | 1'b1                    |
//  | 2'b10     | current arith carry out |
//  | 2'b11     | unused                  |
//
// NOTE: we may want to change this so that carry selection is also latched.
// Then ALU dispatch is simpler.
//
// NOTE: we may want another control line indicating if flags should be updated
// on this clock tick. This is useful to avoid subsequent instructions
// corrupting the flag state.
module alu #(parameter DELAY_RISE = 0, DELAY_FALL = 0)
(
  input CLK,

  // input
  input [7:0] LHS,
  input [7:0] RHS,

  // control
  input [2:0] CARRY_SEL,  // carry select for addition
  input [2:0] SHIFT_OP,   // shift op applied to LHS
  input [3:0] LOGIC_OP,   // logical op applied (before shift)

  // result
  output [7:0] RESULT,

  // flags
  output OVERFLOW_FLAG,
  output NEGATIVE_FLAG,
  output ZERO_FLAG,
  output ARITH_CARRY_FLAG,
  output LOGIC_CARRY_FLAG
);

// TODO

endmodule
