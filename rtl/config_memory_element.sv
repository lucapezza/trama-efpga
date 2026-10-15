// File: config_memory_element.sv
// Project: trama-efpga
// Author: luke
// Description: Row-enabled, column-programmed configuration latch mesh.
// Assumptions: Positive dimensions; only the final row may be incomplete.
// Enables must be known binary values. Bits start unknown until programmed.

module config_memory_element #(
    parameter int NUM_BITS = 1,
    parameter int NUM_COLUMNS = 1,
    parameter int NUM_ROWS = (NUM_COLUMNS > 0 && NUM_BITS > 0)
        ? 1 + (NUM_BITS - 1) / NUM_COLUMNS : 1
) (
    input  logic [NUM_COLUMNS-1:0] program_data_in,
    input  logic [NUM_ROWS-1:0]    program_enable_in,
    output logic [NUM_BITS-1:0]    config_out
);
    timeunit 1ns;
    timeprecision 1ps;

    generate
        if (NUM_BITS <= 0 || NUM_COLUMNS <= 0 || NUM_ROWS <= 0) begin : invalid_dimensions
            // synthesis translate_off
            initial $fatal(1, "config_memory_element: parameters must be positive");
            // synthesis translate_on
        end else if (NUM_ROWS != 1 + (NUM_BITS - 1) / NUM_COLUMNS) begin : invalid_rows
            // synthesis translate_off
            initial $fatal(1, "config_memory_element: NUM_ROWS must equal ceil(NUM_BITS / NUM_COLUMNS)");
            // synthesis translate_on
        end else begin : mesh
            for (genvar bit_index_genvar = 0; bit_index_genvar < NUM_BITS; bit_index_genvar++) begin : bits
                logic stored_bit;
                // Row-major order: bit 0 is at the top left. Empty positions
                // in the final row have no storage and no output bit.
                latch config_latch (
                    .data_in(program_data_in[bit_index_genvar % NUM_COLUMNS]),
                    .enable_in(program_enable_in[bit_index_genvar / NUM_COLUMNS]),
                    .data_out(stored_bit)
                );
                assign config_out[bit_index_genvar] = stored_bit;
            end
        end
    endgenerate
endmodule

// End of file
