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

**Prerequisites** \
Before using this repository, ensure you have the following dependencies installed:

- SCL180 PDK ( SCL180 PDK)
- RiscV32-uknown-elf.gcc (building functional simulation files)
- Caravel User Project Framework from Efabless
- Synopsys EDA tool Suite for Synthesis
- Verilog Simulator (e.g., Icarus Verilog)
- GTKWAVE (used for visualizing testbench waves)
- Test Instructions
- Repo Setup

**Clone the repository:**
```bash
git clone https://github.com/vsdip/vsdRiscvScl180.git
cd vsdRiscvScl180
```

Install required dependencies (ensure dc_shell and SCL180 PDK are properly set up).

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

<div align="center" >
  <img src="./logs/RTL_Passed.jpg" alt="rtl_logs" width="80%">
</div>

RTL Log file generated 

```bash
Reading hkspi.hex
hkspi.hex loaded into memory
Memory 5 bytes = 0x93 0x00 0x00 0x00 0x93
VCD info: dumpfile hkspi.vcd opened for output.
Read data = 0x11 (should be 0x11)
Read register 0 = 0x00 (should be 0x00)
Read register 1 = 0x04 (should be 0x04)
Read register 2 = 0x56 (should be 0x56)
Read register 3 = 0x11 (should be 0x11)
Read register 4 = 0x00 (should be 0x00)
Read register 5 = 0x00 (should be 0x00)
Read register 6 = 0x00 (should be 0x00)
Read register 7 = 0x00 (should be 0x00)
Read register 8 = 0x02 (should be 0x02)
Read register 9 = 0x01 (should be 0x01)
Read register 10 = 0x00 (should be 0x00)
Read register 11 = 0x00 (should be 0x00)
Read register 12 = 0x00 (should be 0x00)
Read register 13 = 0xff (should be 0xff)
Read register 14 = 0xef (should be 0xef)
Read register 15 = 0xff (should be 0xff)
Read register 16 = 0x03 (should be 0x03)
Read register 17 = 0x12 (should be 0x12)
Read register 18 = 0x04 (should be 0x04)
Monitor: Test HK SPI (RTL) Passed

```

To view waveforms:

```bash
gtkwave hkspi.vcd hkspi_tb.v
```

<div align="center" >
  <img src="./assets/rtl_wave.jpg" alt="rtl_wave" width="80%">
</div>


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

<div align="center" >
  <img src="./logs/GL_Passed.jpg" alt="GL_Passed" width="80%">
</div>

GLS Log file 

