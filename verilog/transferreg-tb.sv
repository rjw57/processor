`include "tbhelper.v"

`TBPROLOGUE

reg LOAD_LOW;
reg LOAD_HIGH;
reg LOAD_SELECT;
reg ASSERT_LOW_bar;
reg ASSERT_HIGH_bar;
reg ASSERT_ADDR_bar;

reg [7:0] MAIN_in;
reg [15:0] ADDR_in;

wire [7:0] MAIN_out;
wire [15:0] ADDR_out;

wire [15:0] display_value;

// Device under test.
transferreg #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) dut(
  .LOAD_LOW(LOAD_LOW),
  .LOAD_HIGH(LOAD_HIGH),
  .LOAD_SELECT(LOAD_SELECT),
  .ASSERT_LOW_bar(ASSERT_LOW_bar),
  .ASSERT_HIGH_bar(ASSERT_HIGH_bar),
  .ASSERT_ADDR_bar(ASSERT_ADDR_bar),

  .MAIN_in(MAIN_in),
  .ADDR_in(ADDR_in),

  .MAIN_out(MAIN_out),
  .ADDR_out(ADDR_out),

  .display_value(display_value)
);

`TBBEGIN
  LOAD_LOW = 1'b1;
  LOAD_HIGH = 1'b1;
  LOAD_SELECT = 1'b0; // address bus
  MAIN_in = 8'h00;
  ADDR_in = 16'h0000;

  // Start by asserting to address bus.
  ASSERT_ADDR_bar = 1'b0;
  ASSERT_LOW_bar = 1'b1;
  ASSERT_HIGH_bar = 1'b1;

  `TBDELAY(2)
  ADDR_in = 16'hABCD;
  `TBDELAY(2)
  LOAD_LOW = 1'b0;
  LOAD_HIGH = 1'b0;
  `TBDELAY(2)
  LOAD_LOW = 1'b1;
  LOAD_HIGH = 1'b1;
  `TBDELAY(2)
  `TBASSERT(ADDR_out === 16'hABCD, "load address");

  `TBDELAY(2)
  ADDR_in = 16'h1234;
  `TBDELAY(2)
  LOAD_LOW = 1'b0;
  `TBDELAY(2)
  LOAD_LOW = 1'b1;
  `TBDELAY(2)
  `TBASSERT(ADDR_out === 16'hAB34, "load low address");

  `TBDELAY(2)
  ADDR_in = 16'h5678;
  `TBDELAY(2)
  LOAD_HIGH = 1'b0;
  `TBDELAY(2)
  LOAD_HIGH = 1'b1;
  `TBDELAY(2)
  `TBASSERT(ADDR_out === 16'h5634, "load high address");

  `TBDELAY(2)
  MAIN_in = 8'h87;
  LOAD_SELECT = 1'b1;
  `TBDELAY(2)
  LOAD_HIGH = 1'b0;
  `TBDELAY(2)
  LOAD_HIGH = 1'b1;
  `TBDELAY(2)
  `TBASSERT(ADDR_out === 16'h8734, "load high main");

  `TBDELAY(2)
  MAIN_in = 8'hDE;
  LOAD_SELECT = 1'b1;
  `TBDELAY(2)
  LOAD_LOW = 1'b0;
  `TBDELAY(2)
  LOAD_LOW = 1'b1;
  `TBDELAY(2)
  `TBASSERT(ADDR_out === 16'h87DE, "load low main");

  `TBDELAY(2)
  ASSERT_LOW_bar = 1'b1;
  ASSERT_HIGH_bar = 1'b1;
  ASSERT_ADDR_bar = 1'b1;
  `TBDELAY(2)
  `TBASSERT(MAIN_out === 8'hZZ, "main hi-Z");
  `TBASSERT(ADDR_out === 16'hZZZZ, "addr hi-Z");

  `TBDELAY(2)
  ASSERT_LOW_bar = 1'b0;
  ASSERT_HIGH_bar = 1'b1;
  ASSERT_ADDR_bar = 1'b1;
  `TBDELAY(2)
  `TBASSERT(MAIN_out === 8'hDE, "main assert");
  `TBASSERT(ADDR_out === 16'hZZZZ, "addr hi-Z");

  `TBDELAY(2)
  ASSERT_LOW_bar = 1'b1;
  ASSERT_HIGH_bar = 1'b0;
  ASSERT_ADDR_bar = 1'b1;
  `TBDELAY(2)
  `TBASSERT(MAIN_out === 8'h87, "main assert");
  `TBASSERT(ADDR_out === 16'hZZZZ, "addr hi-Z");

  `TBDELAY(2)
  ASSERT_LOW_bar = 1'b1;
  ASSERT_HIGH_bar = 1'b1;
  ASSERT_ADDR_bar = 1'b0;
  `TBDELAY(2)
  `TBASSERT(MAIN_out === 8'hZZ, "main hi-Z");
  `TBASSERT(ADDR_out === 16'h87DE, "addr assert");
`TBEND
