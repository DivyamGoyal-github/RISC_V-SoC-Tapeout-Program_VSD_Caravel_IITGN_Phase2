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

## 🔹 Part 1: RTL & GLS Verification of HKSPI in VSDCaravel SoC

The first part of this project focuses on **logical correctness and synthesis equivalence** of the **HKSPI module** integrated within the **VSDCaravel SoC**.

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

## 🔹 Part 2: Physical Design of Raven SoC (Core Contribution)

The **major contribution** of this repository is the **complete Physical Design (PD) flow of the Raven SoC**, carried out with a **silicon-first mindset**.

This phase moves beyond simulation and addresses **real fabrication constraints**, where layout, routing, and power integrity determine whether a chip can actually be manufactured.

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

---

### 3️⃣ Placement

Placement translates logical netlists into **physically placed standard cells**.

**Focus areas:**

* Congestion-aware placement
* Timing-friendly cell distribution
* Minimizing long interconnects
* Preparing clean paths for routing

---

### 4️⃣ Routing (Global & Detailed)

Routing completes the physical connectivity of the design.

**Key considerations:**

* Signal integrity
* Routing layer usage
* Avoiding congestion hotspots
* Ensuring routability without violations

This step determines whether the design is **manufacturable or not**.

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
