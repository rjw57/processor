
`include "tbhelper.v"

module test;

`TBSETUP

reg [14:0] A;
reg WE_bar, OE_bar, CS_bar;
wire [7:0] Q;

// Device under test
rom #(
  .ROM_CONTENTS ("../roms/popcount.mem"),
  .READ_DELAY(50)
) dut (
  .A(A),
  .WE_bar(WE_bar),
  .OE_bar(OE_bar),
  .CS_bar(CS_bar),
  .Q(Q)
);

initial
begin
  $dumpfile("rom-tb.vcd");
  $dumpvars;

  WE_bar = 1'b1;
  OE_bar = 1'b1;
  CS_bar = 1'b1;

#10
  A = 16'h0101;
  OE_bar = 1'b0;
  CS_bar = 1'b0;

#60
  `TBASSERT(Q === 8'h02, "basic read");

#10
  CS_bar = 1'b0;
  OE_bar = 1'b1;
#10
  `TBASSERT(Q === 8'bZ, "high-Z via OE");

#10
  CS_bar = 1'b1;
  OE_bar = 1'b0;
#10
  `TBASSERT(Q === 8'bZ, "high-Z via CS");

#10
  A = 16'h7FFF;
  WE_bar = 1'b1;
  OE_bar = 1'b0;
  CS_bar = 1'b0;

#10
  `TBASSERT(Q !== 8'h0F, "propagation delay");

#50
  `TBASSERT(Q === 8'h0F, "read from last byte");

  `TBDONE;
end

endmodule
