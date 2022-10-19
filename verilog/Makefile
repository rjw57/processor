IVERILOG?=iverilog
IVERILOG_FLAGS:=\
	-g2012 -y . -y ../lib/custom-7400/ -Y .sv -I../include/ \
	-civerilog.cmd -l ttl_74xx.v -DTB_SET_EXIT_CODE \
	-Wanachronisms -Wimplicit -Wtimescale -Wportbind
VVP?=vvp
PYTHON?=python3

VERBOSE?=
ifneq ($(VERBOSE),)
IVERILOG_FLAGS:=$(IVERILOG_FLAGS) -DTBVERBOSE
endif

TEST_V_FILES:=$(wildcard *-tb.sv)
TEST_VVP_FILES:=$(TEST_V_FILES:.sv=.vvp)
TEST_VCD_FILES:=$(TEST_V_FILES:.sv=.vcd)
TEST_TARGETS:=$(addprefix test-,$(TEST_V_FILES:-tb.sv=))

PIPELINE_ROMS:=pipeline-1a.mem pipeline-1b.mem pipeline-2a.mem pipeline-2b.mem

.DEFAULT: test

test: $(TEST_TARGETS)
	@echo "all testbenches passed"
.PHONY: test

$(TEST_TARGETS): test-%: $(PIPELINE_ROMS)
	"$(IVERILOG)" $(IVERILOG_FLAGS) -o "$*-tb.vvp" \
		-s testbench '-Ptestbench.DUMP_FILENAME="$*-tb.vcd"' "$*-tb.sv"
	"$(VVP)" "$*-tb.vvp"
	rm "$*-tb.vvp"
	@echo "testbench '$*' passed"
.PHONY: $(TEST_TARGETS)

clean:
	rm -f $(TEST_VVP_FILES)
	rm -f $(TEST_VCD_FILES)
	rm -f $(PIPELINE_ROMS)
.PHONY: clean

$(PIPELINE_ROMS): pipelineromgen.py
	$(PYTHON) "$<"