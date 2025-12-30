`timescale 1ns/1ps
`default_nettype wire

// ------------------------------------------------------------
// Testbench for clock_div
// ------------------------------------------------------------
module tb_clock_div;

    // --------------------------------------------------------
    // Parameters
    // --------------------------------------------------------
    localparam SIZE = 3;

    // --------------------------------------------------------
    // DUT signals
    // --------------------------------------------------------
    reg                 clk_in;
    reg                 reset_n;
    reg  [SIZE-1:0]     N;
    wire                clk_out;

    // --------------------------------------------------------
    // Instantiate DUT
    // --------------------------------------------------------
    clock_div #(
        .SIZE(SIZE)
    ) dut (
        .in      (clk_in),
        .out     (clk_out),
        .N       (N),
        .reset_n (reset_n)
    );

    // --------------------------------------------------------
    // Input clock generation (100 MHz)
    // --------------------------------------------------------
    initial begin
        clk_in = 0;
        forever #5 clk_in = ~clk_in;   // 10 ns period
    end

    // --------------------------------------------------------
    // Monitor divided clock
    // --------------------------------------------------------
    integer edge_count;
    time last_edge;

    always @(posedge clk_out) begin
        edge_count = edge_count + 1;
        $display("[%0t] clk_out posedge, count=%0d", $time, edge_count);
    end

    // --------------------------------------------------------
    // Test sequence
    // --------------------------------------------------------
    initial begin
        edge_count = 0;
        last_edge  = 0;

        // ----------------------------
        // Apply reset
        // ----------------------------
        reset_n = 0;
        N       = 3'b000;   // don't care during reset
        #50;

        reset_n = 1;
        $display("\n--- Released reset ---\n");

        // ----------------------------
        // Test divide-by-1 (bypass)
        // N = 000
        // ----------------------------
        N = 3'b000;
        $display("\nTesting divide-by-1 (bypass)");
        #200;

        // ----------------------------
        // Test divide-by-2 (even)
        // N = 010
        // ----------------------------
        N = 3'b010;
        $display("\nTesting divide-by-2");
        #400;

        // ----------------------------
        // Test divide-by-4 (even)
        // N = 100
        // ----------------------------
        N = 3'b100;
        $display("\nTesting divide-by-4");
        #600;

        // ----------------------------
        // Test divide-by-3 (odd)
        // N = 011
        // ----------------------------
        N = 3'b011;
        $display("\nTesting divide-by-3");
        #600;

        // ----------------------------
        // Test divide-by-5 (odd)
        // N = 101
        // ----------------------------
        N = 3'b101;
        $display("\nTesting divide-by-5");
        #800;

        // ----------------------------
        // Runtime divider change test
        // ----------------------------
        $display("\nTesting runtime divider change (odd → even)");
        N = 3'b011;  // ÷3
        #300;
        N = 3'b010;  // ÷2 (live change)
        #300;

        // ----------------------------
        // Finish
        // ----------------------------
        $display("\n--- TEST COMPLETED SUCCESSFULLY ---\n");
        $finish;
    end

    // --------------------------------------------------------
    // Safety checks (X / Z detection)
    // --------------------------------------------------------
    always @(clk_out) begin
        if (^clk_out === 1'bX) begin
            $display("ERROR: clk_out is X at time %0t", $time);
            $stop;
        end
    end

endmodule

`default_nettype wire

