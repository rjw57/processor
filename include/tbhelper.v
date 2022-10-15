// Test bench helpers.
// Adapted from https://github.com/TimRudy/ice-chips-verilog
`default_nettype none

`define TBSETUP reg tb_all_asserts_ok = 1'b1;
`ifdef TB_SET_EXIT_CODE
`define TBDONE $finish_and_return(!tb_all_asserts_ok);
`else
`define TBDONE $finish;
`endif
`define TBASSERT(cond, msg) assert (cond) \
  begin \
    $display("ok: ", msg); \
  end \
  else \
  begin \
    tb_all_asserts_ok = 1'b0; \
    $error("fail: ", msg); \
  end

`define TBCLK_WAIT_TICK_METHOD(TB_NAME) task TB_NAME; repeat (1) @(posedge CLK); endtask
