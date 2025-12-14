// Simple digital POR generator (synthesizable)
// - Asserts reset_n_out LOW when rst_n_in is low (async).
// - After rst_n_in goes HIGH and clk is running,
//   holds reset_n_out low for N cycles, then releases.

module digital_por #(
    parameter integer N_CYCLES = 1024  // adjust based on clock freq & desired delay
)(
    input  wire clk,        // system clock (must be running when you want POR to end)
    input  wire rst_n_in,   // async reset / power-good input (active low)
    output wire reset_n_out // generated reset (active low)
);

    // 1. Synchronize rst_n_in into clk domain
    reg [1:0] rst_sync;
    always @(posedge clk or negedge rst_n_in) begin
        if (!rst_n_in)
            rst_sync <= 2'b00;
        else
            rst_sync <= {rst_sync[0], 1'b1};
    end

    wire rst_n_sync = rst_sync[1];

    // 2. Counter for reset stretching
    localparam integer CNT_WIDTH = $clog2(N_CYCLES+1);

    reg [CNT_WIDTH-1:0] cnt;
    reg                 por_n_int;

    always @(posedge clk or negedge rst_n_sync) begin
        if (!rst_n_sync) begin
            cnt      <= {CNT_WIDTH{1'b0}};
            por_n_int <= 1'b0;  // hold reset active
        end else begin
            if (cnt != N_CYCLES[CNT_WIDTH-1:0]) begin
                cnt      <= cnt + 1'b1;
                por_n_int <= 1'b0;  // still in reset
            end else begin
                por_n_int <= 1'b1;  // release reset
            end
        end
    end

    assign reset_n_out = por_n_int;

endmodule
