// 8-bit general purpose register with synchronous load and asynchronous assert.
//
//
// Uses 4 ICs == 1x74377, 3x74541

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

ttl_74541 main_us_out(
  .A            (value),
  .Enable1_bar  (ASSERT_MAIN_bar),
  .Enable2_bar  (1'b0),
  .Y            (MAIN_out)
);

ttl_74541 lhs_us_out(
  .A            (value),
  .Enable1_bar  (ASSERT_LHS_bar),
  .Enable2_bar  (1'b0),
  .Y            (LHS_out)
);

ttl_74541 rhs_us_out(
  .A            (value),
  .Enable1_bar  (ASSERT_RHS_bar),
  .Enable2_bar  (1'b0),
  .Y            (RHS_out)
);

endmodule
