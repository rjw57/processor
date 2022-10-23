// RAM module
module ram
#(
  parameter
  ADDR_WIDTH = 15,
  DELAY_RISE = 0,
  DELAY_FALL = 0,
  READ_DELAY = 0,
  WRITE_DELAY = 0
)
(
  input [ADDR_WIDTH-1:0] A,
  input WE_bar,
  input OE_bar,
  input CS_bar,
  input [7:0] D,
  output [7:0] Q
);

reg [7:0] Q_out;
reg [7:0] data[0:2**ADDR_WIDTH-1];

assign #(DELAY_RISE, DELAY_FALL) Q = (~OE_bar & WE_bar * ~CS_bar) ? Q_out : 'bZ;

integer i;
initial
begin
  // Initialise RAM contents to junk data. This is just to avoid Xs propagating
  // though the output which wouldn't happen in real hardware.
  for(i=0; i<2**ADDR_WIDTH; i=i+1)
  begin
    data[i] = ~i;
  end
end

always @(A)
begin
  #READ_DELAY Q_out = data[A];
end

always @(WE_bar or OE_bar or CS_bar or D)
begin
  if(~WE_bar & OE_bar & ~CS_bar)
  begin
    #WRITE_DELAY data[A] = D;
  end
end

endmodule
