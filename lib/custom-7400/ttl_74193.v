// Presettable 4-bit binary up/down counter
//
// Based on implementation at https://github.com/alfishe/74xxx/blob/master/rtl/sn74xxxx.sv
//
// Signal names from https://assets.nexperia.com/documents/data-sheet/74HC_HCT193.pdf
module ttl_74193 #(parameter WIDTH = 4, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input MR,
  input CPU,
  input CPD,
  input PL_bar,
  input [WIDTH-1:0] D,

  output TCU_bar,
  output TCD_bar,
  output [WIDTH-1:0] Q
);

reg tcu = 1'b0;
reg tcd = 1'b0;
reg [WIDTH-1:0] Q_current = 0;

always @(posedge MR or negedge PL_bar or posedge CPU or posedge CPD)
begin
  if (MR)
  begin
    Q_current <= 4'b0000;
    tcu <= 1'b0;
    tcd <= 1'b0;
  end
  else if (~PL_bar)
    Q_current <= D;
  else if (CPU)
  begin
    Q_current <= Q_current + 1;
    // Will carry if we're at 14 and we're going to count up
    tcu <= (Q_current === 4'b1110) ? CPU : 1'b0;
    tcd <= 1'b0;
  end
  else if (CPD)
  begin
    Q_current <= Q_current - 1;
    tcu <= 1'b0;
    // Will borrow if we're at 1 and we're going to count down
    tcd <= (Q_current === 4'b0001) ? CPD : 1'b0;
  end
end

assign Q = Q_current;
assign TCU_bar = ~tcu;
assign TCD_bar = ~tcd;

endmodule
