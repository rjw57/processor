// 8-bit general purpose register with synchronous load and asynchronous assert.
//
// Uses 4 ICs == 1x74574, 3x74541
//
// TODO: refactor as three 74574s latching the same data but asserting to the
// three buses.

module gpreg #(parameter DELAY_RISE = 0, DELAY_FALL = 0)
(
  // Control lines
  input LOAD,             // Load on +ve going edge
  input ASSERT_MAIN_bar,  // Async assert to main bus
  input ASSERT_LHS_bar,   // Async assert to LHS bus
  input ASSERT_RHS_bar,   // Async assert to RHS bus

  // Input data
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
wire reg_clk;
assign reg_clk = LOAD;

ttl_74574 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) register(
  .Clk        (reg_clk),
  .OE_bar     (1'b0),
  .D          (DATA_in),
  .Q          (value)
);

ttl_74541 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) main_bus_out(
  .A            (value),
  .Enable1_bar  (ASSERT_MAIN_bar),
  .Enable2_bar  (1'b0),
  .Y            (MAIN_out)
);

ttl_74541 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) lhs_bus_out(
  .A            (value),
  .Enable1_bar  (ASSERT_LHS_bar),
  .Enable2_bar  (1'b0),
  .Y            (LHS_out)
);

ttl_74541 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) rhs_bus_out(
  .A            (value),
  .Enable1_bar  (ASSERT_RHS_bar),
  .Enable2_bar  (1'b0),
  .Y            (RHS_out)
);

endmodule
