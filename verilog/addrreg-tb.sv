// Test: 16-bit register
`include "tbhelper.v"

`TBPROLOGUE

reg RST_bar, LOAD_bar, INC, ASSERT_bar;
reg [15:0] BUS_in;
wire [15:0] BUS_out;

// Device under test
addrreg dut(
  .CLK(CLK),
  .RST_bar(RST_bar),
  .LOAD_bar(LOAD_bar),
  .INC(INC),
  .ASSERT_bar(ASSERT_bar),
  .BUS_in(BUS_in),
  .BUS_out(BUS_out)
);

`TBBEGIN
  // Initial signal values
  RST_bar = 1;
  LOAD_bar = 1;
  INC = 0;
  ASSERT_bar = 0;
  BUS_in = 16'b0;

  // Asynchronous reset
  `TBDELAY(2)
  RST_bar = 0;
  `TBDELAY(2)
  RST_bar = 1;
  `TBDELAY(2)
  `TBASSERT(BUS_out === 16'h0000, "Test reset");

  // Count
  `TBTICK
  `TBDELAY(2)
  INC = 1;
  `TBTICK
  `TBDELAY(2)
  `TBASSERT(BUS_out === 16'h0001, "Increment once");
  `TBDELAY(2)
  `TBTICK
  `TBDELAY(2)
  `TBASSERT(BUS_out === 16'h0002, "Increment twice");
  INC = 0;

  // Synchronous load
  `TBTICK
  `TBDELAY(2)
  RST_bar = 0;
  BUS_in = 16'h8FFF;
  `TBDELAY(2)
  RST_bar = 1;
  `TBDELAY(2)
  LOAD_bar = 0;
  `TBDELAY(2)
  `TBASSERT(BUS_out === 16'h0000, "reset");
  `TBTICK
  `TBDELAY(2)
  `TBASSERT(BUS_out === 16'h8FFF, "synchronous load");
  `TBDELAY(2)
  LOAD_bar = 1;

  // Increment with ripple carry
  `TBDELAY(2)
  INC = 1;
  `TBDELAY(2)
  `TBASSERT(BUS_out === 16'h8FFF, "synchronous load");
  `TBTICK
  `TBDELAY(2)
  `TBASSERT(BUS_out === 16'h9000, "increment with ripple carry");

  // Assert
  `TBTICK
  `TBDELAY(2)
  ASSERT_bar = 1;
  `TBDELAY(2)
  `TBASSERT(BUS_out === 16'bZ, "do not assert");
  `TBDELAY(2)
  ASSERT_bar = 0;
  `TBDELAY(2)
  `TBASSERT(BUS_out !== 16'bZ, "assert");
`TBEND
