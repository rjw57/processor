`include "tbhelper.v"

`TBPROLOGUE

reg [3:0] OP_SEL;
reg [7:0] LHS_IN;
reg [7:0] RHS_IN;
wire [7:0] VALUE_OUT;

// Device under test.
logicop #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) dut(
  .OP_SEL(OP_SEL),
  .LHS_IN(LHS_IN),
  .RHS_IN(RHS_IN),
  .VALUE_OUT(VALUE_OUT)
);

`TBBEGIN
  // Initial values
  OP_SEL = 4'b0000;
  LHS_IN = 8'b10100101;
  RHS_IN = 8'b11000011;

  `define TEST(op_sel, expected, msg) \
    `TBDELAY(2) \
    OP_SEL = op_sel; \
    `TBDELAY(2) \
    `TBASSERT(VALUE_OUT === (expected), $sformatf("%s, want 8'h%h, got 8'h%h", msg, expected, VALUE_OUT));

  `TEST(4'b0000, 8'b00000000, "zero");
  `TEST(4'b0101, ~RHS_IN, "not rhs");
  `TEST(4'b0110, LHS_IN ^ RHS_IN, "lhs XOR rhs");
  `TEST(4'b1000, LHS_IN & RHS_IN, "lhs AND rhs");
  `TEST(4'b1010, RHS_IN, "rhs");
  `TEST(4'b1110, LHS_IN | RHS_IN, "lhs OR rhs");
  `TEST(4'b1111, 8'b11111111, "ones");
`TBEND
