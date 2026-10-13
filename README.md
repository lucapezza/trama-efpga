# trama-efpga
Just fooling around, trying to build my own FPGA.

trama-efpga is an embedded FPGA project in its initial development stage. The first building blocks will be behavioral SystemVerilog lookup tables (LUTs) and flip-flops, together with their hardware testbenches.

## Repository layout

```text
trama-efpga/
├── README.md
├── rtl/
│   └── basic_primitives.sv
├── test/
│   ├── basic_primitives_tb.sv
│   ├── run_checks.sh
│   └── test_guide.md
├── tools/
│   └── README.md
└── docs/
    ├── environment_setup.md
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

`basic_primitives.sv` implements five one-bit behavioral primitives in one file:

| Module | Interface and behavior |
|---|---|
| `mux2` | `a0_in`, `a1_in`, `select_in` -> `data_out`; select 0 chooses a0, select 1 chooses a1. |
| `mux4` | `a0_in` through `a3_in`, two-bit `select_in` -> `data_out`; binary selections 00 through 11 choose a0 through a3. |
| `latch` | `data_in`, `enable_in` -> `data_out`; active-high transparency, hold when disabled, no reset or initialized value. |
| `latch_reset` | `data_in`, `enable_in`, `reset_n_in` -> `data_out`; asynchronous active-low reset forces 0 and overrides enable. |
| `latch_set` | `data_in`, `enable_in`, `set_n_in` -> `data_out`; asynchronous active-low set forces 1 and overrides enable. |

The muxes use conditional-operator four-state merging. Latch enables and inactive reset/set controls must be known during normal operation. Storage starts unknown until written or explicitly reset/set. Releasing reset/set while disabled retains the forced value; releasing it while enabled resumes transparency. Technology-specific implementations will replace this file while preserving its module interfaces and binary behavior. Grouping these basic modules in one implementation file is intentional; it is an exception to the usual module-name/filename convention.

## Development guides

- [Environment setup](docs/environment_setup.md): install the required tools on Windows (WSL2), Linux, or macOS and obtain a checkout.
- [Hardware test guide](test/test_guide.md): run Verilator lint and Icarus tests, understand coverage, and interpret results.

Run both stages from the repository root:

```sh
sh test/run_checks.sh
```

Current verification uses Verilator for RTL lint and Icarus Verilog for four-state behavioral simulation. The single basic-primitives bench covers all five primitives and forms the current runnable regression. Synthesis and CI workflows are still pending.

## SKY130 analysis notes

- [D-latches](docs/notes/sky130_hd_d_latches.md)
- [Multiplexers](docs/notes/sky130_hd_muxes.md)
- [Flip-flops](docs/notes/sky130_hd_flip_flops.md)
