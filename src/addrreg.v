// 16-bit address register with asynchronous reset, synchronous load and
// synchronous increment.
//
// Uses: 6 ICs == 4x74161, 2x74244

module addrreg
(
  input CLK,
  input RST_bar,
  input LOAD_bar,
  input INC,
  input ASSERT_bar,
  input [15:0] BUS_in,
  output [15:0] BUS_out,

  // Optionally, what we'd display in LEDs
  output [15:0] display_value
);

wire [15:0] value;
wire [3:0] rco;

assign display_value = value;

ttl_74244 line_driver0(
  .A1(value[3:0]),
  .OE1_bar(ASSERT_bar),
  .A2(value[7:4]),
  .OE2_bar(ASSERT_bar),
  .Y1(BUS_out[3:0]),
  .Y2(BUS_out[7:4])
);

ttl_74244 line_driver1(
  .A1(value[11:8]),
  .OE1_bar(ASSERT_bar),
  .A2(value[15:12]),
  .OE2_bar(ASSERT_bar),
  .Y1(BUS_out[11:8]),
  .Y2(BUS_out[15:12])
);

ttl_74161 reg0(
  .Clear_bar    (RST_bar),
  .Load_bar     (LOAD_bar),
  .ENT          (1'b1),
  .ENP          (INC),
  .D            (BUS_in[3:0]),
  .Clk          (CLK),
  .RCO          (rco[0]),
  .Q            (value[3:0])
);

ttl_74161 reg1(
  .Clear_bar    (RST_bar),
  .Load_bar     (LOAD_bar),
  .ENT          (rco[0]),
  .ENP          (1'b1),
  .D            (BUS_in[7:4]),
  .Clk          (CLK),
  .RCO          (rco[1]),
  .Q            (value[7:4])
);

ttl_74161 reg2(
  .Clear_bar    (RST_bar),
  .Load_bar     (LOAD_bar),
  .ENT          (rco[1]),
  .ENP          (1'b1),
  .D            (BUS_in[11:8]),
  .Clk          (CLK),
  .RCO          (rco[2]),
  .Q            (value[11:8])
);

ttl_74161 reg3(
  .Clear_bar    (RST_bar),
  .Load_bar     (LOAD_bar),
  .ENT          (rco[2]),
  .ENP          (1'b1),
  .D            (BUS_in[15:12]),
  .Clk          (CLK),
  .Q            (value[15:12])
);

endmodule
