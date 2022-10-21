// Octal D transparent latch with load enable

module ttl_74573 #(parameter WIDTH = 8, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input LE,
  input OE_bar,
  input [WIDTH-1:0] D,
  output [WIDTH-1:0] Q
);

//------------------------------------------------//
reg [WIDTH-1:0] Q_current;

always @(D)
begin
  if (LE)
    Q_current <= D;
end

//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Q = OE_bar ? {(WIDTH){1'bZ}} : Q_current;

endmodule
