// File: basic_primitives_tb.sv
// Project: trama-efpga
// Author: luke
// Description: Self-checking four-state tests for basic behavioral primitives.

module basic_primitives_tb;
    timeunit 1ns;
    timeprecision 1ps;

    logic [1:0] mux2_data_tb;
    logic       mux2_select_tb;
    wire        mux2_result_tb;
    logic [3:0] mux4_data_tb;
    logic [1:0] mux4_select_tb;
    wire        mux4_result_tb;
    logic       latch_data_tb;
    logic       latch_enable_tb;
    wire        latch_result_tb;

    mux2 mux2_dut (
        .a0_in(mux2_data_tb[0]), .a1_in(mux2_data_tb[1]),
        .select_in(mux2_select_tb), .data_out(mux2_result_tb)
    );

    mux4 mux4_dut (
        .a0_in(mux4_data_tb[0]), .a1_in(mux4_data_tb[1]),
        .a2_in(mux4_data_tb[2]), .a3_in(mux4_data_tb[3]),
        .select_in(mux4_select_tb), .data_out(mux4_result_tb)
    );

    latch latch_dut (
        .data_in(latch_data_tb), .enable_in(latch_enable_tb),
        .data_out(latch_result_tb)
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

    // Independent reference: enumerate every binary address consistent with
    // the select bits, then merge the candidate data values by consensus.
    function automatic logic mux_reference_tb(
        input logic [3:0] data_in_tb,
        input logic [1:0] select_in_tb,
        input int input_count_var_tb
    );
        bit found_var_tb;
        bit compatible_var_tb;
        logic result_var_tb;
        found_var_tb = 1'b0;
        result_var_tb = 1'bx;
        for (int address_var_tb = 0; address_var_tb < input_count_var_tb; address_var_tb++) begin
            compatible_var_tb = 1'b1;
            for (int bit_var_tb = 0; bit_var_tb < 2; bit_var_tb++) begin
                if (select_in_tb[bit_var_tb] === 1'b0 && ((address_var_tb >> bit_var_tb) & 1))
                    compatible_var_tb = 1'b0;
                if (select_in_tb[bit_var_tb] === 1'b1 && !((address_var_tb >> bit_var_tb) & 1))
                    compatible_var_tb = 1'b0;
            end
            if (compatible_var_tb) begin
                if (!found_var_tb) begin
                    result_var_tb = data_in_tb[address_var_tb];
                    found_var_tb = 1'b1;
                end else if (result_var_tb !== data_in_tb[address_var_tb]) begin
                    result_var_tb = 1'bx;
                end
            end
        end
        mux_reference_tb = result_var_tb;
    endfunction

    task automatic check_latch_tb(input logic expected_in_tb);
        if (latch_result_tb !== expected_in_tb)
            $fatal(1, "Latch: expected %b, got %b", expected_in_tb, latch_result_tb);
    endtask

    // Watchdog: fail if the test sequence does not finish within 10,000 ns.
    initial begin
        #10000;
        $fatal(1, "Simulation timed out");
    end

    initial begin
        // An unwritten latch must start unknown, even with known input data.
        latch_enable_tb = 1'b0;
        latch_data_tb = 1'b0;
        #1;
        check_latch_tb(1'bx);

        // Exhaust all four-state data/select combinations for the 2:1 mux.
        for (int pattern_var_tb = 0; pattern_var_tb < 64; pattern_var_tb++) begin
            mux2_data_tb[0] = four_state_tb(pattern_var_tb % 4);
            mux2_data_tb[1] = four_state_tb((pattern_var_tb / 4) % 4);
            mux2_select_tb = four_state_tb((pattern_var_tb / 16) % 4);
            #1;
            if (mux2_result_tb !== mux_reference_tb({2'b00, mux2_data_tb}, {1'b0, mux2_select_tb}, 2))
                $fatal(1, "mux2 mismatch at pattern %0d", pattern_var_tb);
        end

        // Exhaust the 4:1 mux, including partial unknown selects and consensus.
        for (int pattern_var_tb = 0; pattern_var_tb < 4096; pattern_var_tb++) begin
            for (int bit_var_tb = 0; bit_var_tb < 4; bit_var_tb++)
                mux4_data_tb[bit_var_tb] = four_state_tb((pattern_var_tb >> (2 * bit_var_tb)) & 3);
            mux4_select_tb[0] = four_state_tb((pattern_var_tb >> 8) & 3);
            mux4_select_tb[1] = four_state_tb((pattern_var_tb >> 10) & 3);
            #1;
            if (mux4_result_tb !== mux_reference_tb(mux4_data_tb, mux4_select_tb, 4))
                $fatal(1, "mux4 mismatch at pattern %0d", pattern_var_tb);
        end

        // Enabled latch: capture the current input and follow subsequent changes.
        latch_enable_tb = 1'b1;
        #1;
        check_latch_tb(1'b0);
        latch_data_tb = 1'b1;
        #1;
        check_latch_tb(1'b1);
        // Disabled latch: retain a stored one despite binary, X, and Z inputs.
        latch_enable_tb = 1'b0;
        #1;
        latch_data_tb = 1'b0;
        #1;
        check_latch_tb(1'b1);
        latch_data_tb = 1'bx;
        #1;
        check_latch_tb(1'b1);
        latch_data_tb = 1'bz;
        #1;
        check_latch_tb(1'b1);
        // Enabled unknown data propagates; a later known write restores certainty.
        latch_enable_tb = 1'b1;
        latch_data_tb = 1'bx;
        #1;
        check_latch_tb(1'bx);
        latch_data_tb = 1'b0;
        #1;
        check_latch_tb(1'b0);
        // Check retention of a stored zero as well as the earlier stored one.
        latch_enable_tb = 1'b0;
        #1;
        latch_data_tb = 1'b1;
        #1;
        check_latch_tb(1'b0);

        $display("PASS: mux2 (64 patterns), mux4 (4096 patterns), latch startup/transparency/hold");
        $finish;
    end
endmodule

// End of file
