// 16-bit address register with asynchronous reset, synchronous load and
// synchronous increment.
//
// Uses: 6 ICs == 4x74161, 2x74541

module addrreg #(parameter DELAY_RISE = 0, DELAY_FALL = 0)
(
  // Control lines
  input CLK,              // Clock
  input RST_bar,          // Asynchronous reset
  input LOAD_bar,         // Load on next +ve clock
  input INC,              // Increment on next +ve clock
  input ASSERT_bar,       // Assert to output

  // Bus connection
  input [15:0] BUS_in,
  output [15:0] BUS_out,

  // Optionally, what we'd display in LEDs
  output [15:0] display_value
);

wire [15:0] value;
wire [3:0] rco;

assign display_value = value;

ttl_74541 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) line_driver0 (
  .A(value[7:0]),
  .Enable1_bar(ASSERT_bar),
  .Enable2_bar(1'b0),
  .Y(BUS_out[7:0])
);

ttl_74541 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) line_driver1(
  .A(value[15:8]),
  .Enable1_bar(ASSERT_bar),
  .Enable2_bar(1'b0),
  .Y(BUS_out[15:8])
);

ttl_74161 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg0(
  .Clear_bar    (RST_bar),
  .Load_bar     (LOAD_bar),
  .ENT          (1'b1),
  .ENP          (INC),
  .D            (BUS_in[3:0]),
  .Clk          (CLK),
  .RCO          (rco[0]),
  .Q            (value[3:0])
);

ttl_74161 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg1(
  .Clear_bar    (RST_bar),
  .Load_bar     (LOAD_bar),
  .ENT          (rco[0]),
  .ENP          (1'b1),
  .D            (BUS_in[7:4]),
  .Clk          (CLK),
  .RCO          (rco[1]),
  .Q            (value[7:4])
);

ttl_74161 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg2(
  .Clear_bar    (RST_bar),
  .Load_bar     (LOAD_bar),
  .ENT          (rco[1]),
  .ENP          (1'b1),
  .D            (BUS_in[11:8]),
  .Clk          (CLK),
  .RCO          (rco[2]),
  .Q            (value[11:8])
);

ttl_74161 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg3(
  .Clear_bar    (RST_bar),
  .Load_bar     (LOAD_bar),
  .ENT          (rco[2]),
  .ENP          (1'b1),
  .D            (BUS_in[15:12]),
  .Clk          (CLK),
  .Q            (value[15:12])
);

endmodule
