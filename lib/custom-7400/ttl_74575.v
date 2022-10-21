// octal D-type edge-triggered flip-flop, synchronous clear

module ttl_74575 #(parameter WIDTH = 8, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input Clear_bar,
  input OE_bar,
  input [WIDTH-1:0] D,
  input Clk,
  output [WIDTH-1:0] Q
);

//------------------------------------------------//
reg [WIDTH-1:0] Q_current;

always @(posedge Clk)
begin
  Q_current <= Clear_bar ? D : {(WIDTH){1'b0}};
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Q = Q_current;

endmodule

