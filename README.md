# RISC-V SoC Tapeout Program Documentation
---

# Raven SoC Physical Design & VSDCaravel Verification (Sky130 → SCL180) 

---

## 📘 Project Overview

This repository documents my **end-to-end SoC design journey** during **Phase-2 of the RISC-V SoC Tapeout Program**, covering both **functional verification** and **full-chip physical implementation** across different technology nodes.

The work spans **two complete design dimensions**:

1. **RTL & Gate-Level Simulation (GLS) of HKSPI inside the VSDCaravel SoC**
2. **Complete Physical Design (PD) Flow of the Raven SoC**, including **technology migration from SKY130 to SCL180 (180 nm)**

The objective of this repository is to demonstrate **tapeout-oriented thinking**, where RTL correctness, synthesis fidelity, and physical feasibility are treated as **one continuous flow**, rather than isolated steps.

---

## 🏗️ Design Scope Summary

| Area                | Description                                                     |
| ------------------- | --------------------------------------------------------------- |
| **SoC Platform**    | VSDCaravel (for verification) & Raven SoC (for physical design) |
| **Verification**    | RTL Simulation, GLS, reset integrity, module-level testing      |
| **Physical Design** | Floorplanning, Power Planning, Placement & Routing              |
| **PDKs Used**       | SKY130 → SCL180 (180 nm)                                        |
| **Tools & Flows**   | Open-source and industry-style synthesis & PD flows             |
| **Focus Areas**     | PDK migration, physical correctness, timing awareness           |

---

## 📊 Technical Journey Overview

## 🔹 Part 1: RTL & GLS Verification of HKSPI in VSDCaravel SoC

This part of the project focuses on ensuring **logical correctness, synthesis equivalence, and tool-flow robustness** for the **HKSPI module** integrated within the **VSDCaravel SoC**.

The emphasis was on building **reliable RTL and Gate-Level Simulation (GLS) flows** across multiple PDKs and toolchains, ensuring that functional behavior is preserved after synthesis.

### Objectives

* Validate RTL functionality through simulation
* Establish RTL ↔ GLS equivalence
* Adapt and verify flows using **SCL180 PDK**
* Transition from open-source to industry-grade tools

### Verification Scope

| Focus Area                              | Tools Used            | Key Outcome                                                                   |
| --------------------------------------- | --------------------- | ----------------------------------------------------------------------------- |
| HKSPI Interface Functional Verification | Icarus Verilog, Yosys | RTL and GLS waveforms matched, signal flow fully validated                    |
| SCL180 PDK-Based Synthesis & GLS        | Synopsys DC Shell     | Clean synthesis with no functional mismatches                                 |
| Industry Tool Migration                 | Synopsys VCS, DC_TOPO | Faster compilation, improved debug visibility, professional verification flow |

---

## 🔹 Part 2: RTL Architecture Analysis & Debug

This phase involved **deep RTL-level investigation and corrective design actions** to improve synthesis compatibility and backend readiness.

### Objectives

* Remove non-synthesizable or fragile constructs
* Improve reset determinism
* Identify root causes of functional failures

### Key Debug & Design Improvements

| Focus Area                   | Key Finding                                              | Resolution / Outcome                                                           |
| ---------------------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------ |
| Reset Architecture           | Behavioral POR delays incompatible with synthesis        | Replaced `dummy_por` with a single deterministic active-low `reset_n`          |
| GPIO Subsystem Investigation | Register-mapping mismatch and pad control disconnections | Root cause documented: CSR vs MMIO incompatibility and missing control signals |


### Key Activities

* Performed **RTL simulations** to validate functional behavior
* Ran **Gate-Level Simulations (GLS)** using synthesized netlists
* Verified **RTL ↔ GLS equivalence** across:

  * SKY130 PDK
  * SCL180 PDK


* Tested behavior across:

  * Reset conditions
  * Clock transitions
  * Module-level interfaces


