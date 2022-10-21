// 8-bit general purpose register with synchronous load and asynchronous assert.
//
//
// Uses 4 ICs == 1x74575, 3x74541

module gpreg #(parameter DELAY_RISE = 0, DELAY_FALL = 0)
(
  // Control lines
  input LOAD,             // Load on -ve going edge
  input CLEAR_bar,        // Synchronous clear
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
wire load_clk;
assign #(DELAY_RISE, DELAY_FALL) load_clk = !LOAD; // FIXME: could we remove the inverter?

ttl_74575 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) register(
  .Clear_bar  (CLEAR_bar),
  .Clk        (load_clk),
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
