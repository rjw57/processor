// Test: 16-bit register
`include "tbhelper.v"

module test;

`TBSETUP
`TBCLK_WAIT_TICK_METHOD(wait_tick)

reg CLK, RST_bar, LOAD_bar, INC, ASSERT_bar;
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

// Set up a clock
initial CLK = 1'b0;
always #50 CLK = ~CLK;

initial
begin
  $dumpfile("addrreg-tb.vcd");
  $dumpvars;

  // Initial signal values
  RST_bar = 1;
  LOAD_bar = 1;
  INC = 0;
  ASSERT_bar = 0;
  BUS_in = 16'b0;

  // Asynchronous reset
#5
  RST_bar = 0;
#15
  RST_bar = 1;
#25
  `TBASSERT(BUS_out === 16'h0000, "Test reset");

  // Count
  wait_tick();
#5
  INC = 1;
  wait_tick();
#5
  `TBASSERT(BUS_out === 16'h0001, "Increment once");
#15
  wait_tick();
#5
  `TBASSERT(BUS_out === 16'h0002, "Increment twice");
  INC = 0;

  // Synchronous load
  wait_tick();
#5
  RST_bar = 0;
  BUS_in = 16'h8FFF;
#15
  RST_bar = 1;
#25
  LOAD_bar = 0;
#35
  `TBASSERT(BUS_out === 16'h0000, "reset");
  wait_tick();
#5
  `TBASSERT(BUS_out === 16'h8FFF, "synchronous load");
#15
  LOAD_bar = 1;

  // Increment with ripple carry
#25
  INC = 1;
#35
  `TBASSERT(BUS_out === 16'h8FFF, "synchronous load");
  wait_tick();
#5
  `TBASSERT(BUS_out === 16'h9000, "increment with ripple carry");

  // Assert
  wait_tick();
#5
  ASSERT_bar = 1;
#15
  `TBASSERT(BUS_out === 16'bZ, "do not assert");
#25
  ASSERT_bar = 0;
#35
  `TBASSERT(BUS_out !== 16'bZ, "assert");

  // Finish on next clock pulse
  wait_tick();
  `TBDONE;
end

endmodule
