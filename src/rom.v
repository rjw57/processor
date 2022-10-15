// ROM module
module rom 
#(
  parameter ROM_CONTENTS = "../roms/zeros.mem",
  ADDR_WIDTH = 15,
  DELAY_RISE = 0,
  DELAY_FALL = 0,
  READ_DELAY = 0
)
(
  input [ADDR_WIDTH-1:0] A,
  input WE_bar,
  input OE_bar,
  input CS_bar,
  output [7:0] Q
);

reg [7:0] Q_out;
reg [7:0] data[0:2**ADDR_WIDTH-1];

initial
begin
  $readmemh(ROM_CONTENTS, data);
end

assign #(DELAY_RISE, DELAY_FALL) Q = (~OE_bar & WE_bar * ~CS_bar) ? Q_out : 'bZ;

always @(A)
begin
  #READ_DELAY Q_out = data[A];
end

endmodule