```text
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              TOP-LEVEL                                          │
│                            vsdcaravel.v                                         │
│                                                                                 │
│  External Reset Pad: resetb => rstb_h (Currently UNUSED for POR, using reset_n) │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                    dummy_por por (INSTANTIATED)                           │  │
│  │   vdd3v3, vdd1v8, vss3v3, vss1v8  ─┐                                      │  │
│  └────────────────────────────────────┼──────────────────────────────────────┘  │
│                                       │                                         │
│                                       ▼                                         │
│                                  ┌─────────┐                                    │
│                                  │  POR    │                                    │
│                                  │  MODULE │                                    │
│                                  └─────────┘                                    │
│                                       │                                         │
│        ┌──────────────────────────────┼──────────────────────────────┐          │
│        │                              │                              │          │
│        ▼                              ▼                              ▼          │
│     [porb_h]                       [porb_l]                       [por_l]       │
│      (3.3V)                         (1.8V)                         (1.8V)       │
│        │                              │                              │          │
│        │                              │                              │          │
│        ▼                              ▼                              ▼          │
┌──────────────────────────┐  ┌──────────────────────────┐  ┌──────────────────┐  │
│  chip_io.v               │  │  caravel_core.v          │  │  housekeeping.v  │  │
│  .porb_h(porb_h)         │  │  .porb_h(porb_h)         │  │  .porb(porb_l)   │  │
│  .por(por_l)             │  │  .por(por_l)             │  │                  │  │
│                          │  │                          │  │                  │  │
│  Enables HV pads         │  │  Drives mgmt_core        │  │  Controls SPI    │  │
│  during power-up         │  │  reset distribution      │  │  flash control   │  │
└──────────────────────────┘  └──────────────────────────┘  └──────────────────┘  │
│        │                              │                              │          │
│        ▼                              ▼                              ▼          │
│  ┌─────────────────┐          ┌──────────────┐              ┌──────────────┐    │
│  │ mprj_io.v       │          │ mgmt_core.v  │              │ flash ports  │    │
│  │ .porb_h(porb_h) │          │ .porb(porb_l)│              │              │    │
│  │                 │          │              │              │              │    │
│  │ Enables HV      │          │ Resets CPU,  │              │              │    │
│  │ domain pads     │          │ RAMs, Perip. │              │              │    │
│  └─────────────────┘          └──────────────┘              └──────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────┘
```
* Removed non-synthesizable / dummy constructs (e.g., dummy POR) and replaced them with a **single clean active-low reset (`reset_n`)**


<div align="center" >
  <img src="./Task-4_Caravel_Without_dummy_POR_Final_GLS/assets/reset_n_vsdcaravel_gui.png" alt="reset_n_vsdcaravel_gui" width="80%">
</div>


### Why This Matters

GLS verification ensures that:

* The synthesized netlist truly represents the RTL intent
* No functional regressions are introduced by synthesis
* The design is safe to move into **physical implementation**

---

This phase ensured the design was **logically stable and backend-friendly** before moving into physical design. There were numerour issues in the GPIO and MPRJ Block files which are documented and needed to verify before going on to the backend physical design part. So, we shifted to Raven SOC to create a PD Flow using Synopsys so that after fixing the GPIO and MPRJ Blocks we can implement the PD flow adopted in Raven SOC to VSDCaravel saving time and exploring both the Frontend and Backend systems

---

## 🔹 Part 3: Physical Design Preparation of Raven SoC

This phase marks the transition from **logical correctness to physical feasibility**, focusing on preparing the **Raven SoC** for backend implementation.

### Objectives

* Establish a clean physical design entry point
* Prepare the design for placement and routing
* Validate physical constraints and reports

### Physical Design Scope

| Physical Design Task        | Tool / Flow               | Key Deliverables                                       |
| --------------------------- | ------------------------- | ------------------------------------------------------ |
| Floorplanning               | Physical Design Tool Flow | Die sizing, core utilization planning, pin placement   |
| Power Planning & Automation | TCL-based scripting       | Power grid planning, design-rule awareness             |
| Physical Analysis           | Tool-generated Reports    | Area, congestion, timing, and power integrity insights |

This stage ensured the Raven SoC was **physically well-structured** and suitable for downstream placement and routing without major architectural rework.

---


## 🧱 Physical Design Flow Breakdown

### 1️⃣ Floorplanning of Raven SoC

Floorplanning defines the **physical foundation** of the chip.

**Key work performed:**

* Die size and core area estimation
* Core utilization optimization
* Logical-to-physical hierarchy planning
* I/O and macro placement strategy

**Why it is critical:**

* Poor floorplanning leads to routing congestion
* Impacts timing closure and power integrity
* Sets the limits for placement and routing quality

<div align="center" >
  <img src="./Task-7 Physical design of Raven SOC/assets/sram_placement.png" alt="sram_placement" width="80%">
</div>

---

### 2️⃣ Power Planning

Power planning ensures **reliable power delivery** across the entire chip.

**Implemented concepts:**

* Power rings around the core
* Power stripes across standard-cell regions
* Separate planning for VDD and VSS networks

