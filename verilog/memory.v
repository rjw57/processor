module memory
#(
  parameter
  DELAY_RISE = 0,
  DELAY_FALL = 0,
  ROM_CONTENTS = "../rom/zeros.mem",
  ROM_READ_DELAY = 0,
  RAM_READ_DELAY = 0,
  RAM_WRITE_DELAY = 0
)
(
  input [15:0] ADDR_IN,
  input [7:0] DATA_IN,
  input WE_bar,
  input OE_bar,
  output [7:0] DATA_OUT
);

wire [7:0] cs;
wire [7:0] rom_out;
wire [7:0] ram_out;

// Address decode

ttl_74138 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) addr_decode (
  .Enable1_bar(1'b0),
  .Enable2_bar(1'b0),
  .Enable3(1'b1),
  .A({2'b0, ADDR_IN[15]}),
  .Y(cs)
);

rom #(
  .ROM_CONTENTS(ROM_CONTENTS),
  .READ_DELAY(ROM_READ_DELAY),
  .DELAY_RISE(DELAY_RISE),
  .DELAY_FALL(DELAY_FALL)
) rom (
  .A(ADDR_IN[14:0]),
  .WE_bar(1'b1),
  .OE_bar(OE_bar),
  .CS_bar(cs[0]),
  .Q(rom_out)
);

ram #(
  .READ_DELAY(RAM_READ_DELAY),
  .WRITE_DELAY(RAM_WRITE_DELAY),
  .DELAY_RISE(DELAY_RISE),
  .DELAY_FALL(DELAY_FALL)
) ram (
  .A(ADDR_IN[14:0]),
  .WE_bar(WE_bar),
  .OE_bar(OE_bar),
  .CS_bar(cs[1]),
  .D(DATA_IN),
  .Q(ram_out)
);

wire [7:0] data_out_stages [0:2];
assign data_out_stages[0] = 8'bZ;
assign data_out_stages[1] = cs[0] ? data_out_stages[0] : rom_out;
assign data_out_stages[2] = cs[1] ? data_out_stages[1] : ram_out;
assign DATA_OUT = data_out_stages[2];

endmodule
