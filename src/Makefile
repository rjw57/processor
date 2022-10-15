IVERILOG:=iverilog
IVERILOG_FLAGS:=\
	-g2012 -y . -y ../lib/custom-7400/ -I../include/ \
	-civerilog.cmd -l ttl_74xx.v \
	-Wanachronisms -Wimplicit -Wtimescale -Wportbind
VVP:=vvp

TEST_V_FILES:=$(wildcard *-tb.v)
TEST_VVP_FILES:=$(TEST_V_FILES:.v=.vvp)
TEST_VCD_FILES:=$(TEST_V_FILES:.v=.vcd)

%-tb.vvp: %-tb.v
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
