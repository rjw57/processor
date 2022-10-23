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
  input CANCEL, // bring high to set NEXT_STAGE_OUT to NOP
  input [ADDR_WIDTH-9:0] FLAGS,
  input [7:0] PREV_STAGE_IN,
  output [7:0] NEXT_STAGE_OUT,
  output [15:0] CONTROL_OUT
);

reg [7:0] opcode_next;
wire [7:0] opcode = PREV_STAGE_IN;
wire [ADDR_WIDTH-9:0] flags = FLAGS;
wire [7:0] rom_a_out;
wire [7:0] rom_b_out;

// in hardware we're implement this by a pull-down resistor network since the
// latch will go high-Z
assign NEXT_STAGE_OUT = (opcode_next === 8'hZZ) ? 8'h00 : opcode_next;

// opcode latch
ttl_74377 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) opcode_latch(
  .Enable_bar (CANCEL),
  .D          (opcode),
  .Clk        (CLK),
  .Q          (opcode_next)
);

// control line latches with pull downs on input
ttl_74377 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) ctrl_1_latch(
  .Enable_bar (1'b0),
  .D          ((rom_a_out === 8'hZZ) ? 8'h00 : rom_a_out),
  .Clk        (CLK),
  .Q          (CONTROL_OUT[7:0])
);

ttl_74377 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) ctrl_2_latch(
  .Enable_bar (1'b0),
  .D          ((rom_b_out === 8'hZZ) ? 8'h00 : rom_b_out),
  .Clk        (CLK),
  .Q          (CONTROL_OUT[15:8])
);

rom #(
  .DELAY_RISE(DELAY_RISE),
  .DELAY_FALL(DELAY_FALL),
  .READ_DELAY(READ_DELAY),
  .ADDR_WIDTH(ADDR_WIDTH),
  .ROM_CONTENTS(A_CONTENTS)
) rom_a (
  .WE_bar(1'b1),
  .OE_bar(CANCEL),
  .CS_bar(1'b0),
  .A({flags, opcode}),
  .Q(rom_a_out)
);

rom #(
  .DELAY_RISE(DELAY_RISE),
  .DELAY_FALL(DELAY_FALL),
  .READ_DELAY(READ_DELAY),
  .ADDR_WIDTH(ADDR_WIDTH),
  .ROM_CONTENTS(B_CONTENTS)
) rom_b (
  .WE_bar(1'b1),
  .OE_bar(CANCEL),
  .CS_bar(1'b0),
  .A({flags, opcode}),
  .Q(rom_b_out)
);

endmodule
