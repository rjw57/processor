`include "tbhelper.v"

`TBPROLOGUE

localparam RAM_READ_DELAY = 45, RAM_WRITE_DELAY = 45;

reg [14:0] A;
reg WE_bar, OE_bar, CS_bar;
wire [7:0] Q;
reg [7:0] D;

// Device under test
ram #(
  .READ_DELAY (RAM_READ_DELAY),
  .WRITE_DELAY (RAM_WRITE_DELAY)
) dut (
  .A(A),
  .WE_bar(WE_bar),
  .OE_bar(OE_bar),
  .CS_bar(CS_bar),
  .D(D),
  .Q(Q)
);

`TBBEGIN
  WE_bar = 1'b1;
  OE_bar = 1'b1;
  CS_bar = 1'b1;

  `TBDELAY(2)
  A = 16'h0101;
  D = 8'h8A;

  CS_bar = 1'b0;
  WE_bar = 1'b0;
  #(RAM_WRITE_DELAY)
  WE_bar = 1'b1;

  `TBDELAY(2)
  A = 16'h1010;
  D = 8'hA8;

  WE_bar = 1'b0;
  #(RAM_WRITE_DELAY)
  WE_bar = 1'b1;

  `TBDELAY(2)
  A = 16'h0101;
  OE_bar = 1'b0;
  #(RAM_READ_DELAY)
  `TBDELAY(2)
  `TBASSERT(Q === 8'h8A, "basic read");

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
  A = 16'h1010;
  WE_bar = 1'b1;
  OE_bar = 1'b0;
  CS_bar = 1'b0;

  `TBDELAY(2)
  `TBASSERT(Q !== 8'hA8, "propagation delay");

  #RAM_READ_DELAY
  `TBASSERT(Q === 8'hA8, "read");
`TBEND

