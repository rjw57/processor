// Test: 16-bit register
`include "tbhelper.v"

`TBPROLOGUE

reg RST, INC, DEC, LOAD_bar, ASSERT_bar;
reg [15:0] BUS_in;
wire [15:0] BUS_out;
wire [15:0] display_value;

// Device under test
addrreg dut(
  .RST(RST),
  .LOAD_bar(LOAD_bar),
  .INC(INC),
  .DEC(DEC),
  .ASSERT_bar(ASSERT_bar),
  .BUS_in(BUS_in),
  .BUS_out(BUS_out),
  .display_value(display_value)
);

`TBBEGIN
  // Initial signal values
  RST = 1'b1;
  LOAD_bar = 1'b1;
  INC = 1'b1;
  DEC = 1'b1;
  ASSERT_bar = 1'b0;
  BUS_in = 16'hFFFF;

  // Reset
  `TBDELAY(2)
  RST = 1'b0;
  `TBDELAY(2)
  `TBASSERT(BUS_out === 16'h0000, "reset");

  // Load
  `TBDELAY(2)
  BUS_in = 16'hABCD;
  `TBDELAY(2)
  LOAD_bar = 1'b0;
  `TBDELAY(2)
  LOAD_bar = 1'b1;
  `TBDELAY(2)
  `TBASSERT(BUS_out === 16'hABCD, "load");

  // Increment
  BUS_in = 16'h1234;
  LOAD_bar = 1'b0;
  `TBDELAY(2)
  LOAD_bar = 1'b1;
  `TBDELAY(2)
  INC = 1'b0;
  `TBDELAY(2)
  INC = 1'b1;
  `TBDELAY(2)
  `TBASSERT(BUS_out === 16'h1235, "increment");

  // Roll over increment
  BUS_in = 16'hFFFF;
  LOAD_bar = 1'b0;
  `TBDELAY(2)
  LOAD_bar = 1'b1;
  `TBDELAY(2)
  INC = 1'b0;
  `TBDELAY(2)
  INC = 1'b1;
  `TBDELAY(2)
  `TBASSERT(BUS_out === 16'h0000, "roll over increment");

  // Decrement
  BUS_in = 16'h1234;
  LOAD_bar = 1'b0;
  `TBDELAY(2)
  LOAD_bar = 1'b1;
  `TBDELAY(2)
  DEC = 1'b0;
  `TBDELAY(2)
  DEC = 1'b1;
  `TBDELAY(2)
  `TBASSERT(BUS_out === 16'h1233, "decrement");

  // Roll over decrement
  BUS_in = 16'h0000;
  LOAD_bar = 1'b0;
  `TBDELAY(2)
  LOAD_bar = 1'b1;
  `TBDELAY(2)
  DEC = 1'b0;
  `TBDELAY(2)
  DEC = 1'b1;
  `TBDELAY(2)
  `TBASSERT(BUS_out === 16'hFFFF, "roll over decrement");

  // Assert
  `TBDELAY(2)
  ASSERT_bar = 1'b1;
  `TBDELAY(2)
  `TBASSERT(BUS_out === 16'hZZZZ, "high-Z");
`TBEND
