// File: ff_tb.sv
// Project: trama-efpga
// Author: luke
// Description: Self-checking rising-edge and asynchronous reset FF tests.

module ff_tb;
    timeunit 1ns;
    timeprecision 1ps;
    logic data_tb;
    logic clk_tb;
    logic reset_n_tb;
    logic result_tb;

    ff ff_dut (
        .data_in(data_tb), .clk_in(clk_tb),
        .reset_n_in(reset_n_tb), .data_out(result_tb)
    );

    task automatic check_tb(input logic expected_tb, input string phase_tb);
        #1;
        if (result_tb !== expected_tb)
            $fatal(1, "ff %s: expected=%b actual=%b", phase_tb, expected_tb, result_tb);
    endtask

    initial begin
        clk_tb = 0;
        reset_n_tb = 1;
        data_tb = 0;
        check_tb(1'bx, "unknown startup");
        clk_tb = 1;
        check_tb(0, "capture zero");
        data_tb = 1;
        check_tb(0, "data change with clock high");
        clk_tb = 0;
        check_tb(0, "falling-edge retention");
        clk_tb = 1;
        check_tb(1, "capture one");
        reset_n_tb = 0;
        check_tb(0, "asynchronous reset with clock high");
        reset_n_tb = 1;
        check_tb(0, "release with clock high does not capture");
        clk_tb = 0;
        check_tb(0, "falling edge after release");
        clk_tb = 1;
        check_tb(1, "capture after release");
        clk_tb = 0;
        check_tb(1, "hold one while clock low");
        reset_n_tb = 0;
        check_tb(0, "asynchronous reset with clock low");
        clk_tb = 1;
        check_tb(0, "reset overrides rising-edge data");
        clk_tb = 0;
        reset_n_tb = 1;
        check_tb(0, "release with clock low does not capture");
        data_tb = 1'bx;
        clk_tb = 1;
        check_tb(1'bx, "capture X");
        clk_tb = 0;
        data_tb = 1'bz;
        check_tb(1'bx, "hold X between edges");
        clk_tb = 1;
        check_tb(1'bz, "capture Z");
        reset_n_tb = 0;
        check_tb(0, "reset recovers unknown state");
        clk_tb = 0;
        reset_n_tb = 1;
        data_tb = 1;
        #1;
        // Assert reset and raise clock together; reset must win.
        reset_n_tb = 0;
        clk_tb = 1;
        check_tb(0, "simultaneous reset assertion and clock edge");
        $display("PASS: ff (rising-edge capture, retention, async reset, X/Z)");
        $finish;
    end
    initial begin
        #10000;
        $fatal(1, "ff test timeout");
    end
endmodule

// End of file
