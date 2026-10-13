# SKY130 HD Flip-Flop Comparison

## Purpose and scope

This analysis compares functional interfaces and physical footprints of ordinary, enabled, and scan D flip-flops in SkyWater's `sky130_fd_sc_hd` high-density standard-cell library. It supports early choices for trama-efpga runtime registers and configuration storage, alongside the [D-latch](sky130_hd_d_latches.md) and [mux](sky130_hd_muxes.md) comparisons.

The comparison includes all 20 families and 40 numbered drive-strength variants in these categories at the pinned source revision. Other SKY130 libraries, latches, special low-power cells, and timing/power characterization are outside scope. This note does not introduce flip-flop RTL or select a final implementation.

## Functional interfaces

Names below omit the common `sky130_fd_sc_hd__` prefix. Each cell stores one bit; `Q_N` is its complementary output, not another storage bit. Power and body pins are omitted. Clock edges are relative to the external clock pin, with asynchronous controls inactive.

| Family | Clock edge | Reset | Set | Enable / scan | Data/control inputs (including clock) | Outputs | Drive variants |
|---|---|---|---|---|---|---|---|
| [dfbbn](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/dfbbn) | Falling `CLK_N` | Async low `RESET_B`: Q=0 | Async low `SET_B`: Q=1 | None | `D`, `CLK_N`, `SET_B`, `RESET_B` | `Q`, `Q_N` | `_1`, `_2` |
| [dfbbp](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/dfbbp) | Rising `CLK` | Async low `RESET_B`: Q=0 | Async low `SET_B`: Q=1 | None | `D`, `CLK`, `SET_B`, `RESET_B` | `Q`, `Q_N` | `_1` |
| [dfrbp](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/dfrbp) | Rising `CLK` | Async low `RESET_B`: Q=0 | None | None | `CLK`, `D`, `RESET_B` | `Q`, `Q_N` | `_1`, `_2` |
| [dfrtn](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/dfrtn) | Falling `CLK_N` | Async low `RESET_B`: Q=0 | None | None | `CLK_N`, `D`, `RESET_B` | `Q` | `_1` |
| [dfrtp](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/dfrtp) | Rising `CLK` | Async low `RESET_B`: Q=0 | None | None | `CLK`, `D`, `RESET_B` | `Q` | `_1`, `_2`, `_4` |
| [dfsbp](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/dfsbp) | Rising `CLK` | None | Async low `SET_B`: Q=1 | None | `CLK`, `D`, `SET_B` | `Q`, `Q_N` | `_1`, `_2` |
| [dfstp](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/dfstp) | Rising `CLK` | None | Async low `SET_B`: Q=1 | None | `CLK`, `D`, `SET_B` | `Q` | `_1`, `_2`, `_4` |
| [dfxbp](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/dfxbp) | Rising `CLK` | None | None | None | `CLK`, `D` | `Q`, `Q_N` | `_1`, `_2` |
| [dfxtp](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/dfxtp) | Rising `CLK` | None | None | None | `CLK`, `D` | `Q` | `_1`, `_2`, `_4` |
| [edfxbp](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/edfxbp) | Rising `CLK` | None | None | High `DE`: capture D; low: hold | `CLK`, `D`, `DE` | `Q`, `Q_N` | `_1` |
| [edfxtp](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/edfxtp) | Rising `CLK` | None | None | High `DE`: capture D; low: hold | `CLK`, `D`, `DE` | `Q` | `_1` |
| [sdfbbn](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/sdfbbn) | Falling `CLK_N` | Async low `RESET_B`: Q=0 | Async low `SET_B`: Q=1 | `SCE`: D / SCD selection | `D`, `SCD`, `SCE`, `CLK_N`, `SET_B`, `RESET_B` | `Q`, `Q_N` | `_1`, `_2` |
| [sdfbbp](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/sdfbbp) | Rising `CLK` | Async low `RESET_B`: Q=0 | Async low `SET_B`: Q=1 | `SCE`: D / SCD selection | `D`, `SCD`, `SCE`, `CLK`, `SET_B`, `RESET_B` | `Q`, `Q_N` | `_1` |
| [sdfrbp](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/sdfrbp) | Rising `CLK` | Async low `RESET_B`: Q=0 | None | `SCE`: D / SCD selection | `CLK`, `D`, `SCD`, `SCE`, `RESET_B` | `Q`, `Q_N` | `_1`, `_2` |
| [sdfrtn](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/sdfrtn) | Falling `CLK_N` | Async low `RESET_B`: Q=0 | None | `SCE`: D / SCD selection | `CLK_N`, `D`, `SCD`, `SCE`, `RESET_B` | `Q` | `_1` |
| [sdfrtp](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/sdfrtp) | Rising `CLK` | Async low `RESET_B`: Q=0 | None | `SCE`: D / SCD selection | `CLK`, `D`, `SCD`, `SCE`, `RESET_B` | `Q` | `_1`, `_2`, `_4` |
| [sdfsbp](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/sdfsbp) | Rising `CLK` | None | Async low `SET_B`: Q=1 | `SCE`: D / SCD selection | `CLK`, `D`, `SCD`, `SCE`, `SET_B` | `Q`, `Q_N` | `_1`, `_2` |
| [sdfstp](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/sdfstp) | Rising `CLK` | None | Async low `SET_B`: Q=1 | `SCE`: D / SCD selection | `CLK`, `D`, `SCD`, `SCE`, `SET_B` | `Q` | `_1`, `_2`, `_4` |
| [sdfxbp](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/sdfxbp) | Rising `CLK` | None | None | `SCE`: D / SCD selection | `CLK`, `D`, `SCD`, `SCE` | `Q`, `Q_N` | `_1`, `_2` |
| [sdfxtp](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/sdfxtp) | Rising `CLK` | None | None | `SCE`: D / SCD selection | `CLK`, `D`, `SCD`, `SCE` | `Q` | `_1`, `_2`, `_4` |

