// SPDX-FileCopyrightText: 2025 Efabless Corporation/VSD
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

// `default_nettype none
// SPDX-FileCopyrightText: 2025 Efabless Corporation/VSD
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

// ==============================================================================
// SCL180 PAD MACROS - Replacement for Sky130 pads
// ==============================================================================
// This file defines Verilog macros for SCL180 pad instantiation
// Replaces all Sky130 gpiov2 pads with SCL180 equivalents:
//   - pc3d01_wrapper: Input pad (CMOS)
//   - pc3d21: Input pad with Schmitt trigger
//   - pt3b02_wrapper: Output pad (TTL, 4mA)
//   - pc3b03ed_wrapper: Bidirectional pad (CMOS, 3x drive with pull-down)
// ==============================================================================

// `default_nettype none

`ifndef TOP_ROUTING 
	`define USER1_ABUTMENT_PINS \
	.AMUXBUS_A(analog_a),\
	.AMUXBUS_B(analog_b),\
	.VSSA(vssa1),\
	.VDDA(vdda1),\
	.VSWITCH(vddio),\
	.VDDIO_Q(vddio_q),\
	.VCCHIB(vccd),\
	.VDDIO(vddio),\
	.VCCD(vccd),\
	.VSSIO(vssio),\
	.VSSD(vssd),\
	.VSSIO_Q(vssio_q),

	`define USER2_ABUTMENT_PINS \
	.AMUXBUS_A(analog_a),\
	.AMUXBUS_B(analog_b),\
	.VSSA(vssa2),\
	.VDDA(vdda2),\
	.VSWITCH(vddio),\
	.VDDIO_Q(vddio_q),\
	.VCCHIB(vccd),\
	.VDDIO(vddio),\
	.VCCD(vccd),\
	.VSSIO(vssio),\
	.VSSD(vssd),\
	.VSSIO_Q(vssio_q),

	`define MGMT_ABUTMENT_PINS \
	.AMUXBUS_A(analog_a),\
	.AMUXBUS_B(analog_b),\
	.VSSA(vssa),\
	.VDDA(vdda),\
	.VSWITCH(vddio),\
	.VDDIO_Q(vddio_q),\
	.VCCHIB(vccd),\
	.VDDIO(vddio),\
	.VCCD(vccd),\
	.VSSIO(vssio),\
	.VSSD(vssd),\
	.VSSIO_Q(vssio_q),
`else 
	`define USER1_ABUTMENT_PINS 
	`define USER2_ABUTMENT_PINS 
	`define MGMT_ABUTMENT_PINS 
`endif

// Power pad connection macros (retained for compatibility but unused in SCL180)
`define HVCLAMP_PINS(H,L) \
	.DRN_HVC(H), \
	.SRC_BDY_HVC(L)

`define LVCLAMP_PINS(H1,L1,H2,L2,L3) \
	.BDY2_B2B(L3), \
	.DRN_LVC1(H1), \
	.DRN_LVC2(H2), \
	.SRC_BDY_LVC1(L1), \
	.SRC_BDY_LVC2(L2)

// ==============================================================================
// INPUT PAD MACRO - SCL180 pc3d01_wrapper
// ==============================================================================
// Replaces: sky130_ef_io__gpiov2_pad_wrapped (input-only configuration)
// 
// Parameters:
//   X        - Pad signal name (e.g., gpio)
//   Y        - Core input signal (e.g., gpio_in)
//   CONB_ONE - Constant 1 (unused in SCL180, kept for compatibility)
//   CONB_ZERO- Constant 0 (unused in SCL180, kept for compatibility)
//
// Port Mapping:
//   Sky130: .PAD(X), .IN(Y)
//   SCL180: .PAD(X), .IN(Y)
// ==============================================================================
`define INPUT_PAD(X,Y,CONB_ONE,CONB_ZERO) \
	pc3d01_wrapper X``_pad ( \
		.PAD(X), \
		.IN(Y) \
	)

// ==============================================================================
// INPUT PAD WITH SCHMITT TRIGGER - SCL180 pc3d21
// ==============================================================================
// Alternative input pad with Schmitt trigger for noise immunity
// Useful for clock inputs, reset signals, or noisy environments
//
// Parameters:
//   X - Pad signal name
//   Y - Core input signal
//
// Port Mapping:
//   .PAD(X)  - External pad (3.3V domain)
//   .CIN(Y)  - Core input (1.8V domain, level-shifted internally)
// ==============================================================================
`define INPUT_PAD_SCHMITT(X,Y) \
	pc3d21 X``_pad ( \
		.PAD(X), \
		.CIN(Y) \
	)

// ==============================================================================
// OUTPUT PAD MACRO - SCL180 pt3b02_wrapper
// ==============================================================================
// Replaces: sky130_ef_io__gpiov2_pad_wrapped (output configuration)
//
// Parameters:
//   X          - Pad signal name
//   Y          - Core output signal (data to drive pad)
//   CONB_ONE   - Constant 1 (unused)
//   CONB_ZERO  - Constant 0 (unused)
//   INPUT_DIS  - Input disable (unused in output-only)
//   OUT_EN_N   - Output enable, active low
//
// Port Mapping:
//   Sky130: .PAD(X), .OUT(Y), .OE_N(OUT_EN_N)
//   SCL180: .PAD(X), .IN() (unused readback), .OE_N(OUT_EN_N)
//
// NOTE: pt3b02_wrapper has readback capability (.IN output) but typically unused
//       for pure output pads. The .I input should be connected to core output Y.
// ==============================================================================
// CORRECTED VERSION - Actually connects the output data!
// The wrapper needs modification OR we need to instantiate pt3b02 directly

/*wrapper is as this:

`include "pt3b02.v"
module pt3b02_wrapper(input OUT, output IN, inout PAD, input OE_N);
pt3b02 pad(.CIN(IN), .OEN(OE_N), .I(OUT), .PAD(PAD));

