# Caravel hkSPI – RTL Simulation, Synthesis, and Gate-Level Verification

Functional Verification & Synthesis Flow using SCL 180nm PDK

This repository documents the full verification flow performed on the **hkspi design inside Caravel**, including:

* RTL functional simulation
* Synthesis using **Synopsys Design Compiler** with SCL 180nm (4M1L)
* Gate-Level Simulation (GLS) using the synthesized netlist
* GTKWave-based waveform comparison
* Final functional verification sign-off

All steps follow the Makefile‑driven simulation flow, with corrected paths for SCL PDK, I/O libraries, and wrapper files.

---

# 1. Repository Structure

```
.
├── rtl/                 # RTL + testbench
│   ├── hkspi.v
│   ├── hkspi_tb.v
│   └── utility RTL modules
│
├── dv/                  # RTL simulation environment (Makefile driven)
│   └── hkspi/
│
├── gl/                  # gate-level wrapper files
│
├── gls/                 # GLS simulation environment
│
├── synthesis/
│   ├── vsdcaravel_synthesis.v        # 4M1L netlist (USED)
│   ├── vsdcaravel_synthesis_6M1L.v   # 6M1L netlist (FAILED)
├── synthesis_reports
│   ├── area_post_synth.rpt
│   ├── power_post_synth.rpt
│   ├── qor_post_synth.rpt
│
├── logs/
│   ├── rtl.log
│   ├── gls.log
│
└── assets/
    ├── rtl_wave.png
    └── gls_wave.png
```

---

# 2. Environment Setup

Before running simulations, export these paths according to your setup:

```bash
export PDK_ROOT=/path/to/SCL_PDK_3.0
export SCL_IO_PATH=$PDK_ROOT/scl180/iopad/cio250/...
export GCC_PATH=/path/to/riscv32-unknown-elf/bin
```

Makefiles inside `dv/` and `gls/` use these variables internally.

---

# 3. RTL Simulation

Functional Simulation Setup
Setup functional simulation file paths
Edit Makefile at this path `./dv/hkspi/Makefile`
- Modify and verify GCC_Path to point to correct riscv installation
- Modify and verify scl_io_PATH to point to correct io

Functional Simulation Execution
- open a terminal and cd to the location of Makefile i.e. `./dv/hkspi`
- make sure hkspi.vvp file has been deleted from the hkspi folder
- Run following command to generate vvp file for functional simulation
- Navigate to the RTL DV directory:

```bash
cd dv/hkspi
make clean
make
```

This completes:

* Compilation of firmware (ELF → HEX)
* RTL compilation using iverilog
* Execution using `vvp`
* Generation of `hkspi.vcd`

Run simulation manually:

```bash
vvp hkspi.vvp | tee ../../logs/rtl.log
```

### Expected RTL Output

```
hkspi.hex loaded into memory
Read register X = ...
Monitor: Test HK SPI (RTL) Passed
```

To view waveforms:

```bash
gtkwave hkspi.vcd hkspi_tb.v
```

---

# 4. Synthesis (Synopsys Design Compiler)

Modify and verify following variables in synth.tcl file at path ./synthesis/synth.tcl
``` bash
library Path
Root Directory Path
SCL PDK Path
SCL IO PATH
```

- Before Running the synthesis, remove the `dummy_por.v` , `caravel.v` from the verilog/rtl folder

Run synthesis:

```bash
cd synthesis/work_folder
dc_shell -f ../synth.tcl
```

The final usable netlist is:

```
synthesis/vsdcaravel_synthesis.v
```

Synthesis was performed using **dc_shell** with two technology libraries:

### ❌ 6M1L — FAILED

* Generated `vsdcaravel_synthesis_6M1L.v`
* Missing/incompatible cells → mapping errors

### ✅ 4M1L — SUCCESS

* Generated **`vsdcaravel_synthesis.v`**
* Clean compile, used for GLS
* Reports stored in `synthesis/`


---

# 5. Gate-Level Simulation (GLS)

Modify and verify following variables in Makefile at path `./gls/Makefile` according to your paths

```bash 
SCL PDK Path
GCC Path
SCL IO Path
```

Modify synthesized netlist at path ./synthesis/output/vsdcaravel_synthsis.v to remove blackboxed modules
Remove following modules
```bash 
dummy_por
RAM128
housekeeping
```
Add following lines at the beginning of the netlist file to import the blackboxed modules from functional rtl

```bash 
`include "dummy_por.v"
`include "RAM128.v
`include "housekeeping.v"
```

Go to GLS directory:

```bash
cd gls
make clean
make
```

This compiles:

* Synthesized netlist (`vsdcaravel_synthesis.v`)
* Testbench
* Wrapper models

Run simulation manually:

```bash
vvp hkspi.vvp | tee ../logs/gls.log
```

### Expected GLS Output

```
Read register X = ...
Monitor: Test HK SPI (GL) Passed
```

---

# 6. RTL vs GLS Waveform Comparison

Waveform files:

```
dv/hkspi/hkspi.vcd   # RTL
gls/hkspi.vcd         # GLS
```

Open both in GTKWave:

```bash
gtkwave hkspi.vcd hkspi_tb.v
gtkwave hkspi.vcd hkspi_tb.v
```

Signals must match exactly between RTL and GLS.

### ✔ Result

Waveforms are identical → functional equivalence confirmed.
Screenshots stored in `assets/rtl_wave.png` and `assets/gls_wave.png`.

---

# 7. Results & Analysis

Below are the synthesis reports generated during the 4M1L synthesis run:

| Report File            | Description                                                   | Key Insights                                                                         |
| ---------------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `area_post_synth.rpt`  | Standard cell area breakdown                                  | Confirms cell usage, hierarchy size, and overall area footprint after mapping.       |
| `power_post_synth.rpt` | Estimated dynamic & leakage power                             | Shows low power consumption suitable for integration in Caravel user project region. |
| `qor_post_synth.rpt`   | Quality of Results (timing, violations, optimization summary) | Indicates stable timing closure; no critical violations for 4M1L library.            |

These reports were generated automatically during synthesis and are stored inside the `synthesis/` directory.

---

# 8. Summary of Verification

| Stage                 | Status   | Notes                              |
| --------------------- | -------- | ---------------------------------- |
| RTL Simulation        | ✅ Passed | Output in `logs/rtl.log`           |
| 6M1L Synthesis        | ❌ Failed | Missing cells, unusable netlist    |
| 4M1L Synthesis        | ✅ Passed | Generated `vsdcaravel_synthesis.v` |
| Gate-Level Simulation | ✅ Passed | Output in `logs/gls.log`           |
| Waveform Comparison   | ✅ Match  | Functional equivalence confirmed   |

---

# 9. Final Conclusion

* The **4M1L synthesized netlist (`vsdcaravel_synthesis.v`)** is verified and functionally accurate.
* RTL simulation and GLS simulation produce **identical results**, including register reads and waveform transitions.
* This completes **functional verification** of the hkspi design on the **SCL 180nm PDK**.

---

