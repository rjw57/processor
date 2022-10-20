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

// Instruction fetch
wire [7:0] next_instruction = mem_data_bus;

// Pipeline stages
wire [7:0] pipeline_1_out;
wire [15:0] pipeline_1_control_out;
pipelinestage #(
  .DELAY_RISE(DELAY_RISE),
  .DELAY_FALL(DELAY_FALL),
  .A_CONTENTS("./pipeline-1a.mem"),
  .B_CONTENTS("./pipeline-1b.mem")
) pipeline_1 (
  .CLK(CLK),
  .FLAGS(7'b0),
  .PREV_STAGE_IN(next_instruction),
  .NEXT_STAGE_OUT(pipeline_1_out),
  .CONTROL_OUT(pipeline_1_control_out)
);

wire [7:0] pipeline_2_out;
wire [15:0] pipeline_2_control_out;
pipelinestage #(
  .DELAY_RISE(DELAY_RISE),
  .DELAY_FALL(DELAY_FALL),
  .A_CONTENTS("./pipeline-2a.mem"),
  .B_CONTENTS("./pipeline-2b.mem")
) pipeline_2 (
  .CLK(CLK),
  .FLAGS(7'b0),
  .PREV_STAGE_IN(pipeline_1_out),
  .NEXT_STAGE_OUT(pipeline_2_out),
  .CONTROL_OUT(pipeline_2_control_out)
);

// Control lines
wire ctrl_inc_pcra0 = pipeline_1_control_out[0];
wire ctrl_inc_pcra1 = pipeline_1_control_out[1];
wire ctrl_halt = pipeline_1_control_out[2];

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

// Program counter
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

endmodule
