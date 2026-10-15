// File: config_memory_element_tb.sv
// Project: trama-efpga
// Author: luke
// Description: Self-checking configuration mesh tests across mesh shapes.

module config_memory_element_case_tb #(
    parameter int NUM_BITS_TB = 1,
    parameter int NUM_COLUMNS_TB = 1,
    parameter int NUM_ROWS_TB = 1 + (NUM_BITS_TB - 1) / NUM_COLUMNS_TB
) (
    output logic done_out_tb
);
    timeunit 1ns;
    timeprecision 1ps;

    logic [NUM_COLUMNS_TB-1:0] data_tb;
    logic [NUM_ROWS_TB-1:0] enable_tb;
    wire [NUM_BITS_TB-1:0] result_tb;
    logic [NUM_BITS_TB-1:0] expected_tb;

    // Leave NUM_ROWS at its default to exercise inferred row counts.
    config_memory_element #(
        .NUM_BITS(NUM_BITS_TB), .NUM_COLUMNS(NUM_COLUMNS_TB)
    ) config_memory_element_dut (
        .program_data_in(data_tb), .program_enable_in(enable_tb), .config_out(result_tb)
    );

    task automatic check_tb(input string phase_tb);
        #1;
        if (result_tb !== expected_tb)
            $fatal(1, "%s: bits=%0d columns=%0d expected=%b actual=%b",
                phase_tb, NUM_BITS_TB, NUM_COLUMNS_TB, expected_tb, result_tb);
    endtask

    // Reference walks physical rows/columns and packs each existing position.
    task automatic capture_tb;
        for (int row_var_tb = 0; row_var_tb < NUM_ROWS_TB; row_var_tb++)
            for (int col_var_tb = 0; col_var_tb < NUM_COLUMNS_TB; col_var_tb++)
                if (enable_tb[row_var_tb] &&
                    row_var_tb * NUM_COLUMNS_TB + col_var_tb < NUM_BITS_TB)
                    expected_tb[row_var_tb * NUM_COLUMNS_TB + col_var_tb] = data_tb[col_var_tb];
    endtask

    initial begin
        done_out_tb = 0;
        enable_tb = '0;
        data_tb = '0;
        expected_tb = 'x;
        check_tb("unknown startup");

        // Select each row independently; change every column independently.
        for (int row_var_tb = 0; row_var_tb < NUM_ROWS_TB; row_var_tb++) begin
            enable_tb = '0;
            enable_tb[row_var_tb] = 1;
            data_tb = '0;
            capture_tb();
            check_tb("row selection");
            for (int col_var_tb = 0; col_var_tb < NUM_COLUMNS_TB; col_var_tb++) begin
                data_tb[col_var_tb] = 1;
                capture_tb();
                check_tb("transparent column walking one");
                data_tb[col_var_tb] = 0;
                capture_tb();
                check_tb("transparent column walking zero");
            end
            data_tb = {NUM_COLUMNS_TB{row_var_tb[0]}};
            capture_tb();
            check_tb("distinct row pattern");
            enable_tb = '0;
            data_tb = '1;
            check_tb("disabled row retention");
        end

        // All enabled rows share the same column data, including X and Z.
        enable_tb = '1;
        for (int pattern_var_tb = 0; pattern_var_tb < 4; pattern_var_tb++) begin
            case (pattern_var_tb)
                0: data_tb = '0;
                1: data_tb = '1;
                2: data_tb = 'x;
                3: data_tb = 'z;
            endcase
            capture_tb();
            check_tb("simultaneous rows / four-state transparency");
            enable_tb = '0;
            data_tb = '0;
            check_tb("four-state retention");
            enable_tb = '1;
        end
        data_tb = '1;
        capture_tb();
        check_tb("known-data recovery");
        enable_tb = '0;
        data_tb = 'x;
        check_tb("hold known data against X");
        data_tb = 'z;
        check_tb("hold known data against Z");
        done_out_tb = 1;
    end
endmodule

module config_memory_element_tb;
    timeunit 1ns;
    timeprecision 1ps;
    wire [5:0] done_tb;

    config_memory_element_case_tb single_bit_dut (.done_out_tb(done_tb[0]));
    config_memory_element_case_tb #(.NUM_BITS_TB(4), .NUM_COLUMNS_TB(4))
        single_row_dut (.done_out_tb(done_tb[1]));
    config_memory_element_case_tb #(.NUM_BITS_TB(4), .NUM_COLUMNS_TB(1))
        single_column_dut (.done_out_tb(done_tb[2]));
    config_memory_element_case_tb #(.NUM_BITS_TB(12), .NUM_COLUMNS_TB(4))
        full_mesh_dut (.done_out_tb(done_tb[3]));
    config_memory_element_case_tb #(.NUM_BITS_TB(10), .NUM_COLUMNS_TB(4))
        partial_mesh_dut (.done_out_tb(done_tb[4]));
    config_memory_element_case_tb #(.NUM_BITS_TB(2), .NUM_COLUMNS_TB(4))
        partial_single_row_dut (.done_out_tb(done_tb[5]));

    initial begin
        wait (&done_tb);
        $display("PASS: config_memory_element (6 mesh shapes, mapping, transparency, hold, X/Z)");
        $finish;
    end
    initial begin
        #10000;
        $fatal(1, "config_memory_element test timeout");
    end
endmodule

// End of file
