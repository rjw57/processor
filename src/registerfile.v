// All registers contained in the processor.

// TODO: have a better think about the control lines. Perhaps have unified
// register file and register select, load, increment and main/addr/lhs/rhs
// assert lines? == 10 lines
module registerfile (
  input CLK,

  // Address register reset
  input RST_bar,

  // Master assert, increment and load enables
  input ADDR_ASSERT_bar,
  input ADDR_LOAD_bar,
  input ADDR_INC,
  input MAIN_ASSERT_bar,
  input MAIN_LOAD_bar,
  input LHS_ASSERT_bar,
  input RHS_ASSERT_bar,

  // 16-bit register increment select
  input [2:0] ADDR_INC_SEL,

  // 16-bit register assert select
  input [2:0] ADDR_ASSERT_SEL,

  // 16-bit register load select
  input [2:0] ADDR_LOAD_SEL,

  // 8-bit register assert selects
  input [2:0] MAIN_ASSERT_SEL,
  input [2:0] LHS_ASSERT_SEL,
  input [2:0] RHS_ASSERT_SEL,

  // 8-bit register load select
  input [2:0] MAIN_LOAD_SEL,

  // 8-bit busses
  input [7:0] MAIN_in,
  input [7:0] LHS_in,
  input [7:0] RHS_in,
  output [7:0] MAIN_out,
  output [7:0] LHS_out,
  output [7:0] RHS_out,

  // 16-bit busses
  input [15:0] ADDR_in,
  output [15:0] ADDR_out
);

wire [7:0] addr_load_vec_bar;
wire [7:0] main_load_vec_bar;
wire [7:0] addr_assert_vec_bar;
wire [7:0] main_assert_vec_bar;
wire [7:0] lhs_assert_vec_bar;
wire [7:0] rhs_assert_vec_bar;
wire [7:0] addr_inc_vec;

ttl_74138 main_assert(
  .Enable1_bar  (MAIN_ASSERT_bar),
  .Enable2_bar  (1'b0),
  .Enable3      (1'b1),
  .A            (MAIN_ASSERT_SEL),
  .Y            (main_assert_vec_bar)
);

ttl_74138 lhs_assert(
  .Enable1_bar  (LHS_ASSERT_bar),
  .Enable2_bar  (1'b0),
  .Enable3      (1'b1),
  .A            (LHS_ASSERT_SEL),
  .Y            (lhs_assert_vec_bar)
);

ttl_74138 rhs_assert(
  .Enable1_bar  (RHS_ASSERT_bar),
  .Enable2_bar  (1'b0),
  .Enable3      (1'b1),
  .A            (RHS_ASSERT_SEL),
  .Y            (rhs_assert_vec_bar)
);

ttl_74138 addr_assert(
  .Enable1_bar  (ADDR_ASSERT_bar),
  .Enable2_bar  (1'b0),
  .Enable3      (1'b1),
  .A            (ADDR_ASSERT_SEL),
  .Y            (addr_assert_vec_bar)
);

ttl_74138 main_load(
  .Enable1_bar  (MAIN_LOAD_bar),
  .Enable2_bar  (1'b0),
  .Enable3      (1'b1),
  .A            (MAIN_LOAD_SEL),
  .Y            (main_load_vec_bar)
);

ttl_74138 addr_load(
  .Enable1_bar  (ADDR_LOAD_bar),
  .Enable2_bar  (1'b0),
  .Enable3      (1'b1),
  .A            (ADDR_LOAD_SEL),
  .Y            (addr_load_vec_bar)
);

ttl_74138 addr_inc(
  .Enable1_bar  (1'b0),
  .Enable2_bar  (1'b0),
  .Enable3      (ADDR_INC),
  .A            (ADDR_INC_SEL),
  .Y            (addr_inc_vec)
);

genvar i;

// 4 general purpose registers
generate
  for (i=0; i<4; i=i+1) begin
    gpreg gpreg(
      .CLK              (CLK),
      .LOAD_bar         (main_load_vec_bar[i]),
      .ASSERT_bar       (main_assert_vec_bar[i]),
      .ASSERT_LHS_bar   (lhs_assert_vec_bar[i]),
      .ASSERT_RHS_bar   (rhs_assert_vec_bar[i]),
      .BUS_in           (MAIN_in),
      .BUS_out          (MAIN_out),
      .LHS_out          (LHS_out),
      .RHS_out          (RHS_out)
    );
  end
endgenerate

// 4 address registers
generate
  for (i=0; i<4; i=i+1) begin
    addrreg addrreg(
      .CLK              (CLK),
      .RST_bar          (RST_bar),
      .LOAD_bar         (addr_load_vec_bar[i]),
      .INC              (addr_inc_vec[i]),
      .ASSERT_bar       (addr_assert_vec_bar[i]),
      .BUS_in           (ADDR_in),
      .BUS_out          (ADDR_out)
    );
  end
endgenerate

endmodule
