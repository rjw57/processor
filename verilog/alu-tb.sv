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
  LHS = 8'hFF;
  RHS = 8'hFF;
  LHS_prev = 8'h00;
  RHS_prev = 8'h00;

  // Zero
  OPCODE = 4'h0;
  CARRY_IN = 1'b0;
  `TBDELAY(2)
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
        RESULT === 8'h00,
        $sformatf(
          "zero: got %0d",
          RESULT
        )
      );
    end
  end

  // Addition
  OPCODE = 4'h1;
  CARRY_IN = 1'b0;
  `TBDELAY(2)
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

  // Addition w/carry
  OPCODE = 4'h1;
  CARRY_IN = 1'b1;
  `TBDELAY(2)
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
        RESULT === (8'hFF & (1 + LHS_prev + RHS_prev)),
        $sformatf(
          "(1 + %0d + %0d) mod 256: expect %0d, got %0d",
          LHS_prev, RHS_prev, (8'hFF & (1 + LHS_prev + RHS_prev)), RESULT
        )
      );
    end
  end

  // Subtraction
  OPCODE = 4'h2;
  CARRY_IN = 1'b1;
  `TBDELAY(2)
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

  // Logical AND
  OPCODE = 4'h3;
  CARRY_IN = 1'b0;
  `TBDELAY(2)
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
        RESULT === (LHS_prev & RHS_prev),
        $sformatf(
          "%0d & %0d mod 256: expect %0d, got %0d",
          LHS_prev, RHS_prev, (LHS_prev & RHS_prev), RESULT
        )
      );
    end
  end

  // Logical OR
  OPCODE = 4'h4;
  CARRY_IN = 1'b0;
  `TBDELAY(2)
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
        RESULT === (LHS_prev | RHS_prev),
        $sformatf(
          "%0d | %0d: expect %0d, got %0d",
          LHS_prev, RHS_prev, (LHS_prev | RHS_prev), RESULT
        )
      );
    end
  end

  // Logical XOR
  OPCODE = 4'h5;
  CARRY_IN = 1'b0;
  `TBDELAY(2)
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
        RESULT === (LHS_prev ^ RHS_prev),
        $sformatf(
          "%0d ^ %0d: expect %0d, got %0d",
          LHS_prev, RHS_prev, (LHS_prev ^ RHS_prev), RESULT
        )
      );
    end
  end

  // ~RHS
  OPCODE = 4'h6;
  CARRY_IN = 1'b0;
  `TBDELAY(2)
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
        RESULT === ~RHS_prev,
        $sformatf(
          "~%0d: expect %0d, got %0d",
          RHS_prev, ~RHS_prev, RESULT
        )
      );
    end
  end

  // LHS << 1
  OPCODE = 4'h7;
  CARRY_IN = 1'b0;
  `TBDELAY(2)
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
        RESULT === {LHS_prev[6:0], 1'b0},
        $sformatf(
          "%0d << 1: expect %0d, got %0d",
          LHS_prev, {LHS_prev[6:0], 1'b0}, RESULT
        )
      );
    end
  end

  // LHS >> 1
  OPCODE = 4'h8;
  CARRY_IN = 1'b0;
  `TBDELAY(2)
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
        RESULT === {1'b0, LHS_prev[7:1]},
        $sformatf(
          "%0d >> 1: expect %0d, got %0d",
          LHS_prev, {1'b0, LHS_prev[7:1]}, RESULT
        )
      );
    end
  end

  // LHS ~>> 1
  OPCODE = 4'h9;
  CARRY_IN = 1'b0;
  `TBDELAY(2)
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
        RESULT === {LHS_prev[7], LHS_prev[7:1]},
        $sformatf(
          "%0d ~>> 1: expect %0d, got %0d",
          LHS_prev, {LHS_prev[7], LHS_prev[7:1]}, RESULT
        )
      );
    end
  end

  // LHS <<< 1
  OPCODE = 4'hA;
  CARRY_IN = 1'b0;
  `TBDELAY(2)
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
        RESULT === {LHS_prev[6:0], LHS_prev[7]},
        $sformatf(
          "%0d <<< 1: expect %0d, got %0d",
          LHS_prev, {LHS_prev[6:0], LHS_prev[7]}, RESULT
        )
      );
    end
  end

  // LHS >>> 1
  OPCODE = 4'hB;
  CARRY_IN = 1'b0;
  `TBDELAY(2)
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
        RESULT === {LHS_prev[0], LHS_prev[7:1]},
        $sformatf(
          "%0d >>> 1: expect %0d, got %0d",
          LHS_prev, {LHS_prev[0], LHS_prev[7:1]}, RESULT
        )
      );
    end
  end
`TBEND
