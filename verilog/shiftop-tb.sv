`include "tbhelper.v"

`TBPROLOGUE

reg [1:0] OP_SEL;
reg [1:0] INTERP_SEL;
reg [7:0] VALUE_IN;
wire [7:0] VALUE_OUT;
reg expected_interp;

// Device under test.
shiftop #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) dut(
  .OP_SEL(OP_SEL),
  .INTERP_SEL(INTERP_SEL),
  .VALUE_IN(VALUE_IN),
  .VALUE_OUT(VALUE_OUT)
);

integer i, j;

`TBBEGIN

  // Iniitial state
  OP_SEL = 2'b00;
  VALUE_IN = 8'h00;

  `TBTICK
  `TBDELAY(2)
  `TBASSERT(VALUE_OUT === 8'h00, "pass through zeros");

  for(j=0; j<4; j=j+1)
  begin
    `TBDELAY(2)
    INTERP_SEL = j;

    // zero
    for(i=0; i<256; i=i+1)
    begin
      `TBDELAY(2)
      VALUE_IN = i;
      OP_SEL = 2'b00; // zero
      `TBDELAY(2)
      `TBASSERT(VALUE_OUT === 8'b0, $sformatf("correct zero for val 8'h%0h", i));
    end

    // pass through
    for(i=0; i<256; i=i+1)
    begin
      `TBDELAY(2)
      VALUE_IN = i;
      OP_SEL = 2'b01; // pass through
      `TBDELAY(2)
      `TBASSERT(VALUE_OUT === VALUE_IN, $sformatf("correct pass through for val 8'h%0h", i));
    end

    // shift up
    for(i=0; i<256; i=i+1)
    begin
      `TBDELAY(2)
      VALUE_IN = i;
      OP_SEL = 2'b10; // shift up

      `TBDELAY(2)
      case(j)
        0: expected_interp = 1'b0;
        1: expected_interp = 1'b1;
        2: expected_interp = VALUE_IN[0];
        3: expected_interp = VALUE_IN[7];
        default: $display("unexpected interp: ", j);
      endcase

      `TBDELAY(2)
      `TBASSERT(
        VALUE_OUT === {VALUE_IN[6:0], expected_interp},
        $sformatf(
          "correct shift up for interp sel %0h val 8'b%b: 8'b%b (expected 8'b%b)",
          INTERP_SEL, VALUE_IN, VALUE_OUT, {VALUE_IN[6:0], expected_interp}
        )
      );
    end

    // shift down
    for(i=0; i<256; i=i+1)
    begin
      `TBDELAY(2)
      VALUE_IN = i;
      OP_SEL = 2'b11; // shift down

      `TBDELAY(2)
      case(j)
        0: expected_interp = 1'b0;
        1: expected_interp = 1'b1;
        2: expected_interp = VALUE_IN[0];
        3: expected_interp = VALUE_IN[7];
        default: $display("unexpected interp: ", j);
      endcase

      `TBDELAY(2)
      `TBASSERT(
        VALUE_OUT === {expected_interp, VALUE_IN[7:1]},
        $sformatf(
          "correct shift up for interp sel %0h val 8'b%b: 8'b%b (expected 8'b%b)",
          INTERP_SEL, VALUE_IN, VALUE_OUT, {VALUE_IN[6:0], expected_interp}
        )
      );
    end
  end

`TBEND
