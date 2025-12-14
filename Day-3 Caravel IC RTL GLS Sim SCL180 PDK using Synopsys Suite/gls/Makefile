# SPDX-FileCopyrightText: 2020 Efabless Corporation
# SPDX-License-Identifier: Apache-2.0

VCS   = vcs
SIMV  = simv
DVE   = dve

VERILOG_PATH = ..
GL_PATH      = $(VERILOG_PATH)/gl
SYN_PATH     = $(VERILOG_PATH)/synthesis/output
BEHAVIOURAL_MODELS = ../gls

# SCL180 PDK (cio250 + 4M1L)
# SCL180 PDK (cio250 + 4M1L)
IOPAD_PATH  = /home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/iopad/cio250/4M1L/verilog/tsl18cio250/zero
STDCELL_LIB = /home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/stdcell/fs120/4M1IL/verilog/vcs_sim_model/tsl18fs120_scl.v


RISCV_TYPE ?= rv32imc
FIRMWARE_PATH = ../gls
GCC_PATH ?= /home/rpatel/riscv-tools/bin
GCC_PREFIX ?= riscv32-unknown-elf

PATTERN = hkspi
TB      = $(PATTERN)_tb.v
ELF     = $(PATTERN).elf
HEX     = $(PATTERN).hex
VPD     = $(PATTERN)_gls.vpd

SIM_DEFINES = +define+SIM +define+GL +define+USE_POWER_PINS

VCS_FLAGS = -full64 -sverilog -debug_access+all \
            -l vcs_gls_compile.log \
            +notimingcheck


INCLUDES = \
	+incdir+$(GL_PATH) \
	+incdir+$(BEHAVIOURAL_MODELS) \
	+incdir+$(IOPAD_PATH)

all: sim run

%.elf: %.c $(FIRMWARE_PATH)/sections.lds $(FIRMWARE_PATH)/start.s
	$(GCC_PATH)/$(GCC_PREFIX)-gcc \
		-march=$(RISCV_TYPE) -mabi=ilp32 \
		-Wl,-Bstatic,-T,$(FIRMWARE_PATH)/sections.lds,--strip-debug \
		-ffreestanding -nostdlib \
		-o $@ $(FIRMWARE_PATH)/start.s $<

%.hex: %.elf
	$(GCC_PATH)/$(GCC_PREFIX)-objcopy -O verilog $< $@
	sed -i 's/@10000000/@00000000/g' $@

sim: $(TB) $(HEX)
	$(VCS) $(VCS_FLAGS) \
	$(SIM_DEFINES) \
	$(INCLUDES) \
	$(STDCELL_LIB) \
	$(IOPAD_PATH)/*.v \
	$(SYN_PATH)/*.v \
	$(TB) \
	-o $(SIMV)


run:
	./$(SIMV) +vpdfile=$(VPD) | tee vcs_gls_run.log

wave:
	$(DVE) -vpd $(VPD) &

clean:
	rm -rf $(SIMV) simv.daidir *.log *.vpd *.elf

.PHONY: all sim run wave clean