### Control behavior

- Ordinary flops sample D on the listed clock edge and hold between edges. Their models do not initialize storage; without a reset/set or a valid clocked write, the state can remain X.
- Active-low reset/set inputs act asynchronously, without waiting for a clock edge. Deasserting a control does not itself load D. A reset drives Q=0 and Q_N=1 where present; a set drives Q=1 and Q_N=0.
- Enabled families (`edfxbp`, `edfxtp`) implement feedback selection: DE=1 captures D on a rising edge, while DE=0 retains the prior value. DE is a synchronous data enable, not a clock-gating or asynchronous-load input.
- Scan families select D when SCE=0 and SCD when SCE=1, then capture on their listed edge. SCE alone does not shift data; the clock must still transition. Async reset/set overrides this data selection.
- Families `dfbbn`, `dfbbp`, `sdfbbn`, and `sdfbbp` expose both reset and set. The supplied UDP model gives set priority: when SET_B=0 and RESET_B=0, Q=1 and Q_N=0. This modeled result is not a recommendation to assert both controls in physical hardware; obey the library recovery/removal requirements and avoid uncontrolled simultaneous release.
- Four-state behavior depends on the actual UDP tables, including uncertain clock/control transitions. The UDP called `udp_dff$NSR` has inconsistent descriptive naming: its table captures on internal (01); the external falling-edge variants invert CLK_N before that UDP. The edge column above follows table behavior and wrapper wiring, not the UDP name alone.

## Physical comparison

Widths and heights are in micrometres. The smallest cell is `dfxtp_1`, at 20.0192 µm²; it defines zero overhead. All areas below use LEF width x height, including the documented Liberty discrepancy.

| Cell | Width x height (µm) | Area (µm²) | Area overhead |
|---|---|---:|---:|
| `dfxtp_1` | 7.36 x 2.72 | 20.0192 | 0.00% |
| `dfxtp_2` | 7.82 x 2.72 | 21.2704 | 6.25% |
| `dfxbp_1` | 8.74 x 2.72 | 23.7728 | 18.75% |
| `dfxtp_4` | 8.74 x 2.72 | 23.7728 | 18.75% |
| `dfrtn_1` | 9.20 x 2.72 | 25.0240 | 25.00% |
| `dfrtp_1` | 9.20 x 2.72 | 25.0240 | 25.00% |
| `dfrtp_2` | 9.66 x 2.72 | 26.2752 | 31.25% |
| `dfstp_1` | 9.66 x 2.72 | 26.2752 | 31.25% |
| `dfstp_2` | 9.66 x 2.72 | 26.2752 | 31.25% |
| `dfxbp_2` | 9.66 x 2.72 | 26.2752 | 31.25% |
| `sdfxtp_1` | 9.66 x 2.72 | 26.2752 | 31.25% |
| `sdfxtp_2` | 10.12 x 2.72 | 27.5264 | 37.50% |
| `dfrbp_1` | 10.58 x 2.72 | 28.7776 | 43.75% |
| `dfrtp_4` | 10.58 x 2.72 | 28.7776 | 43.75% |
| `dfsbp_1` | 10.58 x 2.72 | 28.7776 | 43.75% |
| `dfrbp_2` | 11.04 x 2.72 | 30.0288 | 50.00% |
| `dfsbp_2` | 11.04 x 2.72 | 30.0288 | 50.00% |
| `dfstp_4` | 11.04 x 2.72 | 30.0288 | 50.00% |
| `edfxtp_1` | 11.04 x 2.72 | 30.0288 | 50.00% |
| `sdfxbp_1` | 11.04 x 2.72 | 30.0288 | 50.00% |
| `sdfxtp_4` | 11.04 x 2.72 | 30.0288 | 50.00% |
| `sdfrtn_1` | 11.50 x 2.72 | 31.2800 | 56.25% |
| `sdfrtp_1` | 11.50 x 2.72 | 31.2800 | 56.25% |
| `dfbbn_1` | 11.96 x 2.72 | 32.5312 | 62.50% |
| `dfbbp_1` | 11.96 x 2.72 | 32.5312 | 62.50% |
| `edfxbp_1` | 11.96 x 2.72 | 32.5312 | 62.50% |
| `sdfrtp_2` | 11.96 x 2.72 | 32.5312 | 62.50% |
| `sdfxbp_2` | 11.96 x 2.72 | 32.5312 | 62.50% |
| `sdfstp_1` | 12.42 x 2.72 | 33.7824 | 68.75% |
| `dfbbn_2` | 12.88 x 2.72 | 35.0336 | 75.00% |
| `sdfrbp_1` | 12.88 x 2.72 | 35.0336 | 75.00% |
| `sdfrtp_4` | 12.88 x 2.72 | 35.0336 | 75.00% |
| `sdfstp_2` | 12.88 x 2.72 | 35.0336 | 75.00% |
| `sdfrbp_2` | 13.34 x 2.72 | 36.2848 | 81.25% |
| `sdfsbp_1` | 13.34 x 2.72 | 36.2848 | 81.25% |
| `sdfstp_4` | 13.80 x 2.72 | 37.5360 | 87.50% |
| `sdfbbn_1` | 14.26 x 2.72 | 38.7872 | 93.75% |
| `sdfbbp_1` | 14.26 x 2.72 | 38.7872 | 93.75% |
| `sdfsbp_2` | 14.26 x 2.72 | 38.7872 | 93.75% |
| `sdfbbn_2` | 15.18 x 2.72 | 41.2896 | 106.25% |

