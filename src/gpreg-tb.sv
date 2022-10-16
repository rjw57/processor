// Test: general purpose register
`include "tbhelper.v"

`TBPROLOGUE

reg LOAD_bar, ASSERT_MAIN_bar, ASSERT_LHS_bar, ASSERT_RHS_bar;
reg [7:0] DATA_in;
wire [7:0] MAIN_out;
wire [7:0] LHS_out;
wire [7:0] RHS_out;

wire [7:0] display_value;

// Device under test.
gpreg #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) dut(
  .CLK(CLK),
  .LOAD_bar(LOAD_bar),
  .ASSERT_MAIN_bar(ASSERT_MAIN_bar),
  .ASSERT_LHS_bar(ASSERT_LHS_bar),
  .ASSERT_RHS_bar(ASSERT_RHS_bar),
  .DATA_in(DATA_in),
  .MAIN_out(MAIN_out),
  .LHS_out(LHS_out),
  .RHS_out(RHS_out),
  .display_value(display_value)
);

`TBBEGIN
  // Initial signal values
  LOAD_bar = 1;
  ASSERT_MAIN_bar = 1;
  ASSERT_LHS_bar = 1;
  ASSERT_RHS_bar = 1;

  // High-Z outputs
  `TBDELAY(2)
  `TBASSERT(MAIN_out === 8'bZ, "no bus assert")
  `TBASSERT(LHS_out === 8'bZ, "no lhs bus assert")
  `TBASSERT(RHS_out === 8'bZ, "no rhs bus assert")

  // Load value
  `TBDELAY(2)
  LOAD_bar = 0;
  DATA_in = 8'hA8;

  `TBTICK
  `TBDELAY(2)
  LOAD_bar = 1;

  `TBDELAY(2)
  // Still have high-Z outputs but display updated
  `TBASSERT(MAIN_out === 8'bZ, "post load no bus assert")
  `TBASSERT(LHS_out === 8'bZ, "post load no lhs bus assert")
  `TBASSERT(RHS_out === 8'bZ, "post load no rhs bus assert")
  `TBASSERT(display_value === 8'hA8, "display")

  // Clock ignored if LOAD not asserted
  DATA_in = 8'h8A;
  LOAD_bar = 1;

  `TBTICK
  `TBDELAY(2)
  `TBASSERT(display_value === 8'hA8, "no load")

  // Assert lines
  `TBDELAY(2)
  ASSERT_MAIN_bar = 0;
  ASSERT_LHS_bar = 1;
  ASSERT_RHS_bar = 1;

  `TBDELAY(2)
  `TBASSERT(MAIN_out === 8'hA8, "bus assert")
  `TBASSERT(LHS_out === 8'bZ, "no lhs bus assert")
  `TBASSERT(RHS_out === 8'bZ, "no rhs bus assert")

  `TBDELAY(2)
  ASSERT_MAIN_bar = 1;
  ASSERT_LHS_bar = 0;
  ASSERT_RHS_bar = 1;

  `TBDELAY(2)
  `TBASSERT(MAIN_out === 8'bZ, "no bus assert")
  `TBASSERT(LHS_out === 8'hA8, "lhs bus assert")
  `TBASSERT(RHS_out === 8'bZ, "no rhs bus assert")

  `TBDELAY(2)
  ASSERT_MAIN_bar = 1;
  ASSERT_LHS_bar = 1;
  ASSERT_RHS_bar = 0;

  `TBDELAY(2)
  `TBASSERT(MAIN_out === 8'bZ, "no bus assert")
  `TBASSERT(LHS_out === 8'bZ, "no lhs bus assert")
  `TBASSERT(RHS_out === 8'hA8, "rhs bus assert")
`TBEND