endmodule
*/

`define OUTPUT_PAD(X,Y,CONB_ONE,CONB_ZERO,INPUT_DIS,OUT_EN_N) \
	pt3b02_wrapper X``_pad ( \
		.PAD(X), \
		.OUT(Y), \
		.OE_N(OUT_EN_N), \
                .IN() \
	)


// ==============================================================================
// OUTPUT PAD WITHOUT INPUT DISABLE - SCL180 pt3b02
// ==============================================================================
// Simplified output pad macro (input disable was not used in Sky130 version)
//
// Parameters:
//   X         - Pad signal name
//   Y         - Core output signal
//   OUT_EN_N  - Output enable, active low
//
// Port Mapping:
//   .PAD(X)   - External pad
//   .I(Y)     - Core output data (1.8V → 3.3V level shift)
//   .OEN(OUT_EN_N) - Output enable (active low, 0=enabled, 1=disabled)
//   .CIN()    - Readback path (not used)
// ==============================================================================
`define OUTPUT_NO_INP_DIS_PAD(X,Y,CONB_ONE,CONB_ZERO,OUT_EN_N) \
	pt3b02_wrapper X``_pad ( \
		.PAD(X), \
		.OUT(Y), \
		.OE_N(OUT_EN_N), \
                .IN() \
	)

// ==============================================================================
// BIDIRECTIONAL PAD MACRO - SCL180 pc3b03ed_wrapper
// ==============================================================================
// Replaces: sky130_ef_io__gpiov2_pad_wrapped (bidirectional configuration)
//
// Parameters:
//   X          - Pad signal name
//   Y          - Core input signal (pad → core)
//   CONB_ONE   - Constant 1 (unused)
//   CONB_ZERO  - Constant 0 (unused)
//   Y_OUT      - Core output signal (core → pad)
//   INPUT_DIS  - Input path disable (active high)
//   OUT_EN_N   - Output enable (active low!)
//   MODE       - Drive mode [2:0] for slew rate/strength control
//
// Port Mapping:
//   Sky130 → SCL180:
//   .PAD(X)          → .PAD(X)         (bidirectional external pin)
//   .IN(Y)           → .IN(Y)          (pad to core input)
//   .OUT(Y_OUT)      → .OUT(Y_OUT)     (core to pad output)
//   .INP_DIS(INPUT_DIS) → .INPUT_DIS(INPUT_DIS) (input disable)
//   .OE_N(OUT_EN_N)  → .OUT_EN_N(OUT_EN_N) (output enable, active low)
//   .DM(MODE)        → .dm(MODE)       (drive mode [2:0])
//
// Drive Mode (dm[2:0]):
//   3'b000: Hi-Z (both input and output disabled)
//   3'b001: Weak pull-down
//   3'b010: Weak pull-up
//   3'b011: Strong output (push-pull)
//   3'b110: Open-drain output
//   Others: Reserved
//
// CRITICAL: OUT_EN_N is ACTIVE LOW in both Sky130 and SCL180!
//   OUT_EN_N = 0 → Output ENABLED
//   OUT_EN_N = 1 → Output DISABLED (high-Z)
// ==============================================================================
`define INOUT_PAD(X,Y,CONB_ONE,CONB_ZERO,Y_OUT,INPUT_DIS,OUT_EN_N,MODE) \
	pc3b03ed_wrapper X``_pad ( \
		.PAD(X), \
		.IN(Y), \
		.OUT(Y_OUT), \
		.INPUT_DIS(INPUT_DIS), \
		.OUT_EN_N(OUT_EN_N), \
		.dm(MODE) \
	)

// ==============================================================================
// LEGACY SKY130 MACROS - KEPT FOR REFERENCE BUT NOT USED
// ==============================================================================
// These are the original Sky130 definitions, retained as comments for reference
// during migration. DO NOT USE THESE - they will cause synthesis errors.
// ==============================================================================

/*
`define INPUT_PAD_SKY130(X,Y,CONB_ONE,CONB_ZERO) \
	wire loop_zero_``X; \
	wire loop_one_``X; \
	sky130_ef_io__gpiov2_pad_wrapped X``_pad ( \
	`MGMT_ABUTMENT_PINS \
	`ifndef	TOP_ROUTING \
		.PAD(X), \
	`endif	\
		.OUT(CONB_ZERO), \
		.OE_N(CONB_ONE), \
		.HLD_H_N(loop_one_``X), \
		.ENABLE_H(porb_h), \
		.ENABLE_INP_H(loop_zero_``X), \
		.ENABLE_VDDA_H(porb_h), \
		.ENABLE_VSWITCH_H(loop_zero_``X), \
		.ENABLE_VDDIO(CONB_ONE), \
		.INP_DIS(por), \
		.IB_MODE_SEL(CONB_ZERO), \
		.VTRIP_SEL(CONB_ZERO), \
		.SLOW(CONB_ZERO),	\
		.HLD_OVR(CONB_ZERO), \
		.ANALOG_EN(CONB_ZERO), \
		.ANALOG_SEL(CONB_ZERO), \
		.ANALOG_POL(CONB_ZERO), \
		.DM({CONB_ZERO, CONB_ZERO, CONB_ONE}), \
		.PAD_A_NOESD_H(), \
		.PAD_A_ESD_0_H(), \
		.PAD_A_ESD_1_H(), \
		.IN(Y), \
		.IN_H(), \
		.TIE_HI_ESD(loop_one_``X), \
		.TIE_LO_ESD(loop_zero_``X) )
*/

// `default_nettype wire
