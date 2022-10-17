`include "tbhelper.v"

`TBPROLOGUE

// Control lines
reg [1:0] SHIFT_OP;
reg [1:0] SHIFT_INTERP;
reg [3:0] LOGIC_OP;
reg [1:0] CARRY_SEL;

// Values
reg [7:0] LHS;
reg [7:0] RHS;

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
  .CARRY_SEL(CARRY_SEL),
  .RESULT(RESULT),
  .CARRY_OUT(CARRY_OUT)
);

`TBBEGIN
  // Initial values
  LHS = 8'h00;
  RHS = 8'h00;
  SHIFT_OP = 2'b00;
  SHIFT_INTERP = 2'b00;
  LOGIC_OP = 4'b0000;
  CARRY_SEL = 2'b00;
`TBEND

