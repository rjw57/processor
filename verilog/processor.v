module processor
#(
  parameter
  DELAY_RISE = 0,
  DELAY_FALL = 0,
  ROM_READ_DELAY = 0,
  RAM_READ_DELAY = 0,
  RAM_WRITE_DELAY = 0
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