**Design intent:**

* Reduce IR drop
* Improve EM (electromigration) reliability
* Prepare the design for dense routing

<div align="center" >
  <img src="./Task-7 Physical design of Raven SOC/assets/powerplan.png" alt="powerplan" width="80%">
</div>

<div align="center" >
  <img src="./Task-7 Physical design of Raven SOC/assets/power_rails_around_SRAM.png" alt="power_rails_around_SRAM" width="80%">
</div>

---

### 3️⃣ Placement

Placement translates logical netlists into **physically placed standard cells**.

**Focus areas:**

* Congestion-aware placement
* Timing-friendly cell distribution
* Minimizing long interconnects
* Preparing clean paths for routing

<div align="center" >
  <img src="./Task-7 Physical design of Raven SOC/assets/std_cells_placed.png" alt="std_cells_placed" width="80%">
</div>


---

### 4️⃣ Routing (Global & Detailed)

Routing completes the physical connectivity of the design.

**Key considerations:**

* Signal integrity
* Routing layer usage
* Avoiding congestion hotspots
* Ensuring routability without violations

This step determines whether the design is **manufacturable or not**.


<div align="center" >
  <img src="./Task-7 Physical design of Raven SOC/assets/routing.jpg" alt="std_cells_placed" width="80%">
</div>


---

## 🔄 PDK Migration: SKY130 → SCL180 (180 nm)

A critical highlight of this project is the **migration of the design flow from SKY130 to SCL180**.

### Migration Challenges Addressed

| Aspect                 | SKY130             | SCL180                           |
| ---------------------- | ------------------ | -------------------------------- |
| Technology Node        | 130 nm             | 180 nm                           |
| Standard Cells         | SkyWater libraries | SCL standard cell libraries      |
| Design Rules           | Tighter            | Relatively relaxed but different |
| Routing Layers         | Different stack    | Different metal availability     |
| Timing Characteristics | Faster             | Slower but more robust           |

### What Was Done

* Updated synthesis and PD scripts
* Reconfigured library paths and constraints
* Adapted floorplan and routing strategies
* Ensured physical rules were respected
* Maintained functional equivalence post-migration

This demonstrates **real-world SoC portability across fabrication technologies**.

---

## 📊 Task-wise Repository Structure

| Task       | Description                                     |
| ---------- | ----------------------------------------------- |
| **Task-1** | RTL & GLS of Caravel IC using SKY130            |
| **Task-2** | RTL & GLS of Caravel IC using SCL180            |
| **Task-3** | RTL & GLS using SCL180 with Synopsys-style flow |
| **Task-4** | Caravel without dummy POR – final clean GLS     |
| **Task-5** | Individual module testing                       |
| **Task-6** | Floorplanning of Raven SoC                      |
| **Task-7** | Complete Physical Design of Raven SoC           |

This progression reflects a **natural RTL → GLS → PD learning curve**.

---

## 🧪 Verification vs Physical Design: Key Insight

| Verification              | Physical Design                  |
| ------------------------- | -------------------------------- |
| Ensures logic correctness | Ensures silicon feasibility      |
| Works at signal level     | Works at geometry & layout level |
| RTL/Netlist focus         | Floorplan, routing, power focus  |
| Functional bugs           | Manufacturability issues         |

This project intentionally covers **both**, which is essential for tapeout readiness.

---

## 🎯 Key Learnings & Takeaways

* RTL that simulates correctly **can still fail physically**
* PDK migration is **not just library replacement**
* Floorplanning decisions affect the entire backend flow
* Power planning is as important as logic design
* Physical design exposes constraints invisible at RTL level

---

## 🧩 Why This Project Matters

This repository represents:

* A **complete SoC design mindset**
* Exposure to **tapeout-grade workflows**
* Understanding of **technology-dependent design tradeoffs**
* Ability to move confidently from **RTL to physical silicon**

---

## 🙏 **Acknowledgment**

I am thankful to [**Kunal Ghosh**](https://github.com/kunalg123) and Team **[VLSI System Design (VSD)](https://vsdiat.vlsisystemdesign.com/)** for the opportunity to participate in the ongoing **RISC-V SoC Tapeout Program**.  

I also acknowledge the support of **RISC-V International**, **India Semiconductor Mission (ISM)**, **VLSI Society of India (VSI)**, [**Efabless**](https://github.com/efabless) and IIT Gandhinagar for making this initiative possible. Their contributions and guidance have been instrumental in shaping this program.
<div align="center">
