# 📘 Module Documentation

## `user_id_programming` — Caravel IC

### Project Context

This module is part of the **Efabless Caravel IC** reference design.
It implements a **mask-programmable user project identification mechanism** that allows each fabricated chip to carry a **permanent, immutable 32-bit ID**.

---

## 1. Overview

### Module Name

```verilog
user_id_programming
```

### Purpose

The `user_id_programming` module generates a **32-bit constant value (`mask_rev`)** that uniquely identifies the **user project / mask revision** of a Caravel chip.

This value is:

* **Fixed at fabrication time**
* **Not software-programmable**
* **Not stored in flash, OTP, or fuses**
* **Readable by the management core**

---

## 2. Why this module exists

Caravel is designed for **multi-project wafers (MPW)** where:

* Many users share the **same RTL**
* Chips differ only in **metal / via masks**

Therefore, Caravel needs a way to:

* Identify *which* user project is fabricated
* Track silicon revisions
* Allow firmware and debug logic to read this information

`user_id_programming` solves this using **mask-programmable constants**.

---

## 3. Programming mechanism (important)

### Type of programming

✅ **Mask / via programming**
❌ Not EEPROM
❌ Not OTP
❌ Not flash
❌ Not fuses

At tape-out:

* Each bit is hard-wired to **logic 1 or logic 0**
* Using **metal or via connections**
* The value is **permanent and immutable**

---

## 4. Module interface

### Parameters

```verilog
parameter USER_PROJECT_ID = 32'h0
```

* Represents the intended 32-bit project ID
* Used by tools and simulation
* Physically realized via metal connections

---

### Ports

```verilog
output [31:0] mask_rev
```

* `mask_rev` is the final 32-bit programmed value
* Read by management logic and firmware

Optional power pins:

```verilog
`ifdef USE_POWER_PINS
    inout VPWR,
    inout VGND,
`endif
```

---

## 5. Internal structure

### Constant cell array

```verilog
dummy_scl180_conb_1 mask_rev_value [31:0]
```

* Instantiates **32 constant logic cells**
* Each cell provides:

  * `HI` → logic 1
  * `LO` → logic 0
* These are **legal standard-cell replacements** for constants

---

### Bit selection logic

```verilog
assign mask_rev[i] =
    (USER_PROJECT_ID & (32'h01 << i)) ?
        user_proj_id_high[i] :
        user_proj_id_low[i];
```

For each bit:

* If `USER_PROJECT_ID[i] == 1` → connect `HI`
* Else → connect `LO`

⚠️ In real silicon, this is **not a mux** —
it is realized via **mask-level connectivity**.

---

## 6. STA considerations

```verilog
/// sta-blackbox
```

This module is marked as an STA blackbox because:

* Outputs are static (DC)
* No clocks
* No timing paths
* No switching activity

This avoids unnecessary STA warnings.

---

## 7. What we changed during verification (IMPORTANT)

### ❌ What we did NOT change

* `user_id_programming.v`
  ✔ It was already **correct and Caravel-compliant**

---

### ✅ What we changed

**File modified:**

```
dummy_scl180_conb_1.v
```

---

### Original dummy cell (problematic)

```verilog
module dummy_scl180_conb_1 (
    output wire HI,
    output wire LO
);
```

❌ Missing power pins
❌ Did not match instantiation
❌ Caused VCS errors

---

### Updated dummy cell (correct)

```verilog
module dummy_scl180_conb_1 (
`ifndef USE_POWER_PINS
    input VPWR,
    input VPB,
    input VNB,
    input VGND,
`endif
    output HI,
    output LO
);
    assign HI = 1'b1;
    assign LO = 1'b0;
endmodule
```

---

### Why this change was required

| Reason            | Explanation                       |
| ----------------- | --------------------------------- |
| RTL instantiation | Connects `VPWR/VPB/VNB/VGND`      |
| ASIC correctness  | Real cells always have power pins |
| Tool correctness  | VCS enforces port matching        |
| Caravel style     | Uses `USE_POWER_PINS` abstraction |
| LVS safety        | Prevents power-pin mismatches     |

This change **fixed compilation without altering functionality**.

---

## 8. Testbench overview

### Purpose

The testbench verifies that:

```
mask_rev == USER_PROJECT_ID
```

### Characteristics

* No clock
* No reset
* Pure combinational test
* RTL-only simulation

### What it checks

* Correct HI/LO selection
* Correct bit mapping
* Correct parameter usage

---

## 9. Makefile overview

### What the Makefile does

* Compiles RTL + dummy cell + testbench
* Runs Synopsys VCS
* Generates `.vcd` waveform
* Supports GTKWave viewing

### Typical flow

```bash
make        # compile + simulate
make wave   # open GTKWave
make clean  # cleanup
```

---

## 10. Simulation result

### Outcome

✅ Compilation successful
✅ Simulation completed
✅ `user_id_programming.vcd` generated
✅ `mask_rev` matched `USER_PROJECT_ID`

### Interpretation

This confirms:

* The RTL logic is correct
* The dummy cell interface is correct
* The Caravel constant-cell modeling is correct

---

## 11. Final summary

### What this module does

* Provides a **32-bit, mask-programmed user project ID**
* Permanently identifies a fabricated Caravel chip

### Why it matters

* Enables project identification
* Supports MPW workflows
* Requires no storage or configuration logic

### What we fixed

* Added correct **power-pin interface** to the dummy constant cell
* Ensured **tool-safe ASIC-accurate simulation**

### Verification status

✔ Testbench created
✔ Makefile created
✔ Simulation passed
✔ Waveform generated

---

## One-line conclusion (your preferred style)

<div align="center">
  <img src="/user_id_programming/user_id_programmin_test_pass.png" alt="Design & Testbench Overview" width="70%">
</div>

**Yes**, the module is correct and verified.
**Reason:** It implements a mask-programmed 32-bit project ID using constant cells, and the dummy cell was fixed to match ASIC power-pin interfaces.
**Example:** Simulation shows `mask_rev` exactly equals `USER_PROJECT_ID`.

