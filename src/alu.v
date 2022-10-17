// two stage ALU
//
// The result of ALU for a given input will be available *two* clock cycles
// after the input appears on LHS, RHS.
//
// After one clock cycle, bitwise operations and shifting has been performed.
// After two clock cycles, addition has been performed.
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
module alu #(parameter DELAY_RISE = 0, DELAY_FALL = 0)
(
  input CLK,

  // input
  input [7:0] LHS,
  input [7:0] RHS,

  // 8 control lines for first stage
  input [1:0] SHIFT_OP,     // shift op applied to LHS
  input [1:0] SHIFT_INTERP, // interp select for LHS shift
  input [3:0] LOGIC_OP,     // logical op applied (before shift)

  // 2 control lines for second stage
  input [1:0] CARRY_SEL,    // carry select for addition

  // result
  output [7:0] RESULT,
  output CARRY_OUT
);

wire [7:0] shiftop_out;
wire [7:0] logicop_out;
wire [7:0] lhs_latch;
wire [7:0] rhs_latch;
wire add_carry_in;

// stage 1
shiftop #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) shiftop(
  .OP_SEL(SHIFT_OP),
  .INTERP_SEL(SHIFT_INTERP),
  .VALUE_IN(LHS),
  .VALUE_OUT(shiftop_out)
);

logicop #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) logicop(
  .OP_SEL(LOGIC_OP),
  .LHS_IN(LHS),
  .RHS_IN(RHS),
  .VALUE_OUT(logicop_out)
);

// latches
ttl_74377 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) lhs_reg(
  .Enable_bar (1'b0),
  .D          (shiftop_out),
  .Clk        (CLK),
  .Q          (lhs_latch)
);

ttl_74377 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) rhs_reg(
  .Enable_bar (1'b0),
  .D          (logicop_out),
  .Clk        (CLK),
  .Q          (rhs_latch)
);

// stage 2
adder #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) adder(
  .LHS(lhs_latch),
  .RHS(rhs_latch),
  .CARRY_IN(add_carry_in),
  .RESULT(RESULT),
  .CARRY_OUT(CARRY_OUT)
);

// TODO

endmodule
