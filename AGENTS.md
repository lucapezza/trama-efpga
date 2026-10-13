# Repository Guidelines

## Project Structure & Module Organization

trama-efpga is an embedded FPGA project in early development. Behavioral mux2, mux4, plain latch, active-low-reset latch, and active-low-set latch modules are implemented in `basic_primitives.sv`.

- `rtl/primitives/behavioral/`: synthesizable mux and latch variants in `basic_primitives.sv`.
- `tb/primitives/`: self-checking hardware tests in `basic_primitives_tb.sv` and `controlled_latches_tb.sv`.
- `tools/`: future supporting software tools and their tests.
- `docs/`: architecture notes and design decisions.
- `README.md`: project overview, layout, and development status.

Keep the structure small; introduce new directories when concrete work needs them.

## Build, Test, and Development Commands

Run `sh tb/run_checks.sh` for Verilator RTL lint followed by Icarus simulation (`iverilog` and `vvp`); see [environment setup](docs/environment_setup.md) for prerequisites and the [test guide](tb/test_guide.md) for exact commands. Separate stages are `sh tb/run_checks.sh lint` and `sh tb/run_checks.sh test`. No formatter, synthesis flow, or CI has been configured.

Use `git diff --check` to check tracked changes for whitespace errors and `git status --short` to review modified and untracked files. These checks do not validate hardware behavior. When adding a simulation or synthesis flow, document prerequisites in the environment guide and commands in the test guide, with entry links in the README.

## Contributor Skills

- For hand-written SystemVerilog, use [systemverilog-style](.agents/skills/systemverilog-style/SKILL.md).
- For headers and end-of-file comments in hand-written code of any language, use [code-file-comments](.agents/skills/code-file-comments/SKILL.md).

## Testing Guidelines

Run both lint and simulation for RTL changes. Keep warnings fatal except for documented, narrowly scoped exceptions. Update the runner's explicit lint-top and source lists when adding modules or benches. Tests are self-checking SystemVerilog benches; no coverage threshold exists yet. Add a self-checking testbench alongside each implemented primitive under `tb/primitives/`. Check expected outputs, supported parameter configurations, and relevant clock or reset behavior. Fail clearly on mismatches. Record the command and result in the pull request; state when tests could not run.

## Documentation Maintenance

Update documentation in the same change as the implementation:

- Keep `docs/environment_setup.md` current when dependencies, supported versions, operating-system setup, or required tooling change. Distinguish tested setups from instructions that have not been exercised.
- Keep `tb/test_guide.md` current when adding or changing tests: list runnable benches and placeholders, top modules, explicit source lists, commands, expected results, and coverage or limitations.
- Keep `README.md` links, repository layout, and implementation status aligned with the actual files. Link to the detailed guides rather than duplicating installation and test commands.
- Update relevant analysis notes when their assumptions or source data change. Preserve unrelated user edits and state honestly when validation could not run.
