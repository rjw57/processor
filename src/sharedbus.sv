// Emulate a shared bus consisting of devices with independent assert lines.
//
// As this is an abstraction to model a shared bus within verilog, there is no
// delay associated with the shared bus, delays should be modelled within the
// individual devices.
//
// The assert lines for each device should be passed to the module to allow
// contention detection; if any device whose assert line is not actve is sending
// anything other than high-Z on their bus, we signal contention.

module sharedbus #(
  parameter BUS_WIDTH = 8, DEVICE_COUNT = 1
)(
  input [BUS_WIDTH-1:0] device_buses [0:DEVICE_COUNT-1],    // bus outputs for each device
  input device_asserts_bar [0:DEVICE_COUNT-1],              // assert flags passed to each device
  output contention_detected,                               // 1 if contention detected on bus
  output [BUS_WIDTH-1:0] bus_out                            // multiplexed bus
);

// The thought here is to build up the bus signal in stages by propagating
// values from initial stage to final stage based on whether that device is
// currently asserting.
wire [BUS_WIDTH-1:0] bus_stages [0:DEVICE_COUNT];
wire contention_stages[0:DEVICE_COUNT];
assign bus_stages[0] = 'bZ;
assign contention_stages[0] = 'b0;
assign bus_out = bus_stages[DEVICE_COUNT];
assign contention_detected = contention_stages[DEVICE_COUNT];
genvar i;
generate
  for(i=0; i<DEVICE_COUNT; i=i+1) begin
    assign bus_stages[i+1] = device_asserts_bar[i] ? bus_stages[i] : device_buses[i];
    assign contention_stages[i+1] = (
      (device_asserts_bar[i] === 1'b1) && (device_buses[i] !== {(BUS_WIDTH){1'bZ}})
    ) ? 1'b1 : contention_stages[i];
  end
endgenerate

endmodule
