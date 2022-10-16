// Test: general purpose register
`include "tbhelper.v"

`TBPROLOGUE

localparam BUS_WIDTH = 8;
localparam DEVICE_COUNT = 3;

reg [BUS_WIDTH-1:0] device_buses [DEVICE_COUNT];
reg device_asserts_bar [DEVICE_COUNT];
wire contention_detected;
wire [BUS_WIDTH-1:0] bus_out;

// Device under test
sharedbus #(
  .BUS_WIDTH(BUS_WIDTH), .DEVICE_COUNT(DEVICE_COUNT)
) dut(
  .device_buses(device_buses),
  .device_asserts_bar(device_asserts_bar),
  .contention_detected(contention_detected),
  .bus_out(bus_out)
);

genvar gi;
wire [DEVICE_COUNT-1:0] device_assert_mask;
generate
  for(gi=0; gi<DEVICE_COUNT; gi=gi+1) begin
    assign device_assert_mask[gi] = device_asserts_bar[gi];
  end
endgenerate

integer i, j;

`TBBEGIN
  // Initial state
  for(i=0; i<DEVICE_COUNT; i=i+1) begin
    device_asserts_bar[i] = 1'b1;
    device_buses[i] = 'bZ;
  end

  `TBDELAY(2)
  `TBASSERT(bus_out === 8'bZ, "bus is high-Z");
  `TBASSERT(contention_detected === 1'b0, "no contention");

  for(i=0; i<DEVICE_COUNT; i=i+1) begin
    `TBDELAY(2)
    for(j=0; j<DEVICE_COUNT; j=j+1) begin
      device_asserts_bar[j] = (i === j) ? 1'b0 : 1'b1;
      device_buses[j] = (i == j) ? 8'h8A + j : 8'hZZ;
    end

    `TBDELAY(2)
    `TBASSERT(bus_out === 8'h8A + i, $sformatf("bus is device %d", i));
    `TBASSERT(contention_detected === 1'b0, "no contention");

    `TBDELAY(2)
    device_buses[i] = 8'h55;
    `TBDELAY(2)
    `TBASSERT(bus_out === 8'h55, "bus reflects changes");
    `TBASSERT(contention_detected === 1'b0, "no contention");

    `TBDELAY(2)
    device_buses[i] = 8'hZZ;
    `TBDELAY(2)
    `TBASSERT(bus_out === 8'hZZ, "bus propagates high-Z");
    `TBASSERT(contention_detected === 1'b0, "no contention");
  end

  `TBDELAY(2)
  for(i=0; i<DEVICE_COUNT; i=i+1) begin
    device_asserts_bar[i] = 1'b1;
    device_buses[i] = 8'hZZ;
  end
  `TBDELAY(2)
  `TBASSERT(bus_out === 8'hZZ, "default is high-Z");
  `TBASSERT(contention_detected === 1'b0, "no contention");

  for(i=0; i<DEVICE_COUNT; i=i+1) begin
    `TBDELAY(2)
    for(j=0; j<DEVICE_COUNT; j=j+1) begin
      device_buses[j] = (i == j) ? 8'h8A + j : 8'hZZ;
    end

    `TBDELAY(2)
    `TBASSERT(contention_detected === 1'b1, $sformatf("contention detected for device %d", i));
  end

  `TBDELAY(2)
  for(i=0; i<DEVICE_COUNT; i=i+1) begin
    device_buses[i] = 8'hZZ;
    device_asserts_bar[i] = 1'b1;
  end

  `TBDELAY(2)
  device_buses[2] = 8'hBB;
  device_asserts_bar[1] = 1'b0;
  `TBDELAY(2)
  `TBASSERT(contention_detected === 1'b1, "detect contention where wrong device asserts");
`TBEND
