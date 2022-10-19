`include "tbhelper.v"

`TBPROLOGUE

wire HALT;

processor #(
  .DELAY_RISE(DELAY_RISE),
  .DELAY_FALL(DELAY_FALL)
) dut (
  .CLK(CLK),
  .HALT(HALT)
);

`TBBEGIN

  @(posedge HALT);
  $display("processor halted");
`TBEND
