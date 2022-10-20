IVERILOG?=iverilog
IVERILOG_FLAGS:=\
	-g2012 -y . -y ../lib/custom-7400/ -Y .sv -I../include/ \
	-civerilog.cmd -l ttl_74xx.v -DTB_SET_EXIT_CODE \
	-Wanachronisms -Wimplicit -Wtimescale -Wportbind
VVP?=vvp
PYTHON?=python3
PASM?=pasm

VERBOSE?=
ifneq ($(VERBOSE),)
IVERILOG_FLAGS:=$(IVERILOG_FLAGS) -DTBVERBOSE
endif

TEST_V_FILES:=$(wildcard *-tb.sv)
TEST_VVP_FILES:=$(TEST_V_FILES:.sv=.vvp)
TEST_VCD_FILES:=$(TEST_V_FILES:.sv=.vcd)
TEST_TARGETS:=$(addprefix test-,$(TEST_V_FILES:-tb.sv=))

TEST_PROGS:=$(wildcard asm/test-*.asm)
TEST_PROG_VCDS:=$(TEST_PROGS:.asm=.vcd)
TEST_PROG_VVPS:=$(TEST_PROGS:.asm=.vcd)
TEST_PROG_TARGETS:=$(addprefix test-prog-,$(TEST_PROGS:asm/test-%.asm=%))

PIPELINE_ROMS:=pipeline-1a.mem pipeline-1b.mem pipeline-2a.mem pipeline-2b.mem

.DEFAULT: test

test: testbenches testprogs
.PHONY: test

testbenches: $(TEST_TARGETS)
	@echo "all test benches passed"
.PHONY: testbenches

testprogs: $(TEST_PROG_TARGETS)
	@echo "all test programs ran"
.PHONY: testprogs

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
	rm -f $(TEST_PROG_VCDS) $(TEST_PROG_VVPS)
.PHONY: clean

$(PIPELINE_ROMS): pipelineromgen.py
	$(PYTHON) "$<"

$(TEST_PROG_TARGETS): test-prog-%: execution.sv $(PIPELINE_ROMS)
	$(PASM) --output execution.mem "asm/test-$*.asm"
	"$(IVERILOG)" $(IVERILOG_FLAGS) -o "asm/test-$*.vvp" \
		'-Pexecution.DUMP_FILENAME="asm/test-$*.vcd"' \
		-s execution "execution.sv"
	"$(VVP)" "asm/test-$*.vvp"
.PHONY: $(TEST_PROG_TARGETS)
