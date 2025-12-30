# SPDX-FileCopyrightText: 2020 Efabless Corporation
# SPDX-License-Identifier: Apache-2.0

# ============================================================
# Tool definitions (Synopsys only)
# ============================================================
VCS      = vcs
SIMV     = simv
DVE      = dve

# ============================================================
# Paths (verified from your setup)
# ============================================================
VERILOG_PATH        = ../../
RTL_PATH            = $(VERILOG_PATH)/rtl
BEHAVIOURAL_MODELS  = ../

scl_io_PATH = /home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/iopad/cio250/4M1L/verilog/tsl18cio250/zero
scl_io_wrapper_PATH = $(RTL_PATH)/scl180_wrapper

# ============================================================
# Simulation configuration
# ============================================================
PATTERN     = hkspi
TB          = $(PATTERN)_tb.v
HEX         = $(PATTERN).hex
VPD         = $(PATTERN).vpd

SIM_DEFINES = +define+FUNCTIONAL +define+SIM

VCS_FLAGS = -full64 -sverilog -debug_access+all -l vcs_compile.log

INCLUDES = \
	+incdir+$(BEHAVIOURAL_MODELS) \
	+incdir+$(RTL_PATH) \
	+incdir+$(scl_io_wrapper_PATH) \
	+incdir+$(scl_io_PATH)

# ============================================================
# Default target
# ============================================================
all: sim run

# ============================================================
# Compile RTL with VCS
# ============================================================
sim: $(TB) $(HEX)
	$(VCS) $(VCS_FLAGS) \
	$(SIM_DEFINES) \
	$(INCLUDES) \
	$(TB) \
	-o $(SIMV)

# ============================================================
# Run simulation (generate VPD)
# ============================================================
run:
	./$(SIMV) +vpdfile=$(VPD) | tee sim_run.log

# ============================================================
# View waveform (DVE)
# ============================================================
wave:
	$(DVE) -vpd $(VPD) &

# ============================================================
# Clean
# ============================================================
clean:
	rm -rf $(SIMV) simv.daidir *.log *.vpd

.PHONY: all sim run wave clean

