module processor
#(
  parameter
  DELAY_RISE = 0,
  DELAY_FALL = 0
)
(
  input CLK,
  output HALT
);

reg halt;
assign HALT = halt;

initial
begin
  halt = 1'b0;
  #(400)
  halt = 1'b1;
end

endmodule
