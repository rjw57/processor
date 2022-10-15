// Octal buffer/line-driver with three-state outputs.

module ttl_74541 #(parameter DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [7:0] A,
  input Enable1_bar,
  input Enable2_bar,
  output [7:0] Y
);

assign #(DELAY_RISE, DELAY_FALL) Y = (Enable1_bar | Enable2_bar) ? 8'bZ : A;

endmodule

