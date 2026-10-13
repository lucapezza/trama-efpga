---
name: systemverilog-style
description: Apply SystemVerilog formatting, naming, and RTL conventions when creating, editing, or reviewing hand-written .sv or .svh files in this project.
---

# SystemVerilog Style

## Formatting and module organization

Use four spaces for indentation and lowercase snake_case for filenames, modules, signals, and local variables. Match module names to filenames and name testbenches `<module>_tb.sv`.

Keep synthesizable RTL separate from simulation-only testbench code. Prefer `logic`, `always_comb`, and `always_ff`; use `always_latch` for intentional latch storage. Use blocking assignments in combinational calculations and nonblocking assignments for stored state. Declare widths explicitly and explain non-obvious hardware assumptions.

## Signal suffixes

| Suffix | Meaning | Example |
|---|---|---|
| `_in` | Input port | `data_in` |
| `_out` | Output port | `data_out` |
| `_inout` | Bidirectional port | `pad_inout` |
| `_n` | Active-low or complemented signal | `reset_n_in` |
| `_reg` | Flip-flop state | `count_reg` |
| `_regnext` | Explicit next-state value for a flip-flop | `count_regnext` |
| `_latch` | Latch state | `config_latch` |
| `_var` | Local calculation or loop temporary | `index_var` |

- Put polarity before direction or role: `reset_n_in`, `ready_n_out`, `flag_n_reg`.
- Introduce `_regnext` only when a separate next-state signal is useful.
- Reserve `_var` for local calculations and loop temporaries, not every `logic` declaration.
- Name ports by direction even when backed by storage: `data_out`, with internal `data_reg` or `data_latch` when useful. Do not combine direction and storage suffixes.
- Reserve `_reg` for flip-flop state and `_latch` for latch state; declaration type does not determine the suffix.
- Give ordinary internal combinational signals descriptive names without a generic role suffix, such as `selected_data`.
- Use explicit clock, reset, enable, and handshake names: `clk_in`, `reset_n_in`, `enable_in`, `valid_out`, `ready_in`. Use the testbench suffix described below for verification-only identifiers.

## Testbench identifiers

Append `_tb` to testbench-owned signals, variables, constants, function/task names, and their arguments. Preserve existing role and polarity suffixes before it: `mux2_data_tb`, `pattern_var_tb`, `expected_in_tb`, `reset_n_tb`, and `flag_n_reg_tb`.

Keep DUT module names, DUT port names, and DUT instance names unchanged; DUT instances retain `_dut`. A connection such as `.data_in(latch_data_tb)` renames only the testbench signal. Testbench module names and filenames already end in `_tb`; do not append it twice. Apply the suffix to helper return-value assignments as well as declarations and calls.

Use short comments to identify test phases and the behavior being checked, rather than narrating each statement. Keep synthesizable RTL identifiers free of the testbench suffix.

## Applying the conventions

Apply the rules to new or modified code within the requested scope. Preserve externally fixed interfaces, including third-party standard-cell port names; use a wrapper when needed. Do not rename unrelated modules or signals during a focused edit. For reviews, report violations rather than changing files unless edits are requested.

Check the resulting RTL with the repository's configured tools when available; do not claim compilation or simulation passed when no checks ran. Header and trailer conventions are maintained separately in `code-file-comments`.
