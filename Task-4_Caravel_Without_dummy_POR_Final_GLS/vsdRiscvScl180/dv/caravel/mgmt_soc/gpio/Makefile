# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

# ==================== PATH CONFIGURATION ====================
ROOT_DIR = /home/sshekhar/vsdRiscvScl180
VERILOG_PATH = $(ROOT_DIR)
RTL_PATH = $(VERILOG_PATH)/rtl
COMMON_PATH = ../../common
scl_io_PATH = /home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/iopad/cio250/4MIL/verilog/tsl18cio250/zero
scl_io_wrapper_PATH = $(RTL_PATH)/scl180_wrapper

# ==================== TOOLCHAIN CONFIGURATION ====================
GCC_PREFIX = riscv64-unknown-elf
TOOLCHAIN_ROOT = $(HOME)/riscv-compat/riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-linux-centos6
GCC_PATH = $(TOOLCHAIN_ROOT)/bin

RISCV_TYPE ?= rv32imc
RISCV_ABI ?= ilp32

export LD_LIBRARY_PATH := $(HOME)/local/lib:$(TOOLCHAIN_ROOT)/lib:$(LD_LIBRARY_PATH)

$(info *** Using RISC-V toolchain at: $(GCC_PATH))

# ==================== TEST CONFIGURATION ====================
PATTERN = gpio
SIM_DEFINES = +define+FUNCTIONAL +define+SIM +define+SCL180

# ==================== COMPILER FLAGS ====================
GCC_FLAGS = -march=$(RISCV_TYPE) -mabi=$(RISCV_ABI) \
            -ffreestanding -nostdlib \
            -I$(COMMON_PATH) \
            -I$(COMMON_PATH)/generated \
            -I$(COMMON_PATH)/hw

LINKER_FLAGS = -Wl,-Bstatic,-T,$(COMMON_PATH)/sections.lds,--strip-debug

# ==================== VCS OPTIONS ====================
VCS_FLAGS = -sverilog +v2k -full64 -debug_access+all -lca -timescale=1ns/1ps
VCS_INCDIR = +incdir+$(COMMON_PATH) \
             +incdir+$(COMMON_PATH)/generated \
             +incdir+$(COMMON_PATH)/hw \
             +incdir+$(RTL_PATH) \
             +incdir+$(scl_io_wrapper_PATH) \
             +incdir+$(scl_io_PATH)

# ==================== OUTPUT FILES ====================
SIMV = simv
COMPILE_LOG = compile.log
SIM_LOG = simulation.log

.SUFFIXES:

# ==================== TARGETS ====================
all: sim

%.elf: %.c $(COMMON_PATH)/sections.lds $(COMMON_PATH)/start.s
	@echo "==> Compiling $< with $(GCC_PREFIX)-gcc"
	$(GCC_PATH)/$(GCC_PREFIX)-gcc $(GCC_FLAGS) $(LINKER_FLAGS) \
		-o $@ $(COMMON_PATH)/start.s $<

%.hex: %.elf
	@echo "==> Converting $< to hex format"
	$(GCC_PATH)/$(GCC_PREFIX)-objcopy -O verilog $< $@
	sed -i 's/@10000000/@00000000/g' $@
	@echo "✅ Successfully generated $@"

hex: $(PATTERN).hex

compile: $(PATTERN)_tb.v $(PATTERN).hex
	@echo "==> Compiling testbench with VCS"
	vcs $(VCS_FLAGS) $(SIM_DEFINES) $(VCS_INCDIR) \
		$(PATTERN)_tb.v \
		-l $(COMPILE_LOG) \
		-o $(SIMV)

sim: compile
	@echo "==> Running simulation"
	./$(SIMV) -l $(SIM_LOG) +vcs+dumpvars+$(PATTERN).vcd

gui: compile
	@echo "==> Launching VCS GUI"
	./$(SIMV) -gui -l $(SIM_LOG) &

wave:
	@if [ -f $(PATTERN).vcd ]; then \
		echo "==> Opening waveform with GTKWave"; \
		gtkwave $(PATTERN).vcd &; \
	else \
		echo "❌ VCD file not found. Run 'make sim' first."; \
	fi

clean:
	@echo "==> Cleaning build artifacts"
	rm -f $(SIMV) *.elf *.hex *.bin *.log *.vcd *.vpd *.fsdb *.key
	rm -rf simv.daidir csrc DVEfiles verdiLog novas.* *.fsdb+ AN.DB ucli.key

.PHONY: all compile sim hex gui wave clean

