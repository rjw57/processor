module processor
#(
  parameter
  DELAY_RISE = 0,
  DELAY_FALL = 0,
  ROM_READ_DELAY = 0,
  RAM_READ_DELAY = 0,
  RAM_WRITE_DELAY = 0,
  ROM_CONTENTS = "../rom/zeros.mem"
)
(
  input CLK,
  input RST_bar,

  output [7:0] A,
  output [7:0] B,
  output [7:0] C,
  output [7:0] D,
  output [7:0] FLAGS,
  output [15:0] PC,
  output [15:0] SI,
  output [15:0] MEMADDR,
  output [7:0] MEMDATA,

  output HALT
);

// Buses
wire [15:0] mem_addr_bus;
wire [7:0] mem_data_bus;
wire [7:0] lhs_bus;
wire [7:0] rhs_bus;
wire [7:0] main_bus;

// ALU flags register
wire [7:0] reg_flags_out;

assign MEMADDR = mem_addr_bus;
assign MEMDATA = mem_data_bus;
assign FLAGS = reg_flags_out;

// Control lines - stage 1
wire ctrl_load_reg_const;
wire [1:0] ctrl_lhs_bus_assert_index;
wire [1:0] ctrl_rhs_bus_assert_index;
wire [3:0] ctrl_alu_opcode;

// Control lines - stage 2
wire [2:0] ctrl_main_bus_load_index;
wire ctrl_alu_carry_in;
wire [2:0] ctrl_main_bus_assert_index;
wire [3:0] ctrl_addr_bus_load_index;
wire [3:0] ctrl_addr_bus_assert_index;
wire ctrl_halt;

