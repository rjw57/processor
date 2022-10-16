
`include "tbhelper.v"

`TBPROLOGUE

localparam ROM_READ_DELAY = 150;

reg [14:0] A;
reg WE_bar, OE_bar, CS_bar;
wire [7:0] Q;

// Device under test
rom #(
  .ROM_CONTENTS ("../roms/popcount.mem"),
  .READ_DELAY (ROM_READ_DELAY)
) dut (
  .A(A),
  .WE_bar(WE_bar),
  .OE_bar(OE_bar),
  .CS_bar(CS_bar),
  .Q(Q)
);

`TBBEGIN
  WE_bar = 1'b1;
  OE_bar = 1'b1;
  CS_bar = 1'b1;

  `TBDELAY(2)
  A = 16'h0101;
  OE_bar = 1'b0;
  CS_bar = 1'b0;

  #(ROM_READ_DELAY)
  `TBDELAY(2)
  `TBASSERT(Q === 8'h02, "basic read");

  `TBDELAY(2)
  CS_bar = 1'b0;
  OE_bar = 1'b1;
  `TBDELAY(2)
  `TBASSERT(Q === 8'bZ, "high-Z via OE");

  `TBDELAY(2)
  CS_bar = 1'b1;
  OE_bar = 1'b0;
  `TBDELAY(2)
  `TBASSERT(Q === 8'bZ, "high-Z via CS");

  `TBDELAY(2)
  A = 16'h7FFF;
  WE_bar = 1'b1;
  OE_bar = 1'b0;
  CS_bar = 1'b0;

  `TBDELAY(2)
  `TBASSERT(Q !== 8'h0F, "propagation delay");

  #ROM_READ_DELAY
  `TBASSERT(Q === 8'h0F, "read from last byte");
`TBEND
