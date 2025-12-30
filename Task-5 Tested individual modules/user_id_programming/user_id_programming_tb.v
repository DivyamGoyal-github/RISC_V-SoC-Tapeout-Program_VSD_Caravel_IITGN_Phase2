`timescale 1ns/1ps
`default_nettype none

module tb_user_id_programming;

    // --------------------------------------------------
    // Test parameter
    // --------------------------------------------------
    localparam [31:0] TEST_USER_PROJECT_ID = 32'hA5A5_3C3C;

    // --------------------------------------------------
    // DUT signals
    // --------------------------------------------------
    wire [31:0] mask_rev;

    // --------------------------------------------------
    // DUT instantiation
    // --------------------------------------------------
    user_id_programming #(
        .USER_PROJECT_ID(TEST_USER_PROJECT_ID)
    ) dut (
        .mask_rev(mask_rev)
    );

    // --------------------------------------------------
    // Test sequence
    // --------------------------------------------------
    initial begin
        $display("=======================================");
        $display(" USER_ID_PROGRAMMING TEST STARTED ");
        $display(" Expected USER_PROJECT_ID = 0x%08h", TEST_USER_PROJECT_ID);
        $display("=======================================");

        #10; // allow signals to settle

        if (mask_rev === TEST_USER_PROJECT_ID) begin
            $display("[PASS] mask_rev matched USER_PROJECT_ID");
            $display("       mask_rev = 0x%08h", mask_rev);
        end else begin
            $display("[FAIL] mask_rev mismatch!");
            $display("       Expected = 0x%08h", TEST_USER_PROJECT_ID);
            $display("       Got      = 0x%08h", mask_rev);
        end

        $display("=======================================");
        $finish;
    end

endmodule

`default_nettype wire

