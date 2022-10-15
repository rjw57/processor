IVERILOG:=iverilog
IVERILOG_FLAGS:=-g2012 -y . -I../include -I../lib/ice-chips-verilog/source-7400
VVP:=vvp

TEST_V_FILES:=$(wildcard *-tb.v)
TEST_VVP_FILES:=$(TEST_V_FILES:.v=.vvp)
TEST_VCD_FILES:=$(TEST_V_FILES:.v=.vcd)

%.vvp: %.v
	"$(IVERILOG)" $(IVERILOG_FLAGS) -o "$@" "$<"

%-tb.vcd: %-tb.vvp
	"$(VVP)" "$<"

%-tb.v: %.v

test: $(TEST_VCD_FILES)
.PHONY: test
.DEFAULT: test

clean:
	rm -f $(TEST_VVP_FILES)
	rm -f $(TEST_VCD_FILES)
.PHONY: clean
