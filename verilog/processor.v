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
  output HALT
);

// Buses
wire [15:0] mem_addr_bus;
wire [7:0] mem_data_bus;
wire [7:0] lhs_bus;
wire [7:0] rhs_bus;
wire [7:0] main_bus;

// Control lines - stage 1
wire ctrl_inc_pcra0;
wire ctrl_inc_pcra1;
wire ctrl_instr_dispatch_bar;
wire ctrl_load_reg_const;
wire [1:0] ctrl_lhs_bus_assert_index;
wire [1:0] ctrl_rhs_bus_assert_index;
wire [3:0] ctrl_alu_opcode;

// Control lines - stage 2
wire ctrl_load_reg_a;
wire ctrl_load_reg_b;
wire ctrl_load_reg_c;
wire ctrl_load_reg_d;
wire [2:0] ctrl_main_bus_assert_index;
wire ctrl_load_reg_flags;
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
  .FLAGS(pipeline_flags),
  .PREV_STAGE_IN(pipeline_1_out),
  .NEXT_STAGE_OUT(pipeline_2_out),
  .CONTROL_OUT(pipeline_2_control_out)
);

// Pipeline stage 1 control lines
assign ctrl_inc_pcra0 = pipeline_1_control_out[0];
assign ctrl_inc_pcra1 = pipeline_1_control_out[1];
assign ctrl_instr_dispatch_bar = pipeline_1_control_out[2];
assign ctrl_load_reg_const = pipeline_1_control_out[3];
assign ctrl_lhs_bus_assert_index = pipeline_1_control_out[5:4];
assign ctrl_rhs_bus_assert_index = pipeline_1_control_out[7:6];
assign ctrl_alu_opcode = pipeline_1_control_out[11:8];

// Pipeline stage 2 control lines
assign ctrl_load_reg_a = pipeline_2_control_out[0];
assign ctrl_load_reg_b = pipeline_2_control_out[1];
assign ctrl_load_reg_c = pipeline_2_control_out[2];
assign ctrl_load_reg_d = pipeline_2_control_out[3];
assign ctrl_main_bus_assert_index = pipeline_2_control_out[6:4];
assign ctrl_load_reg_flags = pipeline_2_control_out[7];
assign ctrl_halt = pipeline_2_control_out[15];

