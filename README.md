# trama-efpga
Just fooling around, trying to build my own FPGA.

trama-efpga is an embedded FPGA project in its initial development stage. The first building blocks will be behavioral SystemVerilog lookup tables (LUTs) and flip-flops, together with their hardware testbenches.

## Repository layout

```text
trama-efpga/
├── README.md
├── rtl/
│   ├── basic_primitives.sv
│   ├── config_memory_element.sv
│   └── logic_element.sv
├── test/
│   ├── basic_primitives_tb.sv
│   ├── config_memory_element_tb.sv
│   ├── config_memory_element_invalid_tb.sv
│   ├── ff_tb.sv
│   ├── logic_element_tb.sv
│   ├── run_checks.sh
│   └── test_guide.md
├── tools/
│   └── README.md
└── docs/
    ├── environment_setup.md
    ├── diagrams/
    │   ├── config_memory_element.svg
    │   └── logic_element.svg
    └── notes/
        ├── sky130_hd_d_latches.md
        ├── sky130_hd_muxes.md
        └── sky130_hd_flip_flops.md
```

- `rtl/` holds the initial synthesizable behavioral implementations of the primitives.
- `test/` holds hardware testbenches for the primitives.
- `tools/` is reserved for supporting software tools and their tests.
- `docs/` is reserved for architecture notes and design documentation.

## Primitive implementations

Behavioral RTL may be synthesizable. Technology-specific implementations can be added later where explicit standard cells or macros are needed. Each alternative will expose the same module name, ports, and supported parameters as its behavioral counterpart. The build will select exactly one implementation of each primitive through explicit source lists.

## Current status

`basic_primitives.sv` implements six one-bit behavioral primitives in one file:

| Module | Interface and behavior |
|---|---|
| `mux2` | `a0_in`, `a1_in`, `select_in` -> `data_out`; select 0 chooses a0, select 1 chooses a1. |
| `mux4` | `a0_in` through `a3_in`, two-bit `select_in` -> `data_out`; binary selections 00 through 11 choose a0 through a3. |
| `latch` | `data_in`, `enable_in` -> `data_out`; active-high transparency, hold when disabled, no reset or initialized value. |
| `latch_reset` | `data_in`, `enable_in`, `reset_n_in` -> `data_out`; asynchronous active-low reset forces 0 and overrides enable. |
| `latch_set` | `data_in`, `enable_in`, `set_n_in` -> `data_out`; asynchronous active-low set forces 1 and overrides enable. |
| `ff` | `data_in`, `clk_in`, `reset_n_in` -> `data_out`; rising-edge capture, asynchronous active-low reset to zero, no enable or initial value. |

The muxes use conditional-operator four-state merging. Latch enables and inactive reset/set controls must be known during normal operation. Storage starts unknown until written or explicitly reset/set. Releasing reset/set while disabled retains the forced value; releasing it while enabled resumes transparency. Technology-specific implementations will replace this file while preserving its module interfaces and binary behavior. Grouping these basic modules in one implementation file is intentional; it is an exception to the usual module-name/filename convention.

## Configuration memory

`config_memory_element` stores `NUM_BITS` configuration bits in plain latches,
with `NUM_COLUMNS` programming-data inputs and `NUM_ROWS` active-high enable
inputs. All parameters must be positive; `NUM_ROWS` must equal
`1 + (NUM_BITS - 1) / NUM_COLUMNS`, which is also its default. The other
parameters default to 1. Only the final row may be incomplete.

Bit `i` of `config_out` uses `program_data_in[i % NUM_COLUMNS]` and
`program_enable_in[i / NUM_COLUMNS]`: bits run left to right, then top to bottom,
starting with bit 0. Each enabled row follows its column data continuously;
disabled rows hold their values. There is no clock, reset, or initial value.
Enables must be known binary values during normal operation. Simulation checks
reject invalid parameters; synthesis must use valid dimensions.

Parents can connect shared data and enable buses to multiple instances.
Enabled rows in every connected instance receive the same programming data;
independent tile selection requires control in the parent. Each instance has
its own configuration output. See the editable
[configuration mesh diagram](docs/diagrams/config_memory_element.svg), including
a 10-bit example and shared-bus composition view. It shows logical connectivity,
not physical placement constraints.

## Logic element

`logic_element` combines a four-input LUT with one `ff`, using five `mux4`
primitives for the LUT and one `mux2` for the FF data input. Its inputs are
`lut_data_in[3:0]`, `lut_config_in[15:0]`, `ff_select_config_in`, `ff_data_in`,
`clk_in`, and `reset_n_in`; its separate outputs are `lut_out` and `ff_out`.
All ports and internal connections use `logic`. Configuration inputs are listed
last in the module declaration, following the trama-specific convention in
`AGENTS.md`.

For a binary address, `lut_out = lut_config_in[lut_data_in]`, with bit 0 the
least significant address bit. The first mux stage selects within consecutive
groups of four configuration bits using address bits `[1:0]`; the final mux
selects the group using bits `[3:2]`. Configuration is supplied externally
and changes the combinational result without a clock. Unknown address and mux
select bits use the primitives' four-state merging semantics.

`ff_select_config_in = 0` selects the LUT result for the FF; `1` selects the dedicated
`ff_data_in`. This supports LUT feeding FF, or independent LUT and FF operation.
For LUT-only use, consume `lut_out` and ignore `ff_out`; no FF disable is needed.
Both outputs remain directly available, without an output mux. The FF captures
on rising clock edges and asynchronously resets to zero when `reset_n_in` is
low. Releasing reset alone does not capture data. Clock and reset must be known
binary signals during normal operation. See the editable
[logic element diagram](docs/diagrams/logic_element.svg).

## Development guides

- [Environment setup](docs/environment_setup.md): install the required tools on Windows (WSL2), Linux, or macOS and obtain a checkout.
- [Hardware test guide](test/test_guide.md): run Verilator lint and Icarus tests, understand coverage, and interpret results.

Run both stages from the repository root:

```sh
sh test/run_checks.sh
```

Current verification uses Verilator for RTL lint and Icarus Verilog for four-state behavioral simulation. The regression covers all six primitives, the LUT/FF logic element, six configuration mesh shapes, and invalid configuration parameters. Synthesis and CI workflows are still pending.

## SKY130 analysis notes

- [D-latches](docs/notes/sky130_hd_d_latches.md)
- [Multiplexers](docs/notes/sky130_hd_muxes.md)
- [Flip-flops](docs/notes/sky130_hd_flip_flops.md)