```bash
Reading hkspi.hex
hkspi.hex loaded into memory
Memory 5 bytes = 0x93 0x00 0x00 0x00 0x93
VCD info: dumpfile hkspi.vcd opened for output.
Read data = 0x11 (should be 0x11)
Read register 0 = 0x00 (should be 0x00)
Read register 1 = 0x04 (should be 0x04)
Read register 2 = 0x56 (should be 0x56)
Read register 3 = 0x11 (should be 0x11)
Read register 4 = 0x00 (should be 0x00)
Read register 5 = 0x00 (should be 0x00)
Read register 6 = 0x00 (should be 0x00)
Read register 7 = 0x00 (should be 0x00)
Read register 8 = 0x02 (should be 0x02)
Read register 9 = 0x01 (should be 0x01)
Read register 10 = 0x00 (should be 0x00)
Read register 11 = 0x00 (should be 0x00)
Read register 12 = 0x00 (should be 0x00)
Read register 13 = 0xff (should be 0xff)
Read register 14 = 0xef (should be 0xef)
Read register 15 = 0xff (should be 0xff)
Read register 16 = 0x03 (should be 0x03)
Read register 17 = 0x12 (should be 0x12)
Read register 18 = 0x04 (should be 0x04)
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

**RTL Waveform**

<div align="center" >
  <img src="./assets/rtl_wave.jpg" alt="RTL_Wave" width="80%">
</div>

**GLS Waveform**

<div align="center" >
  <img src="./assets/gls_wave.jpg" alt="GLS_Wave" width="80%">
</div>
---

# 7. Results & Analysis

Below are the synthesis reports generated during the 4M1L synthesis run:

| Report File            | Description                                                   | Key Insights                                                                         |
| ---------------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `area_post_synth.rpt`  | Standard cell area breakdown                                  | Confirms cell usage, hierarchy size, and overall area footprint after mapping.       |
| `power_post_synth.rpt` | Estimated dynamic & leakage power                             | Shows low power consumption suitable for integration in Caravel user project region. |
| `qor_post_synth.rpt`   | Quality of Results (timing, violations, optimization summary) | Indicates stable timing closure; no critical violations for 4M1L library.            |

These reports were generated automatically during synthesis and are stored inside the `synthesis/` directory.

Here is your **complete GitHub-ready README section** for **Results & Analysis**, fully written in Markdown and based on the three uploaded report files (`area_post_synth.rpt`, `power_post_synth.rpt`, `qor_post_synth.rpt`).
I extracted the metrics directly from the logs and converted them into clean, structured tables with explanations.

---

# 📊 Results and Analysis

This section presents the synthesized results of the `vsdcaravel` design using the post-synthesis reports generated from:

* **area_post_synth.rpt**
* **power_post_synth.rpt**
* **qor_post_synth.rpt**

---

## 🧱 1. Area Report Analysis (`area_post_synth.rpt`)

The area report provides details about cell usage, design area, and utilization after synthesis.

### **🔹 Area Summary**

| Metric                        | Value              |
| ----------------------------- | ------------------ |
| Number of Cells               | **31,205**         |
| Number of Combinational Cells | **18,575**         |
| Number of Sequential Cells    | **6,887**          |
| Total Cell Area               | **778,824.94 µm²** |
| Combinational Area            | **343,795.63 µm²** |
| Non-Combinational Area        | **431,042.67 µm²** |
| Buffer/Inverter Area          | **30,296.82 µm²**  |
| Macro / Black Box Area        | **3,986.64 µm²**   |
| Net Interconnect Area         | **36,088.91 µm²**  |
| **Total Design Area**         | **814,913.85 µm²** |


---

## ⚡ 2. Power Report Analysis (`power_post_synth.rpt`)

The power report provides the synthesized power breakdown into switching, internal, and leakage components.

### **🔹 Power Summary**

| Power Component         | Value          | Percentage |
| ----------------------- | -------------- | ---------- |
| Cell Internal Power     | **43.6474 mW** | 53%        |
| Net Switching Power     | **38.0750 mW** | 47%        |
| **Total Dynamic Power** | **81.7224 mW** | 100%       |
| Cell Leakage Power      | **3.1650 µW**  | ~0%        |

### **🔹 Combined Power Table**

| Component | Internal       | Switching      | Leakage       | Total          |
| --------- | -------------- | -------------- | ------------- | -------------- |
| **Total** | **43.6460 mW** | **38.0419 mW** | **3.1650 µW** | **81.6910 mW** |

### **📌 Interpretation**

* Dynamic power (internal + switching) dominates, as expected for synthesized digital logic.
* Leakage power is extremely low (~3 µW), demonstrating an efficient standard cell library and synthesis strategy.
* Internal and switching components contribute almost equally, indicating balanced logic and wiring activity.

---

## 📐 3. QoR (Quality of Results) Analysis (`qor_post_synth.rpt`)

This report summarizes the final synthesized timing and electrical rule quality.

### **🔹 QoR Summary**

| Metric                     | Value       |
| -------------------------- | ----------- |
| Worst Setup Violation      | **0.00 ns** |
| Total Setup Violation      | **0.00 ns** |
| Number of Setup Violations | **0**       |
| Worst Hold Violation       | **0.00 ns** |
| Total Hold Violation       | **0.00 ns** |
| Number of Hold Violations  | **0**       |
| Max Transition Violations  | **0**       |
| Max Capacitance Violations | **0**       |

### **📌 Interpretation**

* The design is **clean with zero timing or electrical DRC violations**, which indicates:

  * Good logic structuring
  * Proper constraints
  * The synthesis tool was able to meet all performance targets

---

# 📝 Final Summary

The synthesis results of the `vsdcaravel` design indicate:

* ✔️ **Zero timing violations** (both setup and hold)
* ✔️ **Balanced dynamic power distribution**
* ✔️ **Clean QoR with no max-cap or transition issues**
* ✔️ **Optimized area utilization with efficient logic distribution**

These three reports form the basis of the post-synthesis evaluation and help validate the correctness and efficiency of the synthesized design.

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

