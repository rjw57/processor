`include "tbhelper.v"

`TBPROLOGUE

reg [6:0] FLAGS;
reg CANCEL;
reg [7:0] PREV_STAGE_IN;
wire [7:0] NEXT_STAGE_OUT;
wire [15:0] CONTROL_OUT;

// Device under test
pipelinestage #(
  .DELAY_RISE(DELAY_RISE),
  .DELAY_FALL(DELAY_FALL),
  .A_CONTENTS("../roms/popcount.mem"),
  .B_CONTENTS("../roms/popcount.mem")
) dut (
  .CLK(CLK),
  .CANCEL(CANCEL),
  .FLAGS(FLAGS),
  .PREV_STAGE_IN(PREV_STAGE_IN),
  .NEXT_STAGE_OUT(NEXT_STAGE_OUT),
  .CONTROL_OUT(CONTROL_OUT)
);

`TBBEGIN
  CANCEL = 1'b0;
  PREV_STAGE_IN = 8'hab;
  FLAGS = 7'b0;

  `TBTICK
  PREV_STAGE_IN = 8'b01010101;

  `TBDELAY(2)
  `TBASSERT(NEXT_STAGE_OUT === 8'hab, "next opcode is latched");

  `TBDELAY(2)
  FLAGS = 7'b0001111;

  `TBTICK
  `TBDELAY(2)
  `TBASSERT(CONTROL_OUT === {8'd8, 8'd8}, "ROM outputs as expected");
`TBEND
