// File: config_memory_element_invalid_tb.sv
// Project: trama-efpga
// Author: luke
// Description: Expected-failure tests for invalid configuration dimensions.

module config_memory_element_invalid_tb #(
    parameter int CASE_TB = 0
);
    timeunit 1ns;
    timeprecision 1ps;
    localparam int NUM_BITS_TB = CASE_TB == 0 ? 0 : CASE_TB == 1 ? -1 : 10;
    localparam int NUM_COLUMNS_TB = CASE_TB == 2 ? 0 : CASE_TB == 3 ? -1 : 4;
    localparam int NUM_ROWS_TB = CASE_TB == 4 ? 0 : CASE_TB == 5 ? -1 : CASE_TB == 6 ? 2 : 4;
    // Match the declared (even invalid) ranges to avoid port-width warnings.
    wire [NUM_BITS_TB-1:0] result_tb;
    wire [NUM_COLUMNS_TB-1:0] data_tb = '0;
    wire [NUM_ROWS_TB-1:0] enable_tb = '0;
    generate
        if (CASE_TB < 4) begin : default_rows_tb
            // Exercise the guarded default row expression for invalid bits
            // and columns, including division-by-zero avoidance.
            config_memory_element #(
                .NUM_BITS(NUM_BITS_TB), .NUM_COLUMNS(NUM_COLUMNS_TB)
            ) config_memory_element_dut (
                .program_data_in(data_tb), .program_enable_in(1'b0), .config_out(result_tb)
            );
        end else begin : explicit_rows_tb
            config_memory_element #(
                .NUM_BITS(NUM_BITS_TB), .NUM_COLUMNS(NUM_COLUMNS_TB), .NUM_ROWS(NUM_ROWS_TB)
            ) config_memory_element_dut (
                .program_data_in(data_tb), .program_enable_in(enable_tb), .config_out(result_tb)
            );
        end
    endgenerate
    initial begin
        #1;
        $fatal(1, "invalid configuration was accepted");
    end
endmodule

// End of file
