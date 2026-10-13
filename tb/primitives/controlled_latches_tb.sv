// File: controlled_latches_tb.sv
// Project: trama-efpga
// Author: luke
// Description: Self-checking reset/set latch control priority and storage tests.

module controlled_latches_tb;
    timeunit 1ns;
    timeprecision 1ps;

    logic data_tb;
    logic enable_tb;
    logic reset_n_tb;
    logic set_n_tb;
    wire reset_result_tb;
    wire set_result_tb;

    latch_reset latch_reset_dut (
        .data_in(data_tb), .enable_in(enable_tb),
        .reset_n_in(reset_n_tb), .data_out(reset_result_tb)
    );
    latch_set latch_set_dut (
        .data_in(data_tb), .enable_in(enable_tb),
        .set_n_in(set_n_tb), .data_out(set_result_tb)
    );

    function automatic logic four_state_tb(input int index_var_tb);
        case (index_var_tb)
            0: four_state_tb = 1'b0;
            1: four_state_tb = 1'b1;
            2: four_state_tb = 1'bx;
            3: four_state_tb = 1'bz;
            default: four_state_tb = 1'bx;
        endcase
    endfunction

    task automatic check_latches_tb(
        input logic expected_reset_in_tb,
        input logic expected_set_in_tb
    );
        if (reset_result_tb !== expected_reset_in_tb)
            $fatal(1, "Reset latch: expected %b, got %b",
                expected_reset_in_tb, reset_result_tb);
        if (set_result_tb !== expected_set_in_tb)
            $fatal(1, "Set latch: expected %b, got %b",
                expected_set_in_tb, set_result_tb);
    endtask

    // Watchdog for a stalled or accidentally extended test sequence.
    initial begin
        #10000;
        $fatal(1, "Controlled latch simulation timed out");
    end

    initial begin
        // Inactive controls do not initialize an unwritten, disabled latch.
        data_tb = 1'b0;
        enable_tb = 1'b0;
        reset_n_tb = 1'b1;
        set_n_tb = 1'b1;
        #1;
        check_latches_tb(1'bx, 1'bx);

        // Assert asynchronously while disabled, then check priority over X/Z.
        reset_n_tb = 1'b0;
        set_n_tb = 1'b0;
        #1;
        check_latches_tb(1'b0, 1'b1);
        for (int pattern_var_tb = 0; pattern_var_tb < 16; pattern_var_tb++) begin
            data_tb = four_state_tb(pattern_var_tb % 4);
            enable_tb = four_state_tb(pattern_var_tb / 4);
            #1;
            check_latches_tb(1'b0, 1'b1);
        end

        // Release while disabled retains the forced values despite data changes.
        enable_tb = 1'b0;
        data_tb = 1'b1;
        #1;
        reset_n_tb = 1'b1;
        set_n_tb = 1'b1;
        #1;
        check_latches_tb(1'b0, 1'b1);
        data_tb = 1'b0;
        #1;
        check_latches_tb(1'b0, 1'b1);

        // Transparent latches propagate all four states and recover on known data.
        enable_tb = 1'b1;
        #1;
        check_latches_tb(1'b0, 1'b0);
        for (int pattern_var_tb = 0; pattern_var_tb < 4; pattern_var_tb++) begin
            data_tb = four_state_tb(pattern_var_tb);
            #1;
            check_latches_tb(four_state_tb(pattern_var_tb), four_state_tb(pattern_var_tb));
        end
        data_tb = 1'b1;
        #1;
        check_latches_tb(1'b1, 1'b1);

        // Both binary stored values survive all four-state input changes.
        for (int stored_var_tb = 0; stored_var_tb < 2; stored_var_tb++) begin
            enable_tb = 1'b1;
            data_tb = four_state_tb(stored_var_tb);
            #1;
            check_latches_tb(four_state_tb(stored_var_tb), four_state_tb(stored_var_tb));
            enable_tb = 1'b0;
            #1;
            for (int pattern_var_tb = 0; pattern_var_tb < 4; pattern_var_tb++) begin
                data_tb = four_state_tb(pattern_var_tb);
                #1;
                check_latches_tb(four_state_tb(stored_var_tb), four_state_tb(stored_var_tb));
            end
        end

        // Controls override transparent data; each release resumes transparency.
        enable_tb = 1'b1;
        data_tb = 1'b1;
        #1;
        check_latches_tb(1'b1, 1'b1);
        reset_n_tb = 1'b0;
        set_n_tb = 1'b0;
        #1;
        check_latches_tb(1'b0, 1'b1);
        reset_n_tb = 1'b1;
        #1;
        check_latches_tb(1'b1, 1'b1);
        data_tb = 1'b0;
        #1;
        check_latches_tb(1'b0, 1'b1);
        set_n_tb = 1'b1;
        #1;
        check_latches_tb(1'b0, 1'b0);

        $display("PASS: reset/set latches (startup, priority, transparency, hold, release)");
        $finish;
    end
endmodule

// End of file
