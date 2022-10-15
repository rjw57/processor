// Test: general purpose register
`include "tbhelper.v"

module test;

`TBSETUP
`TBCLK_WAIT_TICK_METHOD(wait_tick)

reg CLK, LOAD_bar, ASSERT_bar, ASSERT_LHS_bar, ASSERT_RHS_bar;
reg [7:0] BUS_in;
wire [7:0] BUS_out;
wire [7:0] LHS_out;
wire [7:0] RHS_out;

wire [7:0] display_value;

// Device under test
gpreg dut(
  .CLK(CLK),
  .LOAD_bar(LOAD_bar),
  .ASSERT_bar(ASSERT_bar),
  .ASSERT_LHS_bar(ASSERT_LHS_bar),
  .ASSERT_RHS_bar(ASSERT_RHS_bar),
  .BUS_in(BUS_in),
  .BUS_out(BUS_out),
  .LHS_out(LHS_out),
  .RHS_out(RHS_out),
  .display_value(display_value)
);

// Set up a clock
initial CLK = 1'b0;
always #50 CLK = ~CLK;

initial
begin
  $dumpfile("gpreg-tb.vcd");
  $dumpvars;

  // Initial signal values
  LOAD_bar = 1;
  ASSERT_bar = 1;
  ASSERT_LHS_bar = 1;
  ASSERT_RHS_bar = 1;

  // High-Z outputs
#10
  `TBASSERT(BUS_out === 8'bZ, "no bus assert")
  `TBASSERT(LHS_out === 8'bZ, "no lhs bus assert")
  `TBASSERT(RHS_out === 8'bZ, "no rhs bus assert")

  // Load value
#20
  LOAD_bar = 0;
  BUS_in = 8'hA8;
  wait_tick();
#25
  LOAD_bar = 1;
#30
  // Still have high-Z outputs but display updated
  `TBASSERT(BUS_out === 8'bZ, "post load no bus assert")
  `TBASSERT(LHS_out === 8'bZ, "post load no lhs bus assert")
  `TBASSERT(RHS_out === 8'bZ, "post load no rhs bus assert")
  `TBASSERT(display_value === 8'hA8, "display")

  // Clock ignored if LOAD not asserted
  BUS_in = 8'h8A;
  LOAD_bar = 1;
  wait_tick();
#10
  `TBASSERT(display_value === 8'hA8, "no load")

  // Assert lines
#20
  ASSERT_bar = 0;
  ASSERT_LHS_bar = 1;
  ASSERT_RHS_bar = 1;
#30
  `TBASSERT(BUS_out === 8'hA8, "bus assert")
  `TBASSERT(LHS_out === 8'bZ, "no lhs bus assert")
  `TBASSERT(RHS_out === 8'bZ, "no rhs bus assert")
#40
  ASSERT_bar = 1;
  ASSERT_LHS_bar = 0;
  ASSERT_RHS_bar = 1;
#50
  `TBASSERT(BUS_out === 8'bZ, "no bus assert")
  `TBASSERT(LHS_out === 8'hA8, "lhs bus assert")
  `TBASSERT(RHS_out === 8'bZ, "no rhs bus assert")
#60
  ASSERT_bar = 1;
  ASSERT_LHS_bar = 1;
  ASSERT_RHS_bar = 0;
#70
  `TBASSERT(BUS_out === 8'bZ, "no bus assert")
  `TBASSERT(LHS_out === 8'bZ, "no lhs bus assert")
  `TBASSERT(RHS_out === 8'hA8, "rhs bus assert")

  // Finish on next clock pulse
  wait_tick();
  `TBDONE
end

endmodule
