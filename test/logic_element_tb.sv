// File: logic_element_tb.sv
// Project: trama-efpga
// Author: luke
// Description: Self-checking LUT addressing, four-state, and FF-path tests.

module logic_element_tb;
    timeunit 1ns;
    timeprecision 1ps;
    logic [3:0] address_tb;
    logic [15:0] config_tb;
    logic select_tb;
    logic data_tb;
    logic clk_tb;
    logic reset_n_tb;
    logic lut_result_tb;
    logic ff_result_tb;

    logic_element logic_element_dut (
        .clk_in(clk_tb), .reset_n_in(reset_n_tb),
        .lut_data_in(address_tb), .ff_data_in(data_tb),
        .lut_out(lut_result_tb), .ff_out(ff_result_tb),
        .lut_config_in(config_tb), .ff_select_config_in(select_tb)
    );

    function automatic logic four_state_tb(input int value_tb);
        case (value_tb)
            0: four_state_tb = 0;
            1: four_state_tb = 1;
            2: four_state_tb = 1'bx;
            3: four_state_tb = 1'bz;
            default: four_state_tb = 1'bx;
        endcase
    endfunction

    // Enumerate compatible addresses and merge by consensus, independently
    // of the DUT's two-stage mux tree. X and Z address bits admit 0 and 1.
    function automatic logic lut_reference_tb(
        input logic [15:0] table_tb, input logic [3:0] index_tb
    );
        bit seen_tb;
        bit compatible_tb;
        seen_tb = 0;
        lut_reference_tb = 1'bx;
        for (int candidate_var_tb = 0; candidate_var_tb < 16; candidate_var_tb++) begin
            compatible_tb = 1;
            for (int bit_var_tb = 0; bit_var_tb < 4; bit_var_tb++) begin
                if ((index_tb[bit_var_tb] === 1'b0 || index_tb[bit_var_tb] === 1'b1)
                    && index_tb[bit_var_tb] !== candidate_var_tb[bit_var_tb])
                    compatible_tb = 0;
            end
            if (compatible_tb) begin
                if (!seen_tb)
                    lut_reference_tb = table_tb[candidate_var_tb];
                else if (lut_reference_tb !== table_tb[candidate_var_tb])
                    lut_reference_tb = 1'bx;
                seen_tb = 1;
            end
        end
    endfunction

    task automatic check_tb(
        input logic expected_lut_tb, input logic expected_ff_tb, input string phase_tb
    );
        #1;
        if (lut_result_tb !== expected_lut_tb || ff_result_tb !== expected_ff_tb)
            $fatal(1, "%s: address=%b config=%h select=%b LUT expected/actual=%b/%b FF=%b/%b",
                phase_tb, address_tb, config_tb, select_tb,
                expected_lut_tb, lut_result_tb, expected_ff_tb, ff_result_tb);
    endtask

    task automatic capture_tb(input logic expected_tb, input string phase_tb);
        clk_tb = 0;
        #1;
        clk_tb = 1;
        check_tb(lut_reference_tb(config_tb, address_tb), expected_tb, phase_tb);
        clk_tb = 0;
        #1;
    endtask

    initial begin
        clk_tb = 0;
        reset_n_tb = 1;
        config_tb = '0;
        address_tb = '0;
        select_tb = 0;
        data_tb = 0;
        check_tb(0, 1'bx, "unknown FF startup / LUT only");
        reset_n_tb = 0;
        check_tb(0, 0, "initial asynchronous reset");

        // Walking truth-table bit: every address and every configuration bit.
        for (int config_var_tb = 0; config_var_tb < 16; config_var_tb++) begin
            config_tb = 16'b1 << config_var_tb;
            for (int address_var_tb = 0; address_var_tb < 16; address_var_tb++) begin
                address_tb = address_var_tb[3:0];
                check_tb(address_var_tb == config_var_tb, 0, "walking configuration bit");
            end
        end

        // Constant zero/one, XOR of four inputs, AND, and OR tables.
        for (int table_var_tb = 0; table_var_tb < 5; table_var_tb++) begin
            case (table_var_tb)
                0: config_tb = 16'h0000;
                1: config_tb = 16'hffff;
                2: config_tb = 16'h6996;
                3: config_tb = 16'h8000;
                4: config_tb = 16'hfffe;
            endcase
            // All 256 four-state addresses include binary and unknown cases.
            for (int pattern_var_tb = 0; pattern_var_tb < 256; pattern_var_tb++) begin
                for (int bit_var_tb = 0; bit_var_tb < 4; bit_var_tb++)
                    address_tb[bit_var_tb] = four_state_tb((pattern_var_tb >> (2 * bit_var_tb)) & 3);
                check_tb(lut_reference_tb(config_tb, address_tb), 0, "four-state LUT address");
            end
        end

        address_tb = 4'd5;
        config_tb = '0;
        check_tb(0, 0, "live config before change");
        config_tb[5] = 1;
        check_tb(1, 0, "live config changes LUT without clock");
        reset_n_tb = 1;
        select_tb = 0;
        data_tb = 0;
        capture_tb(1, "LUT feeding FF");
        config_tb[5] = 0;
        check_tb(0, 1, "LUT changes / FF holds between edges");
        capture_tb(0, "LUT zero capture");

        select_tb = 1;
        data_tb = 1;
        capture_tb(1, "external FF input independent of LUT");
        config_tb = '1;
        data_tb = 0;
        check_tb(1, 1, "independent inputs change while FF holds");
        capture_tb(0, "external zero while LUT one");
        data_tb = 1;
        capture_tb(1, "external one");
        reset_n_tb = 0;
        check_tb(1, 0, "async reset leaves LUT unchanged");
        reset_n_tb = 1;
        check_tb(1, 0, "reset release alone does not capture");

        // All four-state mux input/select combinations, through the FF.
        for (int lut_var_tb = 0; lut_var_tb < 4; lut_var_tb++) begin
            config_tb = {16{four_state_tb(lut_var_tb)}};
            for (int data_var_tb = 0; data_var_tb < 4; data_var_tb++) begin
                data_tb = four_state_tb(data_var_tb);
                for (int select_var_tb = 0; select_var_tb < 4; select_var_tb++) begin
                    select_tb = four_state_tb(select_var_tb);
                    if (select_var_tb == 0)
                        capture_tb(four_state_tb(lut_var_tb), "mux select LUT");
                    else if (select_var_tb == 1)
                        capture_tb(data_tb, "mux select external");
                    else if (four_state_tb(lut_var_tb) === data_tb)
                        capture_tb(data_tb, "unknown mux select with consensus");
                    else
                        capture_tb(1'bx, "unknown mux select with disagreement");
                end
            end
        end
        $display("PASS: logic_element (LUT mapping, 1280 four-state addresses, independent/combined FF, 64 mux cases)");
        $finish;
    end
    initial begin
        #10000;
        $fatal(1, "logic_element test timeout");
    end
endmodule

// End of file
