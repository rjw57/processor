`include "tbhelper.v"

`TBPROLOGUE

reg [7:0] LHS;
reg [7:0] RHS;
reg CARRY_IN;
wire [7:0] RESULT;
wire CARRY_OUT;

// Device under test.
adder #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) dut(
  .LHS(LHS),
  .RHS(RHS),
  .CARRY_IN(CARRY_IN),
  .RESULT(RESULT),
  .CARRY_OUT(CARRY_OUT)
);

integer i, j, k;

`TBBEGIN
  // initiail state
  LHS = 8'd13;
  RHS = 8'd100;
  CARRY_IN = 1'b0;

  `define TEST(LHS_VAL, RHS_VAL, CARRY_VAL) \
    `TBDELAY(4) \
    LHS = (LHS_VAL); \
    RHS = (RHS_VAL); \
    CARRY_IN = (CARRY_VAL); \
    `TBDELAY(4) \
    `TBASSERT( \
      RESULT === (8'hFF & ((LHS_VAL) + (RHS_VAL) + (CARRY_VAL))), \
      $sformatf( \
        "(%0d + %0d + %0d) mod 256 == %0d", \
        LHS_VAL, RHS_VAL, CARRY_VAL, ((LHS_VAL) + (RHS_VAL) + (CARRY_VAL)) \
      ) \
    ); \
    `TBASSERT( \
      CARRY_OUT === (((LHS_VAL) + (RHS_VAL) + (CARRY_VAL)) >> 8), \
      $sformatf( \
        "carry out of %0d + %0d + %0d is %0d", \
        LHS_VAL, RHS_VAL, CARRY_VAL, \
        ((LHS_VAL) + (RHS_VAL) + (CARRY_VAL)) >> 8 \
      ) \
    );

  for (i=0; i<256; i=i+3)
  for (j=0; j<256; j=j+7)
  for (k=0; k<2; k=k+1)
  begin
    `TEST(i, j, k);
  end
`TBEND
