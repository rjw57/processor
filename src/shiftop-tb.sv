// Test: general purpose register
`include "tbhelper.v"

`TBPROLOGUE

reg [1:0] OP_SEL;
reg [7:0] VALUE_IN;
wire [7:0] VALUE_OUT;
wire CARRY_OUT;

// Device under test.
shiftop #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) dut(
  .OP_SEL(OP_SEL),
  .VALUE_IN(VALUE_IN),
  .VALUE_OUT(VALUE_OUT),
  .CARRY_OUT(CARRY_OUT)
);

integer i;

`TBBEGIN

  // Iniitial state
  OP_SEL = 2'b00;
  VALUE_IN = 8'h00;

  `TBTICK
  `TBDELAY(2)
  `TBASSERT(VALUE_OUT === 8'h00, "pass through zeros");

  // zero
  for(i=0; i<256; i=i+37)
  begin
    `TBDELAY(2)
    VALUE_IN = i;
    OP_SEL = 2'b00; // zero
    `TBDELAY(2)
    `TBASSERT(VALUE_OUT === 8'b0, $sformatf("correct zero for val 8'h%0h", i));
    `TBASSERT(CARRY_OUT === 1'b0, $sformatf("correct zero carry for val 8'h%0h", i));
  end

  // pass through
  for(i=0; i<256; i=i+37)
  begin
    `TBDELAY(2)
    VALUE_IN = i;
    OP_SEL = 2'b01; // pass through
    `TBDELAY(2)
    `TBASSERT(VALUE_OUT === VALUE_IN, $sformatf("correct pass through for val 8'h%0h", i));
    `TBASSERT(CARRY_OUT === 1'b0, $sformatf("correct pass through carry for val 8'h%0h", i));
  end

  // shift up
  for(i=0; i<256; i=i+37)
  begin
    `TBDELAY(2)
    VALUE_IN = i;
    OP_SEL = 2'b10; // shift up
    `TBDELAY(2)
    `TBASSERT(VALUE_OUT === {VALUE_IN[6:0], 1'b0}, $sformatf("correct shift up for val 8'h%0h", i));
    `TBASSERT(CARRY_OUT === VALUE_IN[7], $sformatf("correct shift up carry for val 8'h%0h", i));
  end

  // shift down
  for(i=0; i<256; i=i+37)
  begin
    `TBDELAY(2)
    VALUE_IN = i;
    OP_SEL = 2'b11; // shift down
    `TBDELAY(2)
    `TBASSERT(VALUE_OUT === {1'b0, VALUE_IN[7:1]}, $sformatf("correct shift down for val 8'h%0h", i));
    `TBASSERT(CARRY_OUT === VALUE_IN[0], $sformatf("correct shift down carry for val 8'h%0h", i));
  end

`TBEND
