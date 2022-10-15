// 8-bit general purpose register with synchronous load and asynchronous assert.
//
//
// Uses 4 ICs == 1x74377, 3x74244
`include "74377.v"
`include "74244.v"

module gpreg(
  input CLK,
  input LOAD_bar,
  input ASSERT_bar,
  input ASSERT_LHS_bar,
  input ASSERT_RHS_bar,
  input [7:0] BUS_in,
  output [7:0] BUS_out,
  output [7:0] LHS_out,
  output [7:0] RHS_out,

  // Optionally, what we'd display in LEDs.
  output [7:0] display_value
);

wire [7:0] value;

assign display_value = value;

ttl_74377 register(
  .Enable_bar (LOAD_bar),
  .D          (BUS_in),
  .Clk        (CLK),
  .Q          (value)
);

ttl_74244 bus_out(
  .A1       (value[3:0]),
  .A2       (value[7:4]),
  .Y1       (BUS_out[3:0]),
  .Y2       (BUS_out[7:4]),
  .OE1_bar  (ASSERT_bar),
  .OE2_bar  (ASSERT_bar)
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
