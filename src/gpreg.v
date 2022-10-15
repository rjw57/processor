// 8-bit general purpose register with synchronous load and asynchronous assert.
//
//
// Uses 4 ICs == 1x74377, 3x74244

module gpreg(
  // Control lines
  input CLK,              // Clock
  input LOAD_bar,         // Load on next +ve clock
  input ASSERT_MAIN_bar,  // Async assert to main bus
  input ASSERT_LHS_bar,   // Async assert to LHS bus
  input ASSERT_RHS_bar,   // Async assert to RHS bus

  // Input dats
  input [7:0] DATA_in,

  // Outputs
  output [7:0] MAIN_out,
  output [7:0] LHS_out,
  output [7:0] RHS_out,

  // Optionally, what we'd display in LEDs.
  output [7:0] display_value
);

wire [7:0] value;

assign display_value = value;

ttl_74377 register(
  .Enable_bar (LOAD_bar),
  .D          (DATA_in),
  .Clk        (CLK),
  .Q          (value)
);

ttl_74244 bus_out(
  .A1       (value[3:0]),
  .A2       (value[7:4]),
  .Y1       (MAIN_out[3:0]),
  .Y2       (MAIN_out[7:4]),
  .OE1_bar  (ASSERT_MAIN_bar),
  .OE2_bar  (ASSERT_MAIN_bar)
);

ttl_74244 lhs_bus_out(
  .A1       (value[3:0]),
  .A2       (value[7:4]),
  .Y1       (LHS_out[3:0]),
  .Y2       (LHS_out[7:4]),
  .OE1_bar  (ASSERT_LHS_bar),
  .OE2_bar  (ASSERT_LHS_bar)
);

ttl_74244 rhs_bus_out(
  .A1       (value[3:0]),
  .A2       (value[7:4]),
  .Y1       (RHS_out[3:0]),
  .Y2       (RHS_out[7:4]),
  .OE1_bar  (ASSERT_RHS_bar),
  .OE2_bar  (ASSERT_RHS_bar)
);

endmodule
