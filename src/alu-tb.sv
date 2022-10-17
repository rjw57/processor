`include "tbhelper.v"

`TBPROLOGUE

// Control lines
reg [1:0] SHIFT_OP;
reg [1:0] SHIFT_INTERP;
reg [3:0] LOGIC_OP;
reg CARRY_IN;

// Values
reg [7:0] LHS;
reg [7:0] RHS;

// previous tick values
reg [7:0] LHS_prev;
reg [7:0] RHS_prev;

// Results
wire [7:0] RESULT;
wire CARRY_OUT;

// Device under test.
alu #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) dut(
  .CLK(CLK),
  .LHS(LHS),
  .RHS(RHS),
  .SHIFT_OP(SHIFT_OP),
  .SHIFT_INTERP(SHIFT_INTERP),
  .LOGIC_OP(LOGIC_OP),
  .CARRY_IN(CARRY_IN),
  .RESULT(RESULT),
  .CARRY_OUT(CARRY_OUT)
);

integer i, j;

`TBBEGIN
  // Initial values
  LHS = 8'h00;
  RHS = 8'h00;
  LHS_prev = 8'h00;
  RHS_prev = 8'h00;

  // Addition
  SHIFT_OP = 2'b01;
  SHIFT_INTERP = 2'b00;
  LOGIC_OP = 4'b1010;
  CARRY_IN = 1'b0;
  `TBDELAY(2)

  LHS_prev <= LHS; RHS_prev <= RHS;
  LHS <= 8'h00; RHS <= 8'h00;
  `TBTICK

  for(i=0; i<256; i=i+37)
  begin
    for(j=0; j<256; j=j+47)
    begin
      LHS_prev <= LHS; RHS_prev <= RHS;
      LHS <= i; RHS <= j;

      `TBTICK
      `TBDELAY(2)

      `TBASSERT(
        RESULT === (8'hFF & (LHS_prev + RHS_prev)),
        $sformatf(
          "(%0d + %0d) mod 256: expect %0d, got %0d",
          LHS_prev, RHS_prev, (8'hFF & (LHS_prev + RHS_prev)), RESULT
        )
      );
    end
  end

  // Subtraction is addition with 2s complement of input
  SHIFT_OP = 2'b01;
  SHIFT_INTERP = 2'b00;
  LOGIC_OP = 4'b0101;
  CARRY_IN = 1'b1;
  `TBDELAY(2)

  LHS_prev <= LHS; RHS_prev <= RHS;
  LHS <= 8'h00; RHS <= 8'h00;
  `TBTICK

  for(i=0; i<256; i=i+37)
  begin
    for(j=0; j<256; j=j+47)
    begin
      LHS_prev <= LHS; RHS_prev <= RHS;
      LHS <= i; RHS <= j;

      `TBTICK
      `TBDELAY(2)

      `TBASSERT(
        RESULT === (8'hFF & (LHS_prev - RHS_prev)),
        $sformatf(
          "(%0d - %0d) mod 256: expect %0d, got %0d",
          LHS_prev, RHS_prev, (8'hFF & (LHS_prev - RHS_prev)), RESULT
        )
      );
    end
  end

  // TODO: other operations
`TBEND
