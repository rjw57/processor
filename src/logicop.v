// Selectable logic ops.
//
// OP_SEL is a 4 bit look up table which gives the truth table for the logical
// operation. For corresponding bits L and R in LHS and RHS, bit 2'bLR of the
// lookup table gives the output for the operation.
//
// Uses 8 ICs = 8x74153 (or 74253)
//
// Well known operations depending on LUT:
//
//  | OP_SEL  | VALUE_OUT |
//  |---------|-----------|
//  | 4'b0000 | 8'h00     |
//  | 4'b0001 |           |
//  | 4'b0010 |           |
//  | 4'b0011 |           |
//  | 4'b0100 |           |
//  | 4'b0101 | ~RHS      |
//  | 4'b0110 | LHS ^ RHS |
//  | 4'b0111 |           |
//  | 4'b1000 | LHS & RHS |
//  | 4'b1001 |           |
//  | 4'b1010 | RHS       |
//  | 4'b1011 |           |
//  | 4'b1100 |           |
//  | 4'b1101 |           |
//  | 4'b1110 | LHS | RHS |
//  | 4'b1111 | 8'hFF     |
module logicop #(parameter DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [3:0] OP_SEL,       // operation select
  input [7:0] LHS_IN,       // left-hand side input
  input [7:0] RHS_IN,       // right-hand side input
  output [7:0] VALUE_OUT    // output value
);

wire [7:0] result;
wire [7:0] unused_outputs;

assign VALUE_OUT = result;

// TODO: it seems wasteful to only use one of the two multiplexer units in the
// 74153. Perhaps there is a clever way to have independent select lines?

genvar i;
generate
  for (i=0; i<8; i=i+1)
  begin
    // This could also be a 74253 with OE tied low.
    ttl_74153 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) sel(
      .Enable_bar(2'b0),
      .Select({LHS_IN[i], RHS_IN[i]}),
      .A_2D({OP_SEL, 4'b000}),
      .Y({result[i], unused_outputs[i]})
    );
  end
endgenerate

endmodule
