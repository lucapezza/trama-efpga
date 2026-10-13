---
name: code-file-comments
description: Apply comment headers and end-of-file trailers when creating, editing, or reviewing hand-written code files in any language, including RTL, testbenches, software tools, and scripts. Excludes Markdown, generated files, third-party sources, and formats without comments.
---

# Code File Headers and Trailers

## Required content

Every hand-written code file must begin with a comment header containing:

- `File`: the file basename.
- `Project`: `trama-efpga`.
- `Author`: `luke`; preserve existing authorship and license notices.
- `Description`: a short, accurate statement of the file's purpose.

Do not include dates or revision histories. Git records changes.

End the file with a comment saying `End of file`. An existing basename suffix, such as `End of file: lut.sv`, is acceptable; keep it accurate when renaming. The trailer must be the final nonblank line.

## Language-specific comments

Use the language's valid comment syntax. Place the header after any required shebang, encoding declaration, or other mandatory file prologue. Keep required language directives in valid positions.

SystemVerilog example:

```systemverilog
// File: lut.sv
// Project: trama-efpga
// Author: luke
// Description: Behavioral lookup table primitive.

// End of file
```

Python or shell example:

```python
# File: generate_bitstream.py
# Project: trama-efpga
# Author: luke
# Description: Generate configuration bitstreams.

# End of file
```

Use suitable line or block comments for other languages, such as `//` for C++ and `/* ... */` for C. Do not add comments to formats that prohibit them, such as strict JSON. Markdown, generated files, and third-party sources are exempt.

## Optional fields and maintenance

Include `Assumptions` for relevant clock/reset behavior, configuration requirements, or parameter limits, and `References` for useful design documentation. Include `SPDX-License-Identifier` only after a project license has been selected; preserve existing license notices.

Update comments when the file's purpose or name changes. Apply the convention within the requested scope, without rewriting unrelated files. During a review, report missing or inconsistent comments rather than editing unless requested. Verify that comments use valid syntax and the trailer is the final nonblank line.
