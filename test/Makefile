# --- cocotb + Icarus, RTL & GL ---

SIM ?= icarus
TOPLEVEL_LANG ?= verilog
MODULE ?= tb                    # tb.py (senza estensione)

# Se GATES=yes (usato dalla action GL), usa la netlist e il wrapper TT
ifeq ($(GATES),yes)
  VERILOG_SOURCES = $(PWD)/gate_level_netlist.v
  TOPLEVEL        = tt_um_mindlessjoe_mips_core
else
  # RTL: tutti i sorgenti
  VERILOG_SOURCES = ../src/*.v
  TOPLEVEL        = top_module
endif

ifeq ($(SIM),verilator)
  export VERILATOR_TRACE = 1
  EXTRA_ARGS += --sv -Wno-REDEFMACRO -Wno-PINMISSING -Wno-WIDTHTRUNC

endif

# produce i file attesi dalla CI
export VCD_FILE = tb.vcd
export COCOTB_RESULTS_FILE = results.xml
export COCOTB_REDUCED_LOG_FMT = 1

# include le regole standard di cocotb
include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: clean
clean::
	$(MAKE) -f $(shell cocotb-config --makefiles)/Makefile.sim clean
	rm -f tb.vcd results.xml gate_level_netlist.v