// Pipeline stages
wire [6:0] pipeline_flags;
wire [7:0] next_instruction;
wire [7:0] pipeline_1_out;
wire [15:0] pipeline_1_control_out;
pipelinestage #(
  .DELAY_RISE(DELAY_RISE),
  .DELAY_FALL(DELAY_FALL),
  .READ_DELAY(DELAY_RISE * 4),
  .A_CONTENTS("./pipeline-1a.mem"),
  .B_CONTENTS("./pipeline-1b.mem")
) pipeline_1 (
  .CLK(CLK),
  .CANCEL(1'b0),
  .FLAGS(pipeline_flags),
  .PREV_STAGE_IN(next_instruction),
  .NEXT_STAGE_OUT(pipeline_1_out),
  .CONTROL_OUT(pipeline_1_control_out)
);

wire [7:0] pipeline_2_out;
wire [15:0] pipeline_2_control_out;
pipelinestage #(
  .DELAY_RISE(DELAY_RISE),
  .DELAY_FALL(DELAY_FALL),
  .READ_DELAY(DELAY_RISE * 4),
  .A_CONTENTS("./pipeline-2a.mem"),
  .B_CONTENTS("./pipeline-2b.mem")
) pipeline_2 (
  .CLK(CLK),
  .CANCEL(1'b0),
  .FLAGS(pipeline_flags),
  .PREV_STAGE_IN(pipeline_1_out),
  .NEXT_STAGE_OUT(pipeline_2_out),
  .CONTROL_OUT(pipeline_2_control_out)
);

// Pipeline stage 1 control lines
assign ctrl_load_reg_const = pipeline_1_control_out[0];
assign ctrl_lhs_bus_assert_index = pipeline_1_control_out[2:1];
assign ctrl_rhs_bus_assert_index = pipeline_1_control_out[4:3];
assign ctrl_alu_opcode = pipeline_1_control_out[8:5];

// Pipeline stage 2 control lines
assign ctrl_main_bus_load_index = pipeline_2_control_out[2:0];
assign ctrl_alu_carry_in = pipeline_2_control_out[3];
assign ctrl_main_bus_assert_index = pipeline_2_control_out[6:4];
assign ctrl_addr_bus_load_index = pipeline_2_control_out[9:7];
assign ctrl_addr_bus_assert_index = pipeline_2_control_out[12:10];
assign ctrl_halt = pipeline_2_control_out[15];

// Instruction dispatch.
//
// Simulate a 74541 line driver chip with pull downs on the
// output. Note that if we use a 74541 then there are two active low output
// enable lines which we tie to !RST_bar and ctrl_load_reg_const. This also
// requires an extra inverter. In real hardware we may not need this since we
// don't care about the initial state of the next instruction register; it will
// get loaded with the first instruction during reset.
wire inverted_rst_bar;
assign #(DELAY_RISE, DELAY_FALL) inverted_rst_bar = !RST_bar;
assign #(DELAY_RISE, DELAY_FALL) next_instruction =
  (ctrl_load_reg_const | inverted_rst_bar) ? 8'h00 : mem_data_bus;

// Halt line
assign HALT = ctrl_halt;

// Memory
wire [7:0] memory_data_out;
wire memory_assert_bar = 1'b0;
memory #(
  .DELAY_RISE(DELAY_RISE),
  .DELAY_FALL(DELAY_FALL),
  .ROM_CONTENTS(ROM_CONTENTS),
  .ROM_READ_DELAY(ROM_READ_DELAY),
  .RAM_READ_DELAY(RAM_READ_DELAY),
  .RAM_WRITE_DELAY(RAM_WRITE_DELAY)
) memory (
  .ADDR_IN(mem_addr_bus),
  .DATA_IN(mem_data_bus),
  .WE_bar(1'b1),
  .OE_bar(memory_assert_bar),
  .DATA_OUT(memory_data_out)
);

// Main bus load device index. We use the clock as an enable to ensure that
// the +ve going edge of the load line happens mid cycle. This is to ensure the
// register value is stable for subsequent cycles to latch the values. Without
// this single cycle reuse of registers, e.g. a train of add a, ... instructoins,
// would use old versions of the a register.
//
// FIXME: this sort of "half clock cycle" magic has a bit of a smell about it :(
//
// 0 == no device
// 1 == A reg
// 2 == B reg
// 3 == C reg
// 4 == D reg
wire [2:0] main_bus_load_index;
wire [7:0] main_bus_load_enable_bar;
wire main_load_index_decode_clk;
// We want to make sure the control lines have settled before starting a load.
// This emulates havign a two inverter delay.
assign #(2*DELAY_RISE, 2*DELAY_FALL) main_load_index_decode_clk = CLK;
ttl_74138 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) main_load_index_decode (
  .Enable1_bar(1'b0),
  .Enable2_bar(1'b0),
  .Enable3(main_load_index_decode_clk),
  .A(main_bus_load_index),
  .Y(main_bus_load_enable_bar)
);
assign main_bus_load_index = ctrl_main_bus_load_index;

// Main bus assert device index:
//
// 0 == no device
// 1 == constant reg
// 2 == A reg
// 3 == B reg
// 4 == C reg
// 5 == D reg
wire [2:0] main_bus_assert_index;
wire [7:0] main_bus_assert_enable_bar;
ttl_74138 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) main_assert_index_decode (
  .Enable1_bar(1'b0),
  .Enable2_bar(1'b0),
  .Enable3(1'b1),
  .A(main_bus_assert_index),
  .Y(main_bus_assert_enable_bar)
);
assign main_bus_assert_index = ctrl_main_bus_assert_index;

// LHS bus assert device index:
//
// 0 == A reg
// 1 == B reg
// 2 == C reg
// 3 == D reg
wire [2:0] lhs_bus_assert_index;
wire [7:0] lhs_bus_assert_enable_bar;
ttl_74138 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) lhs_assert_index_decode (
  .Enable1_bar(1'b0),
  .Enable2_bar(1'b0),
  .Enable3(1'b1),
  .A(lhs_bus_assert_index),
  .Y(lhs_bus_assert_enable_bar)
);
assign lhs_bus_assert_index = {1'b0, ctrl_lhs_bus_assert_index};

// RHS bus assert device index:
//
// 0 == A reg
// 1 == B reg
// 2 == C reg
// 3 == D reg
wire [2:0] rhs_bus_assert_index;
wire [7:0] rhs_bus_assert_enable_bar;
ttl_74138 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) rhs_assert_index_decode (
  .Enable1_bar(1'b0),
  .Enable2_bar(1'b0),
  .Enable3(1'b1),
  .A(rhs_bus_assert_index),
  .Y(rhs_bus_assert_enable_bar)
);
assign rhs_bus_assert_index = {1'b0, ctrl_rhs_bus_assert_index};

// Main bus load device index. We use the clock as an enable to ensure that
// the +ve going edge of the load line happens mid cycle just like with the main
// bus load.
//
// 0 == no device
// 1 == PC reg
// 2 == RA reg
// 3 == SI reg
wire [2:0] addr_bus_load_index;
wire [7:0] addr_bus_load_enable_bar;
wire addr_load_index_decode_clk;
// We want to make sure the control lines have settled before starting a load.
// This emulates havign a two inverter delay.
assign #(2*DELAY_RISE, 2*DELAY_FALL) addr_load_index_decode_clk = CLK;
ttl_74138 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) addr_load_index_decode (
  .Enable1_bar(1'b0),
  .Enable2_bar(1'b0),
  .Enable3(addr_load_index_decode_clk),
  .A(addr_bus_load_index),
  .Y(addr_bus_load_enable_bar)
);
assign addr_bus_load_index = ctrl_addr_bus_load_index;

// Address bus assert device index:
//
// 0 == LHSRHS virtual register
// 1 == PC reg
// 2 == SI reg
wire [2:0] addr_bus_assert_index;
wire [7:0] addr_bus_assert_enable_bar;
ttl_74138 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) addr_assert_index_decode (
  .Enable1_bar(1'b0),
  .Enable2_bar(1'b0),
  .Enable3(1'b1),
  .A(addr_bus_assert_index),
  .Y(addr_bus_assert_enable_bar)
);
assign addr_bus_assert_index = ctrl_addr_bus_assert_index;

// ALU - main bus device 5
wire [3:0] alu_opcode;
wire alu_carry_in;
wire [7:0] alu_result;
wire alu_carry_out;

alu #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) alu (
  .CLK(CLK),
  .LHS(lhs_bus),
  .RHS(rhs_bus),
  .OPCODE(alu_opcode),
  .CARRY_IN(alu_carry_in),
  .RESULT(alu_result),
  .CARRY_OUT(alu_carry_out)
);

// ALU flags register: latched at the -ve going clock edge. We latch at the -ve
// clock edge to ensure the signal is stable for use in the next clock cycle.
wire [7:0] reg_flags_in = {
  6'b0,
  alu_result[7],    // negative == sign bit of result
  alu_carry_out     // carry
};
wire reg_flags_clk;

// NB: inverter gate delay
assign #(DELAY_RISE, DELAY_FALL) reg_flags_clk = !CLK;

// Flags register. Initiialised to zero during reset.
ttl_74575 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg_flags(
  .Clk(reg_flags_clk),
  .Clear_bar(RST_bar),
  .OE_bar(1'b0),
  .D(reg_flags_in),
  .Q(reg_flags_out)
);

// Note: this feedback into the pipelines stage is why it is important that we
// have consistent reset behaviour
assign pipeline_flags = reg_flags_out[6:0];

assign alu_carry_in = ctrl_alu_carry_in;
assign alu_opcode = ctrl_alu_opcode;

// "Virtual" LHS_RHS register. Latched on clock. Asserts LHS *from previous
// clock tick* to the upper byte of the address bus and RHS *From previous clock
// tick* to the lower byte.
wire reg_lhsrhs_assert_bar;
wire [15:0] reg_lhsrhs_out;
ttl_74574 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg_lhsrhs_latch_1 (
  .Clk(CLK),
  .D(rhs_bus),
  .OE_bar(reg_lhsrhs_assert_bar),
  .Q(reg_lhsrhs_out[7:0])
);

ttl_74574 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg_lhsrhs_latch_2 (
  .Clk(CLK),
  .D(lhs_bus),
  .OE_bar(reg_lhsrhs_assert_bar),
  .Q(reg_lhsrhs_out[15:8])
);

// Assert device 0
assign reg_lhsrhs_assert_bar = addr_bus_assert_enable_bar[0];

// Program counter register
wire reg_pc_inc, reg_pc_dec, reg_pc_assert_bar;
wire [15:0] reg_pc_out;
wire reg_pc_reset, reg_pc_load;
assign #(DELAY_RISE, DELAY_FALL) reg_pc_reset = !RST_bar;
addrreg #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg_pc (
  .RST(reg_pc_reset),
  .INC(reg_pc_inc),
  .DEC(reg_pc_dec),
  .LOAD_bar(reg_pc_load),
  .ASSERT_bar(reg_pc_assert_bar),
  .BUS_in(mem_addr_bus),
  .BUS_out(reg_pc_out),

  .display_value(PC) // FIXME: change when we implement reg rewrite
);

// Assert device 1, load device 1
assign reg_pc_inc = CLK;
assign reg_pc_dec = 1'b1;
assign reg_pc_assert_bar = addr_bus_assert_enable_bar[1];
assign reg_pc_load = addr_bus_load_enable_bar[1];

// SI register
wire reg_si_inc, reg_si_dec, reg_si_assert_bar;
wire [15:0] reg_si_out;
wire reg_si_load;
addrreg #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg_si (
  .RST(1'b0),
  .INC(reg_si_inc),
  .DEC(reg_si_dec),
  .LOAD_bar(reg_si_load),
  .ASSERT_bar(reg_si_assert_bar),
  .BUS_in(mem_addr_bus),
  .BUS_out(reg_si_out),

  .display_value(SI)
);

// Assert device 3, load device 3
assign reg_si_inc = 1'b1;
assign reg_si_dec = 1'b1;
assign reg_si_assert_bar = addr_bus_assert_enable_bar[3];
assign reg_si_load = addr_bus_load_enable_bar[3];

// General purpose registers
wire [7:0] reg_a_main_out;
wire [7:0] reg_a_lhs_out;
wire [7:0] reg_a_rhs_out;
wire reg_a_assert_main_bar;
wire reg_a_assert_lhs_bar;
wire reg_a_assert_rhs_bar;
wire reg_a_load;
gpreg #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg_a (
  .LOAD(reg_a_load),

  .ASSERT_MAIN_bar(reg_a_assert_main_bar),
  .ASSERT_LHS_bar(reg_a_assert_lhs_bar),
  .ASSERT_RHS_bar(reg_a_assert_rhs_bar),

  .DATA_in(main_bus),

  .MAIN_out(reg_a_main_out),
  .LHS_out(reg_a_lhs_out),
  .RHS_out(reg_a_rhs_out),

  .display_value(A)
);

// Device 2 on main bus. Device 0 on LHS/RHS buses.
assign reg_a_assert_main_bar = main_bus_assert_enable_bar[2];
assign reg_a_assert_lhs_bar = lhs_bus_assert_enable_bar[0];
assign reg_a_assert_rhs_bar = rhs_bus_assert_enable_bar[0];
assign reg_a_load = main_bus_load_enable_bar[1];

wire [7:0] reg_b_main_out;
wire [7:0] reg_b_lhs_out;
wire [7:0] reg_b_rhs_out;
wire reg_b_assert_main_bar;
wire reg_b_assert_lhs_bar;
wire reg_b_assert_rhs_bar;
wire reg_b_load;
gpreg #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg_b (
  .LOAD(reg_b_load),

  .ASSERT_MAIN_bar(reg_b_assert_main_bar),
  .ASSERT_LHS_bar(reg_b_assert_lhs_bar),
  .ASSERT_RHS_bar(reg_b_assert_rhs_bar),

  .DATA_in(main_bus),

  .MAIN_out(reg_b_main_out),
  .LHS_out(reg_b_lhs_out),
  .RHS_out(reg_b_rhs_out),

  .display_value(B)
);

// Device 3 on main bus. Device 1 on LHS/RHS buses.
assign reg_b_assert_main_bar = main_bus_assert_enable_bar[3];
assign reg_b_assert_lhs_bar = lhs_bus_assert_enable_bar[1];
assign reg_b_assert_rhs_bar = rhs_bus_assert_enable_bar[1];
assign reg_b_load = main_bus_load_enable_bar[2];

wire [7:0] reg_c_main_out;
wire [7:0] reg_c_lhs_out;
wire [7:0] reg_c_rhs_out;
wire reg_c_assert_main_bar;
wire reg_c_assert_lhs_bar;
wire reg_c_assert_rhs_bar;
wire reg_c_load;
gpreg #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg_c (
  .LOAD(reg_c_load),

  .ASSERT_MAIN_bar(reg_c_assert_main_bar),
  .ASSERT_LHS_bar(reg_c_assert_lhs_bar),
  .ASSERT_RHS_bar(reg_c_assert_rhs_bar),

  .DATA_in(main_bus),

  .MAIN_out(reg_c_main_out),
  .LHS_out(reg_c_lhs_out),
  .RHS_out(reg_c_rhs_out),

  .display_value(C)
);

// Device 4 on main bus. Device 2 on LHS/RHS buses.
assign reg_c_assert_main_bar = main_bus_assert_enable_bar[4];
assign reg_c_assert_lhs_bar = lhs_bus_assert_enable_bar[2];
assign reg_c_assert_rhs_bar = rhs_bus_assert_enable_bar[2];
assign reg_c_load = main_bus_load_enable_bar[3];

wire [7:0] reg_d_main_out;
wire [7:0] reg_d_lhs_out;
wire [7:0] reg_d_rhs_out;
wire reg_d_assert_main_bar;
wire reg_d_assert_lhs_bar;
wire reg_d_assert_rhs_bar;
wire reg_d_load;
gpreg #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg_d (
  .LOAD(reg_d_load),

  .ASSERT_MAIN_bar(reg_d_assert_main_bar),
  .ASSERT_LHS_bar(reg_d_assert_lhs_bar),
  .ASSERT_RHS_bar(reg_d_assert_rhs_bar),

  .DATA_in(main_bus),

  .MAIN_out(reg_d_main_out),
  .LHS_out(reg_d_lhs_out),
  .RHS_out(reg_d_rhs_out),

  .display_value(D)
);

// Device 5 on main bus. Device 3 on LHS/RHS buses.
assign reg_d_assert_main_bar = main_bus_assert_enable_bar[5];
assign reg_d_assert_lhs_bar = lhs_bus_assert_enable_bar[3];
assign reg_d_assert_rhs_bar = rhs_bus_assert_enable_bar[3];
assign reg_d_load = main_bus_load_enable_bar[4];

// Constant register. Transparent latch of memory data bus used for two byte
// instructions.
// Like a general purpose register except the LHS/RHS buses
// are not connected and the data input is the memory data bus.
wire [7:0] reg_const_main_out;
wire [7:0] reg_const_lhs_out;
wire [7:0] reg_const_rhs_out;
wire reg_const_assert_main_bar;
wire reg_const_assert_lhs_bar;
wire reg_const_assert_rhs_bar;
wire reg_const_load;
ttl_74573 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg_const (
  .LE(reg_const_load),
  .OE_bar(reg_const_assert_main_bar),
  .D(mem_data_bus),
  .Q(reg_const_main_out)
);

// Device 1 on the main bus. Not on LHS/RHS buses.
assign reg_const_assert_main_bar = main_bus_assert_enable_bar[1];
assign reg_const_load = ctrl_load_reg_const;

// Tansfer of reg to 16 bit values. Could we have ab and cd be the sources by
// e.g., asserting a to lhs, b to rhs, having a "lhsrhs" virtual register which
// can assert on address bus?

// Memory address bus
wire [15:0] mem_addr_bus_stages [0:2];
assign mem_addr_bus_stages[0] = 16'bZ;
assign mem_addr_bus_stages[1] = reg_pc_assert_bar ? mem_addr_bus_stages[0] : reg_pc_out;
assign mem_addr_bus_stages[2] = reg_lhsrhs_assert_bar ? mem_addr_bus_stages[1] : reg_lhsrhs_out;
assign mem_addr_bus = mem_addr_bus_stages[2];

// Memory data bus
wire [7:0] mem_data_bus_stages [0:1];
assign mem_data_bus_stages[0] = 8'bZ;
assign mem_data_bus_stages[1] = memory_assert_bar ? mem_data_bus_stages[0] : memory_data_out;
assign mem_data_bus = mem_data_bus_stages[1];

// Main bus
wire [7:0] main_bus_stages [0:6];
assign main_bus_stages[0] = 8'bZ;
assign main_bus_stages[1] = main_bus_assert_enable_bar[1] ? main_bus_stages[0] : reg_const_main_out;
assign main_bus_stages[2] = main_bus_assert_enable_bar[2] ? main_bus_stages[1] : reg_a_main_out;
assign main_bus_stages[3] = main_bus_assert_enable_bar[3] ? main_bus_stages[2] : reg_b_main_out;
assign main_bus_stages[4] = main_bus_assert_enable_bar[4] ? main_bus_stages[3] : reg_c_main_out;
assign main_bus_stages[5] = main_bus_assert_enable_bar[5] ? main_bus_stages[4] : reg_d_main_out;
assign main_bus_stages[6] = main_bus_assert_enable_bar[6] ? main_bus_stages[5] : alu_result;
assign main_bus = main_bus_stages[6];

// LHS bus
wire [7:0] lhs_bus_stages [0:4];
assign lhs_bus_stages[0] = 8'bZ;
assign lhs_bus_stages[1] = reg_a_assert_lhs_bar ? lhs_bus_stages[0] : reg_a_lhs_out;
assign lhs_bus_stages[2] = reg_b_assert_lhs_bar ? lhs_bus_stages[1] : reg_b_lhs_out;
assign lhs_bus_stages[3] = reg_c_assert_lhs_bar ? lhs_bus_stages[2] : reg_c_lhs_out;
assign lhs_bus_stages[4] = reg_d_assert_lhs_bar ? lhs_bus_stages[3] : reg_d_lhs_out;
assign lhs_bus = lhs_bus_stages[4];

// RHS bus
wire [7:0] rhs_bus_stages [0:4];
assign rhs_bus_stages[0] = 8'bZ;
assign rhs_bus_stages[1] = reg_a_assert_rhs_bar ? rhs_bus_stages[0] : reg_a_rhs_out;
assign rhs_bus_stages[2] = reg_b_assert_rhs_bar ? rhs_bus_stages[1] : reg_b_rhs_out;
assign rhs_bus_stages[3] = reg_c_assert_rhs_bar ? rhs_bus_stages[2] : reg_c_rhs_out;
assign rhs_bus_stages[4] = reg_d_assert_rhs_bar ? rhs_bus_stages[3] : reg_d_rhs_out;
assign rhs_bus = rhs_bus_stages[4];

endmodule
