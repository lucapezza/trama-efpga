---
name: svg-block-diagrams
description: Create or update editable SVG block diagrams of hardware systems from RTL and design documentation, using consistent logic symbols, signal notation, and layout.
---

# SVG Block Diagrams

## Source and scope

Read the relevant RTL and design documentation before drawing. Preserve actual port names, bus widths, connectivity, polarity, and storage behavior. Distinguish implemented behavior from proposed architecture, and identify conceptual simplifications in the diagram description or accompanying explanation. Do not infer an edge-triggered clock from a latch enable.

Default output to `docs/diagrams/<system_name>.svg`, using the system's lowercase snake_case name, unless the user specifies a destination. Create the output directory only when producing a diagram. Update an existing diagram in place when that is the requested task.

## Symbols and typography

- Use white block backgrounds and black outlines. Use US distinctive-shape logic gates: D-shaped AND, curved OR, the extra input curve for XOR, and triangles for buffers/inverters. Use inversion bubbles for complemented outputs and active-low pins.
- Draw muxes as trapezoids with a taller data-input side and shorter output side. Attach select signals to an inclined edge. Label data inputs with their selection values, preserving bit ordering from the source.
- Mark edge-triggered clock inputs with a small triangle pointing into the block. Add an external bubble for falling-edge clocks. Show level-sensitive latch enables without a clock triangle; retain reset/set polarity and asynchronous behavior in the labels or description.
- Center block titles horizontally and vertically in the available title area. Use `Arial, Helvetica, sans-serif` and uniform 14 px text throughout blocks, including port labels. Enlarge blocks or wrap labels with `tspan` elements instead of shrinking individual labels.
- Italicize input/output signal names, including port and external connection labels. Keep block titles and numeric selection values upright. Retain actual signal names when adding polarity bubbles.

## Layout and connections

- Prefer left-to-right data flow. Align related blocks and matching ports where practical, with consistent spacing and enough room for labels. Prefer horizontal and vertical wire segments; route feedback around blocks.
- Align related wires, bends, and endpoints vertically or horizontally whenever possible. Space parallel wires and repeated routes equally where practical, while keeping connectivity clear and labels unobstructed.
- Keep at least 20 px of edge-to-edge clearance in SVG viewBox units between unrelated parallel wire segments and nearby bends or endpoints. Enlarge or reroute the layout when needed; intentional connections, crossings, and symbol pin geometry are exempt.
- Use small arrowheads near receiving ports to indicate signal direction. Keep arrowheads clear of clock triangles and polarity bubbles. For bidirectional signals, show arrows in both directions.
- Default single-bit wire strokes to 1.5 px and multibit wire strokes to 3 px. Label buses with their width or range, retaining symbolic widths for parameterized systems. Do not silently classify an unknown width as single-bit.
- Mark connected branches with filled junction dots. Draw unconnected wire crossings without dots; avoid ambiguous crossings at bends or endpoints. Keep bus taps and bit selections explicit.
- Keep labels clear of wires, symbols, and other labels. Use a compact legend when notation is unfamiliar or the drawing contains conceptual simplifications that need explanation.

## SVG construction and verification

Produce self-contained vector SVG with the SVG namespace, a `viewBox`, editable `text`/`tspan` labels, and reusable styles. Use local definitions for arrow markers and repeated symbols where useful. Avoid external dependencies, embedded raster diagrams, and text converted to paths. Include a `title` and `desc` identifying the system and diagram scope.

Before delivery:

1. Parse the SVG with an XML parser and check that local marker/symbol references resolve.
2. Compare the diagram against the source for port names, widths, mux selection mapping, connectivity, polarity, and latch/clock semantics.
3. Render the SVG with an available SVG-capable browser or renderer and inspect it visually. Check for clipping, text overlap, readable labels, aligned blocks, clean wire routing, correct symbols, and distinguishable arrows and clock triangles. Repair issues and inspect again.
4. Run `git diff --check` for repository changes. Link the final SVG and state any unavailable validation honestly; XML parsing alone does not establish visual correctness.