## Method and interpretation

Inventory comes from the complete pinned repository tree. Functional Verilog wrappers and their referenced UDPs establish interfaces, control polarity and priority, scan selection, and clock edges. LEF `SIZE width BY height` establishes physical dimensions. Every numbered variant was cross-checked against its `__tt_025C_1v80.lib.json` area field.

```text
area = width x height
area overhead (%) = (area / 20.0192 - 1) x 100
```

Percentages are rounded to two decimal places. 39 of 40 LEF areas agree with Liberty. For `dfsbp_2`, LEF gives 11.04 x 2.72 = 30.0288 µm², while Liberty reports 30.0152 µm², a difference of 0.0136 µm². This note retains the LEF footprint; the source inconsistency is not silently corrected or treated as physical measurement uncertainty.

At drive suffix `_1`, relative to the plain `dfxtp_1`:

- Adding complementary output (`dfxbp_1`) increases area by 18.75%.
- Adding active-low reset (`dfrtp_1`) increases area by 25.00%.
- Adding scan selection (`sdfxtp_1`) increases area by 31.25%.
- Adding synchronous data enable (`edfxtp_1`) increases area by 50.00%.

Identical footprints do not establish identical delay, drive, capacitance, or power. The suffix identifies a drive variant; it is not an area multiplier. Compare reset/scan/enable variants only after accounting for their different functionality.

### Implications for trama-efpga

Runtime registers in a logic element need edge-triggered storage; choose reset/set, enable, and output polarity according to that interface. Configuration bits instead hold LUT contents and routing selections while the user circuit runs. Flops, enabled flops, or latches may implement those bits, but programming-clock distribution, write selection, startup behavior, and total configuration-circuit area also matter.

A scan flop can support a serial configuration chain by wiring Q to the next SCD and using SCE to choose the scan path. That is an architectural option, not a completed loader or a reason to conflate configuration shifting with the user circuit clock. The area table includes each cell's built-in scan/enable circuitry, but excludes external configuration logic, routing whitespace, tap cells, clock trees, and added buffers.

No synthesis, routing, timing analysis, or power measurement is claimed. Unknown-state models do not simulate physical metastability. Verify the chosen installed PDK version and its timing/physical views before committing to a cell.

## Sources

Source: [SkyWater HD standard-cell repository](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells), pinned to commit `ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1`. This matches the mux note's source revision and does not pin a project PDK installation.

Each family link in the interface table contains its functional model, numbered LEF files, and Liberty JSON files. Paths are `cells/<family>/sky130_fd_sc_hd__<family>_<drive>.lef` and the corresponding `__tt_025C_1v80.lib.json`.

- [Plain flip-flop functional model](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/blob/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/dfxtp/sky130_fd_sc_hd__dfxtp.functional.v)
- [Enabled flip-flop functional model](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/blob/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/edfxtp/sky130_fd_sc_hd__edfxtp.functional.v)
- [Scan flip-flop functional model](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/blob/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/sdfxtp/sky130_fd_sc_hd__sdfxtp.functional.v)
- [Set/reset priority and clock UDP truth table](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/blob/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/models/udp_dff_nsr/sky130_fd_sc_hd__udp_dff_nsr.v)
- [dfsbp_2 LEF](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/blob/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/dfsbp/sky130_fd_sc_hd__dfsbp_2.lef) and [Liberty area](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/blob/ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1/cells/dfsbp/sky130_fd_sc_hd__dfsbp_2__tt_025C_1v80.lib.json)
