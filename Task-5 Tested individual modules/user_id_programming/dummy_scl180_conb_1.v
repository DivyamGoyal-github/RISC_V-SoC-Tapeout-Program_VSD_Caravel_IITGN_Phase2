/**
 * conb: Constant value, low, high outputs.
 *
 * Verilog simulation functional model.
 */

`default_nettype none

module dummy_scl180_conb_1 (
`ifndef USE_POWER_PINS
    input wire VPWR,   // Power
    input wire VPB,    // Power bulk
    input wire VNB,    // Ground bulk
    input wire VGND,   // Ground
`endif
    output wire HI,
    output wire LO
);

    // Constant behavior
    assign HI = 1'b1;
    assign LO = 1'b0;

endmodule

`default_nettype wire

