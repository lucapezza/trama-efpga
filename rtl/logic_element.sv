// File: logic_element.sv
// Project: trama-efpga
// Author: luke
// Description: Four-input LUT with selectable LUT/external-data flip-flop.
// Assumptions: Configuration is supplied externally. Clock and reset are binary.

module logic_element (
    input  logic        clk_in,
    input  logic        reset_n_in,
    input  logic [3:0]  lut_data_in,
    input  logic        ff_data_in,
    output logic        lut_out,
    output logic        ff_out,
    input  logic [15:0] lut_config_in,
    input  logic        ff_select_config_in
);
    timeunit 1ns;
    timeprecision 1ps;

    logic [3:0] lut_groups;
    logic selected_ff_data;

    // Address bits [1:0] select within each consecutive configuration group.
    mux4 group0_mux (
        .a0_in(lut_config_in[0]), .a1_in(lut_config_in[1]),
        .a2_in(lut_config_in[2]), .a3_in(lut_config_in[3]),
        .select_in(lut_data_in[1:0]), .data_out(lut_groups[0])
    );
    mux4 group1_mux (
        .a0_in(lut_config_in[4]), .a1_in(lut_config_in[5]),
        .a2_in(lut_config_in[6]), .a3_in(lut_config_in[7]),
        .select_in(lut_data_in[1:0]), .data_out(lut_groups[1])
    );
    mux4 group2_mux (
        .a0_in(lut_config_in[8]), .a1_in(lut_config_in[9]),
        .a2_in(lut_config_in[10]), .a3_in(lut_config_in[11]),
        .select_in(lut_data_in[1:0]), .data_out(lut_groups[2])
    );
    mux4 group3_mux (
        .a0_in(lut_config_in[12]), .a1_in(lut_config_in[13]),
        .a2_in(lut_config_in[14]), .a3_in(lut_config_in[15]),
        .select_in(lut_data_in[1:0]), .data_out(lut_groups[3])
    );

    // Address bits [3:2] select the group: lut_out = lut_config_in[address].
    mux4 lut_mux (
        .a0_in(lut_groups[0]), .a1_in(lut_groups[1]),
        .a2_in(lut_groups[2]), .a3_in(lut_groups[3]),
        .select_in(lut_data_in[3:2]), .data_out(lut_out)
    );
    mux2 ff_input_mux (
        .a0_in(lut_out), .a1_in(ff_data_in),
        .select_in(ff_select_config_in), .data_out(selected_ff_data)
    );
    ff storage_ff (
        .data_in(selected_ff_data), .clk_in(clk_in),
        .reset_n_in(reset_n_in), .data_out(ff_out)
    );
endmodule

// End of file
