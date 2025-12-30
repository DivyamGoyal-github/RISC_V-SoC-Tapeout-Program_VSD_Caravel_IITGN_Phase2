# Caravel-IC-RTL-GLS Simulations
---

## **Caravel SoC Architecture & Simulation Guide**

> **Caravel** is an open-source SoC harness by **Efabless**, designed for OpenMPW shuttles on the SkyWater SKY130 process node.
> It provides a complete SoC environment—padframe, housekeeping, management SoC, Wishbone interconnect, GPIOs—and a fixed **User Project Area** (UPA) to integrate your digital or analog design.

---

## **📌 Table of Contents**

1. [Introduction](#introduction)
2. [Caravel Architecture](#caravel-architecture)

   * [Top-Level Block Diagram](#top-level-block-diagram)
   * [1. The Padframe](#1-the-padframe)
   * [2. Housekeeping Logic](#2-housekeeping-logic)
   * [3. Management SoC](#3-management-soc)
   * [4. Wishbone Bus Interface](#4-wishbone-bus-interface)
   * [5. User Project Area (UPA)](#5-user-project-area-upa)
   * [6. Logic Analyzer Interface](#6-logic-analyzer-interface)
3. [Repository Structure Overview](#repository-structure-overview)
4. [Creating Your User Project](#creating-your-user-project)
5. [Running RTL Simulations](#running-rtl-simulations)
6. [Running Gate-Level Simulations (GLS)](#running-gate-level-simulations-gls)
7. [Tips, Pitfalls & Best Practices](#tips-pitfalls--best-practices)
8. [References](#references)

---

# **Introduction**

Caravel is a **silicon-proven SoC harness** that standardizes how user projects are integrated into actual fabricated ASICs. It eliminates the need to design peripheral infrastructure from scratch (padframe, reset controller, bus fabric, management processor).

You only focus on your **digital/analog RTL**, while Caravel handles the rest.

---

# **Caravel Architecture**

## **Top-Level Block Diagram**

![Caravel Architecture](https://github.com/efabless/caravel/raw/main/docs/source/_static/caravel_block_diagram.jpg)

Caravel consists of the following major blocks:

---

## **1. The Padframe**

The padframe handles:

* External I/O protection
* Level shifting
* Power routing
* GPIO configuration (input, output, analog-enabled modes)

It exposes **38 GPIO pads** to the user project.

---

## **2. Housekeeping Logic**

This subsystem provides:

* Clock and reset distribution
* SPI configuration interface
* Pad control registers
* Backdoor access to internal configuration through Wishbone

The SoC firmware uses housekeeping to configure the chip immediately after reset.

---

## **3. Management SoC**

A RISC-V based lightweight SoC responsible for:

* Boot-time configuration of user GPIOs
* Communicating with user logic via Wishbone
* Capturing internal signals via logic analyzer probes
* Running test firmware that exercises the user design

It includes:

* SRAM
* Boot ROM
* SPI interface

---

## **4. Wishbone Bus Interface**

A simple, open standard **Wishbone bus** connects:

* Management SoC
* Housekeeping block
* User Project Area (optional)

Users may implement custom Wishbone peripherals inside their project.

---

## **5. User Project Area (UPA)**

This is the designer's playground.

* A fixed silicon region dedicated to your logic
* Exposed to GPIOs and LA probes
* Contains the required top module:

```
user_project_wrapper
```

### UPA Features:

* 38 GPIO connections
* Wishbone slave interface (optional)
* 128 Logic Analyzer (LA) probes
* Power routing + reset inputs

---

## **6. Logic Analyzer Interface**

The **Logic Analyzer (LA)** provides:

* 128 probe lines
* Software-driven observation/injection of internal signals
* Useful for debugging without external probes

Great for:

* Monitoring signals in a taped-out chip
* Stimulus injection
* Self-test automation

---

# **Repository Structure Overview**

A typical Caravel repository contains:

```
caravel/
│
├── verilog/                   # HDL sources (harness + wrappers)
│   ├── rtl/
│   ├── gl/                    # Gate-level files
│
├── openlane/                  # PnR flows for user project
│
├── gds/                       # GDS files for hardening
├── lef/                       # Layout exchange format files
├── mag/ maglef/               # Magic layout files
│
├── docs/                      # Architecture and flow documentation
│
├── firmware/                  # Management SoC firmware
└── README.rst
```

---

# **Creating Your User Project**

To integrate your design inside Caravel:

### **✔ Mandatory Top Module**

```
module user_project_wrapper(...);
```

### **✔ Requirements**

* Match **pin order exactly**
* Follow provided `info.yaml` configuration
* Ensure your layout fits the UPA area
* Use OpenLane for hardening and DRC/LVS

### **✔ Optional**

* Wishbone peripheral support
* Custom LA probe mapping
* Mixed-signal integration

---

# **Running RTL Simulations**


### **1. Install simulator**

You can use:

* **Icarus Verilog (iverilog)**
* **Verilator**
* Commercial tools (if available)

---

### **2. Compile RTL**

Example command:

```bash
iverilog -o simv \
  verilog/rtl/*.v \
  user_project/verilog/*.v \
  tb/user_project_tb.v

vvp simv
```

---

### **3. Write a testbench**

* Provide clock & reset
* Drive Wishbone/GPIO/LA as needed
* Compare expected outputs

Example skeleton:

```verilog
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    resetn = 0;
    #100 resetn = 1;
end
```

---

# **Running Gate-Level Simulations (GLS)**


GLS validates **timing, glitches, propagation delays**, and verifies design behavior after synthesis & layout.

---

## **1. Run OpenLane Flow**

Install OpenLane + Sky130 PDK, then:

```bash
cd openlane/user_project_wrapper
make clean
make pnr
```

This generates:

* Gate-level netlist
* SPEF / SDF timing files
* Final GDS

---

## **2. Run GLS Simulation**

Example:

```bash
iverilog -o gls_simv \
  verilog/gl/user_project_wrapper.gl.v \
  tb/user_project_tb.v

vvp gls_simv
```

If your simulator supports SDF:

```bash
vsim -sdftyp /dut=user_project_wrapper.sdf tb_top
```

---

# **Tips, Pitfalls & Best Practices**

### ⚠ **Critical: Maintain pin order**

Mismatch leads to **chip integration failure**.

### ⚡ Ensure clean synthesis

Avoid latches, x-propagation, incomplete case statements.

### 🧪 Compare RTL vs GLS waveforms

They must match for a correct implementation.

### 🏗 Ensure the design fits UPA area

Check OpenLane utilization reports.

### 🧵 Use logic analyzer wisely

Great for debugging taped-out silicon.

---

# **References**

* **Caravel Repository:**
  [https://github.com/efabless/caravel](https://github.com/efabless/caravel)

* **Caravel Harness Documentation:**
  [https://caravel-harness.readthedocs.io](https://caravel-harness.readthedocs.io)

* **OpenLane Flow:**
  [https://github.com/The-OpenROAD-Project/OpenLane](https://github.com/The-OpenROAD-Project/OpenLane)

* **SkyWater SKY130 PDK:**
  [https://github.com/RTimothyEdwards/open_pdks](https://github.com/RTimothyEdwards/open_pdks)


---
