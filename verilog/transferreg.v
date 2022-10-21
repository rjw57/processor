// Transfer register
//
// Like with gpreg, load happens at the -ve going edges of the load lines.
module transferreg #(
  parameter
  DELAY_RISE = 0,
  DELAY_FALL = 0
)(
  input LOAD_LOW,
  input LOAD_HIGH,
  input LOAD_SELECT, // 1 == main bus, 0 == address bus

  // 8-bit side access
  input ASSERT_LOW_bar,
  input ASSERT_HIGH_bar,

  // 16-bit side access
  input ASSERT_ADDR_bar,

  input [7:0] MAIN_in,
  input [15:0] ADDR_in,

  output [7:0] MAIN_out,
  output [15:0] ADDR_out,

  output [15:0] display_value
);

wire load_low;
wire [7:0] low_in;
wire [7:0] low_out;

wire load_high;
wire [7:0] high_in;
wire [7:0] high_out;

// Requires 2 inverters
assign #(DELAY_RISE, DELAY_FALL) load_low = !LOAD_LOW;
assign #(DELAY_RISE, DELAY_FALL) load_high = !LOAD_HIGH;

// Input select
ttl_74157 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) input_select_1 (
  .Enable_bar(1'b0),
  .Select(LOAD_SELECT),
  .A_2D({
    {MAIN_in[3], ADDR_in[3]},
    {MAIN_in[2], ADDR_in[2]},
    {MAIN_in[1], ADDR_in[1]},
    {MAIN_in[0], ADDR_in[0]}
  }),
  .Y(low_in[3:0])
);
ttl_74157 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) input_select_2 (
  .Enable_bar(1'b0),
  .Select(LOAD_SELECT),
  .A_2D({
    {MAIN_in[7], ADDR_in[7]},
    {MAIN_in[6], ADDR_in[6]},
    {MAIN_in[5], ADDR_in[5]},
    {MAIN_in[4], ADDR_in[4]}
  }),
  .Y(low_in[7:4])
);
ttl_74157 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) input_select_3 (
  .Enable_bar(1'b0),
  .Select(LOAD_SELECT),
  .A_2D({
    {MAIN_in[3], ADDR_in[11]},
    {MAIN_in[2], ADDR_in[10]},
    {MAIN_in[1], ADDR_in[9]},
    {MAIN_in[0], ADDR_in[8]}
  }),
  .Y(high_in[3:0])
);
ttl_74157 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) input_select_4 (
  .Enable_bar(1'b0),
  .Select(LOAD_SELECT),
  .A_2D({
    {MAIN_in[7], ADDR_in[15]},
    {MAIN_in[6], ADDR_in[14]},
    {MAIN_in[5], ADDR_in[13]},
    {MAIN_in[4], ADDR_in[12]}
  }),
  .Y(high_in[7:4])
);

// The base registers are 74574s
ttl_74574 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg_low(
  .Clk        (load_low),
  .OE_bar     (1'b0),
  .D          (low_in),
  .Q          (low_out)
);

// The base registers are 74574s
ttl_74574 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg_high(
  .Clk        (load_high),
  .OE_bar     (1'b0),
  .D          (high_in),
  .Q          (high_out)
);

// 74541 line drivers for output buses
wire [7:0] low_main_out;
ttl_74541 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) low_main_driver(
  .A            (low_out),
  .Enable1_bar  (ASSERT_LOW_bar),
  .Enable2_bar  (1'b0),
  .Y            (low_main_out)
);

wire [7:0] high_main_out;
ttl_74541 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) high_main_driver(
  .A            (high_out),
  .Enable1_bar  (ASSERT_HIGH_bar),
  .Enable2_bar  (1'b0),
  .Y            (high_main_out)
);

wire [15:0] addr_out;
ttl_74541 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) addr_driver_1(
  .A            (low_out),
  .Enable1_bar  (ASSERT_ADDR_bar),
  .Enable2_bar  (1'b0),
  .Y            (addr_out[7:0])
);
ttl_74541 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) addr_driver_2(
  .A            (high_out),
  .Enable1_bar  (ASSERT_ADDR_bar),
  .Enable2_bar  (1'b0),
  .Y            (addr_out[15:8])
);

assign ADDR_out = addr_out;

// Multiplex to simulate high-Z multiple drivers for main output.
wire [7:0] main_out_stages [0:2];
assign main_out_stages[0] = 8'hZZ;
assign main_out_stages[1] = ASSERT_LOW_bar ? main_out_stages[0] : low_main_out;
assign main_out_stages[2] = ASSERT_HIGH_bar ? main_out_stages[1] : high_main_out;
assign MAIN_out = main_out_stages[2];

endmodule
