# test/Makefile

SIM ?= icarus
TOPLEVEL_LANG ?= verilog
MODULE ?= tb

ifeq ($(GATES),yes)
  VERILOG_SOURCES = $(PWD)/gate_level_netlist.v
  TOPLEVEL        = tt_um_mindlessjoe_mips_core
else
  VERILOG_SOURCES = ../src/*.v
  TOPLEVEL        = top_module
endif

export VCD_FILE = tb.vcd
export COCOTB_RESULTS_FILE = results.xml
export COCOTB_REDUCED_LOG_FMT = 1

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: clean
clean:
	$(MAKE) -f $(shell cocotb-config --makefiles)/Makefile.sim clean
	rm -f tb.vcd results.xml gate_level_netlist.v
