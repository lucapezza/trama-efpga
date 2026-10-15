// File: basic_primitives.sv
// Project: trama-efpga
// Author: luke
// Description: Behavioral single-bit mux, latch, and flip-flop primitives.
// Assumptions: Enables are active-high; reset/set controls are asynchronous
// and active-low. Storage starts unknown until written or explicitly reset/set.
// Enables, clocks, and reset/set controls must be known during normal operation.

// Compile one implementation of these modules per build. Future standard-cell
// wrappers must preserve these names, ports, and binary functional behavior.

module mux2 (
    input  logic a0_in,
    input  logic a1_in,
    input  logic select_in,
    output logic data_out
);
    timeunit 1ns;
    timeprecision 1ps;

    assign data_out = select_in ? a1_in : a0_in;
endmodule

module mux4 (
    input  logic       a0_in,
    input  logic       a1_in,
    input  logic       a2_in,
    input  logic       a3_in,
    input  logic [1:0] select_in,
    output logic       data_out
);
    timeunit 1ns;
    timeprecision 1ps;

    // select_in[0] is the least significant selection bit. Ternary merging
    // preserves a known result when an unknown select cannot change the output.
    assign data_out = select_in[1]
        ? (select_in[0] ? a3_in : a2_in)
        : (select_in[0] ? a1_in : a0_in);
endmodule

module latch (
    input  logic data_in,
    input  logic enable_in,
    output logic data_out
);
    timeunit 1ns;
    timeprecision 1ps;

    // No initial value or reset: configuration must explicitly write this bit.
    // enable_in must be a known 0 or 1 during normal operation.
    // Preserve nonblocking latch semantics; Verilator is used only for lint.
    /* verilator lint_off COMBDLY */
    always_latch begin
        if (enable_in)
            data_out <= data_in;
    end
    /* verilator lint_on COMBDLY */
endmodule

module latch_reset (
    input  logic reset_n_in,
    input  logic data_in,
    input  logic enable_in,
    output logic data_out
);
    timeunit 1ns;
    timeprecision 1ps;

    // Asynchronous active-low reset takes priority over transparency.
    // Preserve nonblocking latch semantics; Verilator is used only for lint.
    /* verilator lint_off COMBDLY */
    always_latch begin
        if (!reset_n_in)
            data_out <= 1'b0;
        else if (enable_in)
            data_out <= data_in;
    end
    /* verilator lint_on COMBDLY */
endmodule

module latch_set (
    input  logic data_in,
    input  logic enable_in,
    input  logic set_n_in,
    output logic data_out
);
    timeunit 1ns;
    timeprecision 1ps;

    // Asynchronous active-low set takes priority over transparency.
    // Preserve nonblocking latch semantics; Verilator is used only for lint.
    /* verilator lint_off COMBDLY */
    always_latch begin
        if (!set_n_in)
            data_out <= 1'b1;
        else if (enable_in)
            data_out <= data_in;
    end
    /* verilator lint_on COMBDLY */
endmodule

module ff (
    input  logic clk_in,
    input  logic reset_n_in,
    input  logic data_in,
    output logic data_out
);
    timeunit 1ns;
    timeprecision 1ps;

    // Active-low asynchronous reset overrides rising-edge data capture.
    // No initialization: reset or a rising clock edge must establish state.
    always_ff @(posedge clk_in or negedge reset_n_in) begin
        if (!reset_n_in)
            data_out <= 1'b0;
        else
            data_out <= data_in;
    end
endmodule

// End of file
