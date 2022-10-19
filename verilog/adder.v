// 8-bit adder
//
// Uses 2 ICs == 2x74283
//
module adder #(parameter DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [7:0] LHS,
  input [7:0] RHS,
  input CARRY_IN,
  output [7:0] RESULT,
  output CARRY_OUT
);

wire [1:0] carry_ins;
wire [1:0] carry_outs;

assign carry_ins[0] = CARRY_IN;
assign carry_ins[1] = carry_outs[0];
assign CARRY_OUT = carry_outs[1];

genvar gi;
generate
  for (gi=0; gi<2; gi=gi+1)
  begin
    ttl_74283 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) full_adder(
      .A(LHS[3+gi*4:gi*4]),
      .B(RHS[3+gi*4:gi*4]),
      .C_in(carry_ins[gi]),
      .Sum(RESULT[3+gi*4:gi*4]),
      .C_out(carry_outs[gi])
    );
  end
endgenerate

endmodule
