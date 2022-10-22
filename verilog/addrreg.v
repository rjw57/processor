// 16-bit address register with asynchronous reset, synchronous load and
// synchronous increment.
//
// Uses: 6 ICs == 4x74161, 2x74541

module addrreg #(parameter DELAY_RISE = 0, DELAY_FALL = 0)
(
  // Control lines
  input RST,              // Asynchronous reset
  input INC,              // +ve going edge decrements
  input DEC,              // +ve going edge increments
  input LOAD_bar,         // asynchronous load
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

wire up_clk, down_clk;
assign up_clk = INC;
assign down_clk = DEC;

wire [2:0] tcu;
wire [2:0] tcd;

ttl_74193 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) counter_1(
  .MR(RST),
  .CPU(up_clk),
  .CPD(down_clk),
  .PL_bar(LOAD_bar),
  .D(BUS_in[3:0]),
  .Q(value[3:0]),
  .TCU_bar(tcu[0]),
  .TCD_bar(tcd[0])
);

ttl_74193 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) counter_2(
  .MR(RST),
  .CPU(tcu[0]),
  .CPD(tcd[0]),
  .PL_bar(LOAD_bar),
  .D(BUS_in[7:4]),
  .Q(value[7:4]),
  .TCU_bar(tcu[1]),
  .TCD_bar(tcd[1])
);

ttl_74193 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) counter_3(
  .MR(RST),
  .CPU(tcu[1]),
  .CPD(tcd[1]),
  .PL_bar(LOAD_bar),
  .D(BUS_in[11:8]),
  .Q(value[11:8]),
  .TCU_bar(tcu[2]),
  .TCD_bar(tcd[2])
);

ttl_74193 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) counter_4(
  .MR(RST),
  .CPU(tcu[2]),
  .CPD(tcd[2]),
  .PL_bar(LOAD_bar),
  .D(BUS_in[15:12]),
  .Q(value[15:12])
);

endmodule
