// Test: register file
`include "tbhelper.v"

module test;

`TBSETUP
`TBCLK_WAIT_TICK_METHOD(wait_tick)

reg CLK;
reg RST_bar;
reg ADDR_ASSERT_bar, ADDR_LOAD_bar, ADDR_INC;
reg MAIN_ASSERT_bar, MAIN_LOAD_bar;
reg LHS_ASSERT_bar, RHS_ASSERT_bar;

reg [2:0] ADDR_INC_SEL;
reg [2:0] ADDR_ASSERT_SEL;
reg [2:0] ADDR_LOAD_SEL;
reg [2:0] MAIN_ASSERT_SEL;
reg [2:0] LHS_ASSERT_SEL;
reg [2:0] RHS_ASSERT_SEL;
reg [2:0] MAIN_LOAD_SEL;

reg [15:0] ADDR_in;
wire [15:0] ADDR_out;
reg [7:0] MAIN_in;
wire [7:0] MAIN_out;
reg [7:0] LHS_in;
wire [7:0] LHS_out;
reg [7:0] RHS_in;
wire [7:0] RHS_out;

// Device under test
registerfile dut(
  .CLK(CLK),
  .RST_bar(RST_bar),

  .ADDR_ASSERT_bar(ADDR_ASSERT_bar),
  .ADDR_LOAD_bar(ADDR_LOAD_bar),
  .ADDR_INC(ADDR_INC),
  .MAIN_ASSERT_bar(MAIN_ASSERT_bar),
  .MAIN_LOAD_bar(MAIN_LOAD_bar),
  .LHS_ASSERT_bar(LHS_ASSERT_bar),
  .RHS_ASSERT_bar(RHS_ASSERT_bar),

  .ADDR_INC_SEL(ADDR_INC_SEL),
  .ADDR_ASSERT_SEL(ADDR_ASSERT_SEL),
  .ADDR_LOAD_SEL(ADDR_LOAD_SEL),

  .MAIN_ASSERT_SEL(MAIN_ASSERT_SEL),
  .LHS_ASSERT_SEL(LHS_ASSERT_SEL),
  .RHS_ASSERT_SEL(RHS_ASSERT_SEL),

  .MAIN_LOAD_SEL(MAIN_LOAD_SEL),

  .ADDR_in(ADDR_in),
  .MAIN_in(MAIN_in),
  .LHS_in(LHS_in),
  .RHS_in(RHS_in),
  .ADDR_out(ADDR_out),
  .MAIN_out(MAIN_out),
  .LHS_out(LHS_out),
  .RHS_out(RHS_out)
);

// Set up a clock
initial CLK = 1'b0;
always #50 CLK = ~CLK;

initial
begin
  $dumpfile("gpreg-tb.vcd");
  $dumpvars;

  // Wait for the next clock and finish
  wait_tick();
  `TBDONE
end

endmodule
