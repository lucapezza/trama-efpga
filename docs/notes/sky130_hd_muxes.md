# SKY130 HD Multiplexer Comparison

## Purpose and scope

This analysis compares the interfaces and physical footprints of the multiplexer cells in SkyWater's `sky130_fd_sc_hd` high-density standard-cell library. It supports early choices for trama-efpga LUT readout trees, local interconnect, and routing-selection logic, following the approach used in the [D-latch comparison](sky130_hd_d_latches.md).

The inspected HD repository contains three mux families and ten numbered drive-strength variants. All are included below. Other SKY130 libraries, including HDLL and their specialized mux cells, are outside this comparison. These are combinational data muxes: they have no clock, reset, enable, or stored configuration bits. A data mux is not inherently a glitch-free clock switch.

## Functional interfaces

All cell names have the prefix `sky130_fd_sc_hd__`; for example, `mux2_1` means `sky130_fd_sc_hd__mux2_1`.

| Family | Function | Data inputs | Select inputs | Output | Reset | Available variants |
|---|---|---|---|---|---|---|
| `mux2` | Non-inverting 2:1 mux | `A0`, `A1` | `S` | `X` | None | `_1`, `_2`, `_4`, `_8` |
| `mux2i` | Inverting 2:1 mux | `A0`, `A1` | `S` | `Y` | None | `_1`, `_2`, `_4` |
| `mux4` | Non-inverting 4:1 mux | `A0`, `A1`, `A2`, `A3` | `S0`, `S1` | `X` | None | `_1`, `_2`, `_4` |

For known binary inputs:

- `mux2`: `S = 0` selects `A0`; `S = 1` selects `A1`.
- `mux2i`: uses the same selection, then complements the selected value.
- `mux4`: `{S1, S0}` values `00`, `01`, `10`, `11` select `A0`, `A1`, `A2`, `A3`, respectively. `S0` is the least significant selection bit.

Each cell produces one output bit. Power and body pins are omitted from the table. The functional models use UDP truth tables; for four-state simulation, an unknown select can still produce a known output when all possible selected inputs agree. Use the actual models when checking X/Z behavior rather than assuming every unknown select forces an unknown output.

## Physical comparison

Overhead is relative to the smallest mux in this set, `mux2i_1`, at 10.0096 µm². These percentages compare footprint only; an inverting mux is not functionally interchangeable with a non-inverting mux without accounting for polarity.

| Cell | Function | Width x height (µm) | Area (µm²) | Area overhead |
|---|---|---|---:|---:|
| `mux2i_1` | Inverting 2:1 | 3.68 x 2.72 | 10.0096 | 0% |
| `mux2_1` | Non-inverting 2:1 | 4.14 x 2.72 | 11.2608 | 12.50% |
| `mux2_2` | Non-inverting 2:1 | 4.14 x 2.72 | 11.2608 | 12.50% |
| `mux2i_2` | Inverting 2:1 | 5.06 x 2.72 | 13.7632 | 37.50% |
| `mux2_4` | Non-inverting 2:1 | 5.52 x 2.72 | 15.0144 | 50% |
| `mux2i_4` | Inverting 2:1 | 8.28 x 2.72 | 22.5216 | 125% |
| `mux4_2` | Non-inverting 4:1 | 8.28 x 2.72 | 22.5216 | 125% |
| `mux4_4` | Non-inverting 4:1 | 9.20 x 2.72 | 25.0240 | 150% |
| `mux2_8` | Non-inverting 2:1 | 9.66 x 2.72 | 26.2752 | 162.50% |
| `mux4_1` | Non-inverting 4:1 | 9.66 x 2.72 | 26.2752 | 162.50% |

## Method and interpretation

Dimensions come from the LEF `SIZE width BY height` declarations, in micrometres. Calculations are:

```text
area = width x height
area overhead (%) = (area / 10.0096 - 1) x 100
```

Percentages are rounded to two decimal places. The complete repository tree was checked for mux-family directories and numbered LEF variants. Functional Verilog and UDP files establish ports, polarity, and select ordering. The unexpected `mux4_1` and `mux4_2` footprints were independently checked against their typical-corner Liberty JSON area fields.

Important observations:

- `mux2i_1` is 11.11% smaller than `mux2_1`, but it inverts the selected signal. Any required polarity restoration has its own cost.
- `mux2_1` and `mux2_2` have identical footprints; this does not establish identical timing or power.
- `mux4_2` is 14.29% smaller than `mux4_1`. Do not assume a larger drive-strength suffix always means a larger layout.
- A 4:1 tree made from three `mux2_1` cells occupies 33.7824 µm². A single `mux4_1` occupies 26.2752 µm², 22.22% less; `mux4_2` occupies 22.5216 µm², 33.33% less.
- A LUT4 readout built as a balanced 16:1 tree needs 15 two-input muxes or five four-input muxes. Using only `mux2_1` gives 168.9120 µm²; using only `mux4_2` gives 112.6080 µm². This is a structural cell-area estimate, not a synthesized or routed result. It excludes the 16 truth-table storage bits and their configuration circuitry.

These footprints exclude routing whitespace, taps, buffers, and configuration storage. Timing, input capacitance, output load, power, and synthesis mapping must be evaluated before selecting cells. More powerful drive variants are not automatically faster in every circuit. The note does not claim timing or power measurements.

## Sources

Source repository: [SkyWater HD standard cells](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells).

This analysis pins commit `ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1` for reproducibility. It does not pin the eventual project PDK installation.

- [mux2 models and physical files](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/mux2)
- [mux2i models and physical files](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/mux2i)
- [mux4 models and physical files](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/mux4)
- [mux4 UDP selection truth table](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/blob/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/models/udp_mux_4to2/sky130_fd_sc_hd__udp_mux_4to2.v)

For each variant, inspect `cells/<family>/sky130_fd_sc_hd__<family>_<drive>.lef`. For the Liberty cross-check, inspect the corresponding `__tt_025C_1v80.lib.json` file.
