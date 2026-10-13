# Hardware Test Guide

## Setup and organization

Install Git, Verilator, and Icarus Verilog using the [environment setup guide](../docs/environment_setup.md). Run the commands below from the repository root in a Linux, Ubuntu WSL, or macOS shell. They use shell continuation syntax, not PowerShell syntax.

`tb/` contains simulation-only verification code. Synthesizable hardware is under `rtl/`. Primitive testbenches are grouped in `tb/primitives/`; generated simulator files go in the Git-ignored `build/` directory.

| Testbench | Status | Hardware and checks |
|---|---|---|
| `primitives/basic_primitives_tb.sv` | Runnable | `mux2`, `mux4`, and plain `latch` from `rtl/primitives/behavioral/basic_primitives.sv`. |
| `primitives/controlled_latches_tb.sv` | Runnable | `latch_reset` and `latch_set` from the same RTL file. |

These two benches are the complete runnable hardware regression. Use explicit source lists rather than compiling files through a wildcard.

## Run the verification workflow

```sh
sh tb/run_checks.sh
```

The default `all` mode checks required tools, lints every RTL primitive with Verilator, then separately compiles and runs both Icarus testbenches. It stops with a nonzero status on missing tools, lint warnings/errors, compilation failure, or test failure. A failed compile never runs an older simulator artifact. The script resolves the repository root from its own location; the examples assume you start at that root.

Run stages separately when useful:

```sh
sh tb/run_checks.sh lint
sh tb/run_checks.sh test
```

`lint` requires only Verilator; `test` requires only Icarus. Use `all` before submitting a change. Unsupported modes or extra arguments produce a usage error (status 2).

## RTL lint policy

The runner invokes Verilator with `--lint-only --language 1800-2012 -Wall` for each of `mux2`, `mux4`, `latch`, `latch_reset`, and `latch_set` as an explicit top. This checks all current RTL primitives, including those not instantiated by a future testbench. The testbench itself is compiled and executed with Icarus; it is not included in this RTL lint pass.

Warnings remain fatal. Two intentional exceptions apply:

- `DECLFILENAME` is disabled only for the invocation on `basic_primitives.sv`, because this replaceable implementation file intentionally groups several modules.
- `COMBDLY` is waived locally around the three `always_latch` blocks. Their nonblocking assignments represent stored state and preserve the intended Icarus scheduling. Verilator flags these assignments and may model them differently in simulation; this workflow uses Verilator only for static lint.

Do not disable all warnings, add `-Wno-fatal`, or extend waivers without a concrete explanation. New modules must be added to the runner's explicit lint-top list and any needed source lists. Output paths stay under the ignored `build/` directory.

See [Verilator arguments](https://verilator.org/guide/latest/exe_verilator.html) and [warning descriptions](https://verilator.org/guide/latest/warnings.html).

## Compile and run Icarus directly

```sh
mkdir -p build
iverilog -g2012 -Wall -s basic_primitives_tb -o build/basic_primitives.vvp \
    rtl/primitives/behavioral/basic_primitives.sv \
    tb/primitives/basic_primitives_tb.sv &&
vvp build/basic_primitives.vvp
```

For the reset/set latch bench:

```sh
mkdir -p build
iverilog -g2012 -Wall -s controlled_latches_tb -o build/controlled_latches.vvp \
    rtl/primitives/behavioral/basic_primitives.sv \
    tb/primitives/controlled_latches_tb.sv &&
vvp build/controlled_latches.vvp
```

- `-g2012` selects SystemVerilog 2012 language support.
- `-Wall` enables compiler warnings; review them even if compilation succeeds.
- `-s` explicitly selects `basic_primitives_tb` or `controlled_latches_tb` as the simulation top.
- `-o` names the compiled simulator artifact; `vvp` executes it.
- `&&` runs simulation only after successful compilation, avoiding execution of an old artifact after a compile error.

Recompile after changing RTL or testbench code. Keep explicit source lists and select exactly one implementation of each primitive when a standard-cell-backed version is introduced.

## What the tests verify

| Primitive | Coverage |
|---|---|
| `mux2` | All 64 combinations of its two data inputs and one select input over `0`, `1`, `X`, and `Z`. |
| `mux4` | All 4,096 combinations of four data inputs and two select bits over `0`, `1`, `X`, and `Z`; includes selection order and partial unknown-select cases. |
| `latch` | Unknown startup with enable low, active-high transparency for binary data, disabled-state retention while data changes to `0`, `1`, `X`, or `Z`, propagation of `X` while enabled, and recovery after writing known data. |
| `latch_reset`, `latch_set` | Unknown startup with controls inactive; asynchronous active-low assertion while disabled and enabled; priority over all 16 four-state data/enable combinations; release while disabled and enabled; transparent `0`/`1`/`X`/`Z` data, known-data recovery, and retention of 0 and 1 across all four-state input data. |

The mux reference enumerates compatible binary select addresses and merges candidate data by consensus. Comparisons use case inequality (`!==`) so X/Z differences are detected. The plain latch has no reset. All latch enables and inactive reset/set controls are assumed known during normal operation. Unknown-enable behavior with inactive controls and unknown reset/set controls are not covered; asserted reset/set is tested even with X/Z enables. Transparent capture of Z is covered for the reset/set variants, but not for the plain latch. This is functional behavioral verification, not timing, metastability, or transistor-level verification. No aggregate coverage threshold is configured.

## Results and troubleshooting

A successful combined run prints `PASS: RTL lint (5 primitives)` followed by both simulation results:

```text
PASS: mux2 (64 patterns), mux4 (4096 patterns), latch startup/transparency/hold
PASS: reset/set latches (startup, priority, transparency, hold, release)
```

Successful simulation exits with status zero; Icarus may also print a normal `$finish` message. A mismatch calls `$fatal`, identifies the failing primitive/pattern or expected and actual latch values, and exits unsuccessfully. A 10,000 ns simulated-time watchdog also calls `$fatal` if the test does not finish. It is not a wall-clock timeout.

If a source file is missing, confirm your working directory. If `verilator`, `iverilog`, or `vvp` is missing, revisit setup and PATH. If lint or compilation fails, fix it before running the simulator. On Windows, use the Ubuntu WSL terminal where the tools were installed. Waveform dumping is not currently enabled.

## Adding tests

Update the explicit lint-top list and source lists in `run_checks.sh` when adding RTL. Add self-checking benches for new hardware, with descriptive failure messages and a timeout. Document each runnable bench here with its top module, complete source list, command, and covered behavior; follow the project-local SystemVerilog style skill, including `_tb` suffixes for testbench-owned identifiers. Use reproducible seeds when introducing random stimulus and report failures with enough context to reproduce them.
