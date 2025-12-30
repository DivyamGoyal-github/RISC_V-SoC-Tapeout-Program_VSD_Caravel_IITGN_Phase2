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
// MPRJ_IO - Multi-Project IO Pad Array for SCL180
// ==============================================================================
// This module instantiates the user project GPIO pads using SCL180 pc3b03ed
// bidirectional pads. Replaces Sky130 gpiov2_pad_wrapped arrays.
//
// Signal Mapping Changes (Sky130 → SCL180):
//   - Most Sky130 configuration signals (enh, ib_mode_sel, vtrip_sel, etc.) 
//     are not used in SCL180 and are ignored
//   - io_in_3v3 (Sky130's IN_H) is tied to io_in for compatibility
//   - analog_io/analog_noesd_io are connected directly to io pads (no separate
//     analog routing in SCL180 like Sky130's PAD_A_NOESD_H/PAD_A_ESD_0_H)
// ==============================================================================

// `default_nettype none

module mprj_io #(
    parameter AREA1PADS = `MPRJ_IO_PADS_1,
    parameter TOTAL_PADS = `MPRJ_IO_PADS
) (
    // Power supplies (passed through, not used in RTL)
    inout vddio,
    inout vssio,
    inout vdda,
    inout vssa,
    inout vccd,
    inout vssd,
    inout vdda1,
    inout vdda2,
    inout vssa1,
    inout vssa2,

    // Sky130 compatibility signals (unused in SCL180)
    input vddio_q,          // Unused in SCL180
    input vssio_q,          // Unused in SCL180
    input analog_a,         // Unused in SCL180
    input analog_b,         // Unused in SCL180
    //input porb_h,
    input rstn_h,           // Unused in SCL180
    input reset_n_core_h,   // Master reset (active-high)
    input [TOTAL_PADS-1:0] vccd_conb,    // Unused
    input [TOTAL_PADS-1:0] enh,          // Unused (Sky130 enable_h)
    input [TOTAL_PADS-1:0] ib_mode_sel,  // Unused (Sky130 input buffer mode)
    input [TOTAL_PADS-1:0] vtrip_sel,    // Unused (Sky130 trip point)
    input [TOTAL_PADS-1:0] slow_sel,     // Unused (Sky130 slew rate)
    input [TOTAL_PADS-1:0] holdover,     // Unused (Sky130 hold)
    input [TOTAL_PADS-1:0] analog_en,    // Unused (Sky130 analog enable)
    input [TOTAL_PADS-1:0] analog_sel,   // Unused (Sky130 analog select)
    input [TOTAL_PADS-1:0] analog_pol,   // Unused (Sky130 analog polarity)

    // Active GPIO signals
    inout [TOTAL_PADS-1:0] io,           // Bidirectional pads
    input [TOTAL_PADS-1:0] io_out,       // Output data (core → pad)
    input [TOTAL_PADS-1:0] oeb,          // Output enable, active low
    input [TOTAL_PADS-1:0] inp_dis,      // Input disable, active high
    input [TOTAL_PADS*3-1:0] dm,         // Drive mode [2:0] per pad
    output [TOTAL_PADS-1:0] io_in,       // Input data (pad → core, 1.8V)
    output [TOTAL_PADS-1:0] io_in_3v3,   // Input data (3.3V copy for Sky130 compat)

    // Analog IO (direct connection to pads for SCL180)
    // ==============================================================================
    // ANALOG IO HANDLING
    // ==============================================================================
    // NOTE: analog_io and analog_noesd_io are left unconnected (floating)
    // In Sky130, these connected to PAD_A_NOESD_H and PAD_A_ESD_0_H on the pads
    // SCL180 has no equivalent - if analog access is needed, connect directly
    // to io[TOTAL_PADS-3:7] at the top level (chip_io.v)
    // ==============================================================================
    //inout [TOTAL_PADS-10:0] analog_io,        // Analog pad access
    //inout [TOTAL_PADS-10:0] analog_noesd_io   // No-ESD analog (same as analog_io in SCL180)
    // Changed from inout to output since SCL180 has no separate analog routing
    output [TOTAL_PADS-10:0] analog_io,        // Analog pad access (mirror of io)
    output [TOTAL_PADS-10:0] analog_noesd_io   // No-ESD analog (same as analog_io in SCL180)
);
    // wire [TOTAL_PADS-1:0] loop0_io;
    // wire [TOTAL_PADS-1:0] loop1_io;
    // wire [6:0] no_connect_1a, no_connect_1b;
    // wire [1:0] no_connect_2a, no_connect_2b;

    // ==============================================================================
    // USER AREA 1 GPIO PADS (pc3b03ed_wrapper)
    // ==============================================================================
    // Instantiates AREA1PADS bidirectional pads for user project area 1
    // These are the first N pads in the array
    // ==============================================================================
    pc3b03ed_wrapper area1_io_pad [AREA1PADS - 1:0] (
        .PAD(io[AREA1PADS - 1:0]),               // External pads
        .OUT(io_out[AREA1PADS - 1:0]),           // Core → pad output
        .IN(io_in[AREA1PADS - 1:0]),             // Pad → core input
        .OUT_EN_N(oeb[AREA1PADS - 1:0]),         // Output enable (active low)
        .INPUT_DIS(inp_dis[AREA1PADS - 1:0]),    // Input disable (active high)
        .dm(dm[AREA1PADS*3 - 1:0])               // Drive mode [2:0] per pad
    );

    // ==============================================================================
    // USER AREA 2 GPIO PADS (pc3b03ed_wrapper)
    // ==============================================================================
    // Instantiates remaining pads for user project area 2
    // These are pads [AREA1PADS : TOTAL_PADS-1]
    // ==============================================================================
    pc3b03ed_wrapper area2_io_pad [TOTAL_PADS - AREA1PADS - 1:0] (
        .PAD(io[TOTAL_PADS - 1:AREA1PADS]),
        .OUT(io_out[TOTAL_PADS - 1:AREA1PADS]),
        .IN(io_in[TOTAL_PADS - 1:AREA1PADS]),
        .OUT_EN_N(oeb[TOTAL_PADS - 1:AREA1PADS]),
        .INPUT_DIS(inp_dis[TOTAL_PADS - 1:AREA1PADS]),
        .dm(dm[TOTAL_PADS*3 - 1:AREA1PADS*3])
    );

    // ==============================================================================
    // COMPATIBILITY SIGNALS
    // ==============================================================================
    
    // Sky130 had separate 3.3V level input (IN_H)
    // SCL180 only has 1.8V input (IN), so we just copy it
    assign io_in_3v3 = io_in;

    // Sky130 had separate analog routing (PAD_A_NOESD_H, PAD_A_ESD_0_H)
    // SCL180 doesn't have this - analog signals just use the regular PAD
    // We connect analog_io directly to the io pads (skipping first 7 and last 3)
    assign analog_io = io[TOTAL_PADS - 3:7];
    
    // In Sky130, NOESD was a separate path without ESD protection
    // SCL180 doesn't distinguish - all pads have ESD
    // So we just connect it to the same pads
    assign analog_noesd_io = io[TOTAL_PADS - 3:7];

endmodule

// `default_nettype wire