// Instruction dispatch.
//
// Simulate a 74541 line driver chip with pull downs on the
// output. Note that if we use a 74541 then there are two active low output
// enable lines which we tie to !RST_bar and ctrl_instr_dispatch_bar. This also
// requires an extra inverter.
assign #(DELAY_RISE, DELAY_FALL) next_instruction =
  (ctrl_instr_dispatch_bar | !RST_bar) ? 8'h00 : mem_data_bus;

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
ttl_74138 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) lhs_assert_index_decodd (
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
ttl_74138 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) rhs_assert_index_decodd (
  .Enable1_bar(1'b0),
  .Enable2_bar(1'b0),
  .Enable3(1'b1),
  .A(rhs_bus_assert_index),
  .Y(rhs_bus_assert_enable_bar)
);
assign rhs_bus_assert_index = {1'b0, ctrl_rhs_bus_assert_index};

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

// Flags register
wire [7:0] reg_flags_in = {7'b0, alu_carry_out};
wire [7:0] reg_flags_out;
ttl_74573 #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg_flags(
  .LE(ctrl_load_reg_flags),
  .OE_bar(1'b0),
  .D(reg_flags_in),
  .Q(reg_flags_out)
);

// TODO: we can't enable this until we have consistent reset behaviour
//assign pipeline_flags = {reg_flags_out[5:0], RST_bar};
assign pipeline_flags = 7'b0;

assign alu_carry_in = 1'b0; // TODO
assign alu_opcode = ctrl_alu_opcode;

// Program counter register
wire [15:0] reg_pc_out;
wire reg_pc_assert_bar = 1'b0;
addrreg #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg_pc (
  .CLK(CLK),
  .RST_bar(RST_bar),
  .LOAD_bar(1'b1),
  .INC(ctrl_inc_pcra0),
  .ASSERT_bar(reg_pc_assert_bar),
  .BUS_in(mem_addr_bus),
  .BUS_out(reg_pc_out)
);

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
  .RHS_out(reg_a_rhs_out)
);

// Device 2 on main bus. Device 0 on LHS/RHS buses.
assign reg_a_assert_main_bar = main_bus_assert_enable_bar[2];
assign reg_a_assert_lhs_bar = lhs_bus_assert_enable_bar[0];
assign reg_a_assert_rhs_bar = rhs_bus_assert_enable_bar[0];
assign reg_a_load = ctrl_load_reg_a;

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
  .RHS_out(reg_b_rhs_out)
);

// Device 3 on main bus. Device 1 on LHS/RHS buses.
assign reg_b_assert_main_bar = main_bus_assert_enable_bar[3];
assign reg_b_assert_lhs_bar = lhs_bus_assert_enable_bar[1];
assign reg_b_assert_rhs_bar = rhs_bus_assert_enable_bar[1];
assign reg_b_load = ctrl_load_reg_b;

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
  .RHS_out(reg_c_rhs_out)
);

// Device 4 on main bus. Device 2 on LHS/RHS buses.
assign reg_c_assert_main_bar = main_bus_assert_enable_bar[4];
assign reg_c_assert_lhs_bar = lhs_bus_assert_enable_bar[2];
assign reg_c_assert_rhs_bar = rhs_bus_assert_enable_bar[2];
assign reg_c_load = ctrl_load_reg_c;

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
  .RHS_out(reg_d_rhs_out)
);

// Device 5 on main bus. Device 3 on LHS/RHS buses.
assign reg_d_assert_main_bar = main_bus_assert_enable_bar[5];
assign reg_d_assert_lhs_bar = lhs_bus_assert_enable_bar[3];
assign reg_d_assert_rhs_bar = rhs_bus_assert_enable_bar[3];
assign reg_d_load = ctrl_load_reg_d;

// Constant register. Like a general purpose register except the LHS/RHS buses
// are not connected and the data input is the memory data bus.
wire [7:0] reg_const_main_out;
wire [7:0] reg_const_lhs_out;
wire [7:0] reg_const_rhs_out;
wire reg_const_assert_main_bar;
wire reg_const_assert_lhs_bar;
wire reg_const_assert_rhs_bar;
wire reg_const_load;
gpreg #(.DELAY_RISE(DELAY_RISE), .DELAY_FALL(DELAY_FALL)) reg_const (
  .LOAD(reg_const_load),
  .ASSERT_MAIN_bar(reg_const_assert_main_bar),
  .ASSERT_LHS_bar(1'b1),
  .ASSERT_RHS_bar(1'b1),

  .DATA_in(mem_data_bus),

  .MAIN_out(reg_const_main_out)
);

// Device 1 on the main bus. Not on LHS/RHS buses.
assign reg_const_assert_main_bar = main_bus_assert_enable_bar[1];
assign reg_const_assert_lhs_bar = 1'b1;
assign reg_const_assert_rhs_bar = 1'b1;
assign reg_const_load = ctrl_load_reg_const;

// Memory address bus
wire [15:0] mem_addr_bus_stages [0:1];
assign mem_addr_bus_stages[0] = 16'bZ;
assign mem_addr_bus_stages[1] = reg_pc_assert_bar ? mem_addr_bus_stages[0] : reg_pc_out;
assign mem_addr_bus = mem_addr_bus_stages[1];

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
assign lhs_bus_stages[1] = lhs_bus_assert_enable_bar[0] ? lhs_bus_stages[0] : reg_a_lhs_out;
assign lhs_bus_stages[2] = lhs_bus_assert_enable_bar[1] ? lhs_bus_stages[1] : reg_b_lhs_out;
assign lhs_bus_stages[3] = lhs_bus_assert_enable_bar[2] ? lhs_bus_stages[2] : reg_c_lhs_out;
assign lhs_bus_stages[4] = lhs_bus_assert_enable_bar[3] ? lhs_bus_stages[3] : reg_d_lhs_out;
assign lhs_bus = lhs_bus_stages[4];

// RHS bus
wire [7:0] rhs_bus_stages [0:4];
assign rhs_bus_stages[0] = 8'bZ;
assign rhs_bus_stages[1] = rhs_bus_assert_enable_bar[0] ? rhs_bus_stages[0] : reg_a_rhs_out;
assign rhs_bus_stages[2] = rhs_bus_assert_enable_bar[1] ? rhs_bus_stages[1] : reg_b_rhs_out;
assign rhs_bus_stages[3] = rhs_bus_assert_enable_bar[2] ? rhs_bus_stages[2] : reg_c_rhs_out;
assign rhs_bus_stages[4] = rhs_bus_assert_enable_bar[3] ? rhs_bus_stages[3] : reg_d_rhs_out;
assign rhs_bus = rhs_bus_stages[4];

endmodule
