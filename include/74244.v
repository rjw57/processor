// Octal buffer/line-driver with three-state outputs.

module ttl_74244
(
  input [3:0] A1,
  input OE1_bar,
  input [3:0] A2,
  input OE2_bar,
  output [3:0] Y1,
  output [3:0] Y2
);

assign Y1 = OE1_bar ? 4'bZ : A1;
assign Y2 = OE2_bar ? 4'bZ : A2;

endmodule
