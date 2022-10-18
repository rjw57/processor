// Pipeline control stage
//
// Accepts opcode from previous stage and outputs control lines for opcode as
// well as latched opcode from prior stages.
module pipelinestage
#(
  parameter A_CONTENTS = "../roms/zeros.mem",
  parameter B_CONTENTS = "../roms/zeros.mem",
  ADDR_WIDTH = 15,
  DELAY_RISE = 0,
  DELAY_FALL = 0,
  READ_DELAY = 0
)
(
  input CLK,
  input [ADDR_WIDTH-9:0] FLAGS,
  input [7:0] PREV_STAGE_IN,
  output [7:0] NEXT_STAGE_OUT,
  output [15:0] CONTROL_OUT
);

reg [7:0] opcode_next;
wire [7:0] opcode = PREV_STAGE_IN;
wire [ADDR_WIDTH-9:0] flags = FLAGS;

assign NEXT_STAGE_OUT = opcode_next;

// opcode latch
ttl_74377 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) opcode_latch(
  .Enable_bar (1'b0),
  .D          (opcode),
  .Clk        (CLK),
  .Q          (opcode_next)
);

rom #(
  .DELAY_RISE(DELAY_RISE),
  .DELAY_FALL(DELAY_FALL),
  .READ_DELAY(READ_DELAY),
  .ADDR_WIDTH(ADDR_WIDTH),
  .ROM_CONTENTS(A_CONTENTS)
) rom_a (
  .WE_bar(1'b1),
  .OE_bar(1'b0),
  .CS_bar(1'b0),
  .A({flags, opcode}),
  .Q(CONTROL_OUT[7:0])
);

rom #(
  .DELAY_RISE(DELAY_RISE),
  .DELAY_FALL(DELAY_FALL),
  .READ_DELAY(READ_DELAY),
  .ADDR_WIDTH(ADDR_WIDTH),
  .ROM_CONTENTS(B_CONTENTS)
) rom_b (
  .WE_bar(1'b1),
  .OE_bar(1'b0),
  .CS_bar(1'b0),
  .A({flags, opcode}),
  .Q(CONTROL_OUT[15:8])
);

endmodule
