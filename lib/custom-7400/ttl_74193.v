// Presettable 4-bit binary up/down counter
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
reg [WIDTH-1:0] Q_next = 0;

always @(CPU or CPD)
begin
  if (!CPU)
  begin
    Q_next = Q_current + 1;
  end
  else if(!CPD)
  begin
    Q_next = Q_current - 1;
  end
end

always @(MR or PL_bar or D)
begin
  if(MR)
  begin
    Q_current = 0;
  end
  else if(!PL_bar)
  begin
    Q_current = D;
  end
end

always @(posedge CPU or posedge CPD)
begin
  if(PL_bar & !MR)
  begin
    Q_current = Q_next;
  end
end

assign #(DELAY_RISE, DELAY_FALL) Q = Q_current;
assign #(DELAY_RISE, DELAY_FALL) TCU_bar = (
  (Q_current === {(WIDTH){1'b1}}) ? CPU : 1'b1
);
assign #(DELAY_RISE, DELAY_FALL) TCD_bar = (
  (Q_current === {(WIDTH){1'b0}}) ? CPD : 1'b1
);

endmodule
