// Selectable shifter.
//
// Uses 5 ICs == 4x74153
//
// Operations:
//
//  | OP_SEL | operation                                              |
//  |--------|--------------------------------------------------------|
//  | 2'b00  | VALUE_OUT = 8'b0, carry_out = 1'b0                     |
//  | 2'b01  | VALUE_OUT = VALUE_IN, carry_out = 1'b0                 |
//  | 2'b10  | VALUE_OUT = VALUE_IN << 1, carry_out = VALUE_IN >> 7   |
//  | 2'b11  | VALUE_OUT = VALUE_IN >> 1, carry_out = VALUE_IN & 0x1  |
module shiftop #(parameter DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [1:0] OP_SEL,     // operation select
  input [7:0] VALUE_IN,   // input value
  output [7:0] VALUE_OUT, // output value
  output CARRY_OUT        // carry flag
);

wire [7:0] results [0:3];
wire carries [0:3];

wire [7:0] selected_result;
wire selected_carry, unused_select;

assign VALUE_OUT = selected_result;
assign CARRY_OUT = selected_carry;

assign results[0] = 8'b0;
assign carries[0] = 1'b0;

assign results[1] = VALUE_IN;
assign carries[1] = 1'b0;

assign results[2] = {VALUE_IN[6:0], 1'b0};
assign carries[2] = VALUE_IN[7];

assign results[3] = {1'b0, VALUE_IN[7:1]};
assign carries[3] = VALUE_IN[0];

genvar i;
generate
  for (i=0; i<4; i=i+1)
  begin
    ttl_74153 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) sel(
      .Enable_bar(2'b0),
      .Select(OP_SEL),
      .A_2D({
        {results[3][2*i], results[2][2*i], results[1][2*i], results[0][2*i]},
        {results[3][1+2*i], results[2][1+2*i], results[1][1+2*i], results[0][1+2*i]}
      }),
      .Y({selected_result[i*2], selected_result[1+i*2]})
    );
  end
endgenerate

// Selector for carry
ttl_74153 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) carry_sel(
  .Enable_bar(2'b0),
  .Select(OP_SEL),
  .A_2D({
    {carries[3], carries[2], carries[1], carries[0]},
    4'b0
  }),
  .Y({selected_carry, unused_select})
);

endmodule
