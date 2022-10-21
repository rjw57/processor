// octal D-type edge-triggered flip-flop

module ttl_74574 #(parameter WIDTH = 8, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input OE_bar,
  input [WIDTH-1:0] D,
  input Clk,
  output [WIDTH-1:0] Q
);

//------------------------------------------------//
reg [WIDTH-1:0] Q_current;

always @(posedge Clk)
begin
  Q_current <= D;
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Q = OE_bar ? {(WIDTH){1'bZ}} : Q_current;

endmodule
