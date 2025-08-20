# Makefile per cocotb (usa Verilator come default)

# Top-level module (DUT)
TOPLEVEL_LANG ?= verilog
TOPLEVEL      = top_module
MODULE        = tb  # nome del file Python in test/ senza .py (es: tb.py)

# Sorgenti RTL
VERILOG_SOURCES = $(shell pwd)/../src/top_module.v \
                  $(shell pwd)/../src/IO_controller.v \
                  $(shell pwd)/../src/control_unit.v \
                  $(shell pwd)/../src/ALU_controller.v \
                  $(shell pwd)/../src/ALU.v \
                  $(shell pwd)/../src/register_port.v \
                  $(shell pwd)/../src/MUX.v \
                  $(shell pwd)/../src/extender.v \
                  $(shell pwd)/../src/CORE.v

# Pulizia variabili Python per evitare conflitti
export PYTHONHOME :=
export PYTHONPATH :=

# Forza cocotb a usare il Python giusto (iniettato da GitHub Actions)
PYTHON ?= $(shell which python3)
export COCOTB_PYTHON = $(PYTHON)

# Simulatore (forzato a verilator)
SIM ?= verilator

ifeq ($(SIM),verilator)
  EXTRA_ARGS += -Wall -Wno-fatal -Wno-PINMISSING -Wno-REDEFMACRO -Wno-WIDTHTRUNC --trace --sv
endif

# Usa nuovo sistema di trace (VERILATOR_TRACE è deprecato)
COCOTB_RESOLVE_X = ZEROS
COCOTB_REDUCED_LOG_FMT = 1

# Include cocotb makefiles
include $(shell cocotb-config --makefiles)/Makefile.sim

# Target di pulizia
.PHONY: clean
clean::
	rm -rf sim_build *.vcd results.xml
