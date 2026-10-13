# SKY130 HD D-Latch Comparison

## Purpose and scope

This analysis compares the physical footprint and functional interfaces of eight D-latch families in SkyWater's `sky130_fd_sc_hd` high-density standard-cell library. It supports early decisions about storage primitives for trama-efpga, including whether reset, enable polarity, or complementary outputs justify additional cell area.

The table covers only the `_1` variants. Other drive strengths and standard-cell libraries are outside this comparison. It is a cell-level area comparison, not a timing, power, or complete eFPGA area estimate, and does not select a final primitive implementation.

## Comparison table

All cell names below have the prefix `sky130_fd_sc_hd__`; for example, `dlxtp_1` means `sky130_fd_sc_hd__dlxtp_1`.

| Cell | Reset | Data/control inputs | Transparent when | Outputs | Width x height (µm) | Area (µm²) | Area overhead |
|---|---|---|---|---|---|---:|---:|
| `dlxtp_1` | None | `D`, `GATE` | `GATE = 1` | `Q` | 5.52 x 2.72 | 15.0144 | 0% |
| `dlxtn_1` | None | `D`, `GATE_N` | `GATE_N = 0` | `Q` | 5.52 x 2.72 | 15.0144 | 0% |
| `dlrtp_1` | Active-low `RESET_B` | `D`, `GATE`, `RESET_B` | `GATE = 1` | `Q` | 5.98 x 2.72 | 16.2656 | 8.33% |
| `dlrtn_1` | Active-low `RESET_B` | `D`, `GATE_N`, `RESET_B` | `GATE_N = 0` | `Q` | 6.44 x 2.72 | 17.5168 | 16.67% |
| `dlxbp_1` | None | `D`, `GATE` | `GATE = 1` | `Q`, `Q_N` | 6.90 x 2.72 | 18.7680 | 25% |
| `dlxbn_1` | None | `D`, `GATE_N` | `GATE_N = 0` | `Q`, `Q_N` | 6.90 x 2.72 | 18.7680 | 25% |
| `dlrbp_1` | Active-low `RESET_B` | `D`, `GATE`, `RESET_B` | `GATE = 1` | `Q`, `Q_N` | 7.82 x 2.72 | 21.2704 | 41.67% |
| `dlrbn_1` | Active-low `RESET_B` | `D`, `GATE_N`, `RESET_B` | `GATE_N = 0` | `Q`, `Q_N` | 7.82 x 2.72 | 21.2704 | 41.67% |

Each cell stores one bit. `Q_N` is the complementary output, not a second stored bit. Transparent means the output follows `D` while the enable is asserted and reset is inactive; otherwise the latch holds its value, unless reset is asserted. Power and body pins are excluded from the input/output columns.

## Method and interpretation

Dimensions come from the `SIZE width BY height` declaration in each cell's LEF file, in micrometres. Area and overhead are calculated as:

```text
area = width x height
area overhead (%) = (area / 15.0144 - 1) x 100
```

The baseline is 15.0144 µm², shared by `dlxtp_1` and `dlxtn_1`. Percentages are rounded to two decimal places.

- Adding active-low reset to the positive-enable, single-output latch increases area by 8.33%.
- Providing both output polarities without reset increases area by 25%.
- Providing reset and both output polarities increases area by 41.67%.

These figures exclude routing whitespace, tap cells, buffers, and other integration overhead. Cell choice must also account for timing, power, reset behavior, and the pinned PDK version used by the eventual implementation flow.

## Sources

The inputs are from the [SkyWater HD standard-cell repository](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/tree/main/cells), using the `main` branch. This comparison does not yet pin a source commit.

For each family, inspect `cells/<family>/sky130_fd_sc_hd__<family>_1.lef` for dimensions and the associated Verilog model for ports and behavior. For example:

- [dlxtp_1 LEF](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/blob/main/cells/dlxtp/sky130_fd_sc_hd__dlxtp_1.lef)
- [dlrtp_1 LEF](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd/blob/main/cells/dlrtp/sky130_fd_sc_hd__dlrtp_1.lef)
- [Official dlxtp cell documentation](https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_sc_hd/cells/dlxtp/README.html)
