module execution
#(parameter
  DUMP_FILENAME = "execution.vcd",
  DELAY_RISE = 10,
  DELAY_FALL = 10
)();

// Processor clock.
reg CLK;
initial CLK = 1'b0;
always #($max(1, 20 * DELAY_RISE)) CLK = ~CLK;

// The processor itself.
reg RST_bar;
wire HALT;
processor #(
  .DELAY_RISE(DELAY_RISE),
  .DELAY_FALL(DELAY_FALL),
  .ROM_READ_DELAY(DELAY_RISE*10),
  .RAM_READ_DELAY(DELAY_RISE*2),
  .RAM_WRITE_DELAY(DELAY_RISE*2),
  .ROM_CONTENTS("execution.mem")
) dut (
  .CLK(CLK),
  .RST_bar(RST_bar),
  .HALT(HALT)
);

// A timeout to finish execution if the halt line is not raised.
initial
begin
  #(50000000)
  $display("execution timed out");
  $finish_and_return(1);
end

initial
begin
  $dumpfile(DUMP_FILENAME);
  $dumpvars;

  // Hold reset for 10 clock cycles
  RST_bar = 1'b0;
  repeat (10) @(posedge CLK);
  RST_bar = 1'b1;

  // Wait for HALT
  @(posedge HALT);

  // Extend recording for 5 clock cycles to verify halt
  repeat (5) @(posedge CLK);

  $display("processor halted");
  $finish;
end

endmodule
