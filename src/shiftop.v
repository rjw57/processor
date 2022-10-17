// Selectable shifter.
//
// Uses 5 ICs == 4x74153
//
// Operations:
//
//  | OP_SEL | operation                            |
//  |--------|--------------------------------------|
//  | 2'b00  | VALUE_OUT = 8'b0                     |
//  | 2'b01  | VALUE_OUT = VALUE_IN                 |
//  | 2'b10  | VALUE_OUT = {VALUE_IN[6:0], interp}  |
//  | 2'b11  | VALUE_OUT = {interp, VALUE_IN[7:1]}  |
//
// Interpolation
//
//  | INTERP_SEL  | interp      |
//  |-------------|-------------|
//  | 2'b00       | 1'b0        |
//  | 2'b01       | 1'b1        |
//  | 2'b10       | VALUE_IN[0] |
//  | 2'b11       | VALUE_IN[7] |
//
module shiftop #(parameter DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [1:0] OP_SEL,     // operation select
  input [1:0] INTERP_SEL, // interpolation select
  input [7:0] VALUE_IN,   // input value
  output [7:0] VALUE_OUT  // output value
);

wire [7:0] results [0:3];

wire [7:0] selected_result;
wire selected_interp, unused_select;

assign VALUE_OUT = selected_result;

// Selector for interp
ttl_74153 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) carry_sel(
  .Enable_bar(2'b0),
  .Select(INTERP_SEL),
  .A_2D({
    {VALUE_IN[7], VALUE_IN[0], 1'b1, 1'b0},
    4'b0
  }),
  .Y({selected_interp, unused_select})
);

assign results[0] = 8'b0;
assign results[1] = VALUE_IN;
assign results[2] = {VALUE_IN[6:0], selected_interp};
assign results[3] = {selected_interp, VALUE_IN[7:1]};

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

endmodule
