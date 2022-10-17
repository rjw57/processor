`include "tbhelper.v"

`TBPROLOGUE

// Control lines
reg [3:0] OPCODE;
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
  .OPCODE(OPCODE),
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
  OPCODE = 2'b00;
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

  // Subtraction
  OPCODE = 2'b01;
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
