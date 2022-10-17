// two stage ALU
//
// The result of ALU for a given input will be available *two* clock cycles
// after the input appears on LHS, RHS.
//
// After one clock cycle, bitwise operations and shifting has been performed.
// After two clock cycles, addition has been performed.
//
// Addition carry in for addition applies on the next clock cycle and so one
// should speciy carry one clock cycle *after* the LHS and RHS inputs are given.
//
module alu #(parameter DELAY_RISE = 0, DELAY_FALL = 0) ( input CLK,

  // input
  input [7:0] LHS,
  input [7:0] RHS,

  // 8 control lines for first stage
  input [1:0] SHIFT_OP,     // shift op applied to LHS
  input [1:0] SHIFT_INTERP, // interp select for LHS shift
  input [3:0] LOGIC_OP,     // logical op applied (before shift)

  // Input carry
  input CARRY_IN,

  // result
  output [7:0] RESULT,
  output CARRY_OUT
);

// ALU Operations:
//
// Result given control lines. 'X' means that the bit pattern does not matter.
//
//  | Opcode  | Result     | Shift Op  | Shift Interp  | Logic Op  | Carry in  |
//  |---------|------------|-----------|---------------|-----------|-----------|
//  | 4'b0000 | LHS + RHS  | 2'b01     | 2'bXX         | 4'b1010   | 1'b0      |
//  | 4'b0001 | LHS - RHS  | 2'b01     | 2'bXX         | 4'b0101   | 1'b1      |
//  | 4'b0010 | LHS & RHS  | 2'b00     | 2'bXX         | 4'b1000   | 1'b0      |
//  | 4'b0011 | LHS | RHS  | 2'b00     | 2'bXX         | 4'b1110   | 1'b0      |
//  | 4'b0100 | LHS ^ RHS  | 2'b00     | 2'bXX         | 4'b0110   | 1'b0      |
//  | 4'b0101 | ~RHS       | 2'b00     | 2'bXX         | 4'b0101   | 1'b0      |
//  | 4'b0110 | LHS << 1   | 2'b10     | 2'b00         | 4'b0000   | 1'b0      |
//  | 4'b0111 | LHS >> 1   | 2'b11     | 2'b00         | 4'b0000   | 1'b0      |
//  | 4'b1000 | LHS ~>> 1  | 2'b11     | 2'b11         | 4'b0000   | 1'b0      |
//  | 4'b1001 | LHS <<< 1  | 2'b10     | 2'b11         | 4'b0000   | 1'b0      |
//  | 4'b1010 | LHS >>> 1  | 2'b11     | 2'b10         | 4'b0000   | 1'b0      |
//
// Note: '~>>' == arithmetic shift, '>>>' == rotate right, '<<<' == rotate left

wire [7:0] shiftop_out;
wire [7:0] logicop_out;
wire [7:0] lhs_latch;
wire [7:0] rhs_latch;

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
  .CARRY_IN(CARRY_IN),
  .RESULT(RESULT),
  .CARRY_OUT(CARRY_OUT)
);

// TODO

endmodule
