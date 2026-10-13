#!/bin/sh
# File: run_checks.sh
# Project: trama-efpga
# Author: luke
# Description: Run Verilator RTL lint and Icarus four-state primitive tests.

set -eu

if [ "$#" -gt 1 ]; then
    echo "Usage: sh tb/run_checks.sh [all|lint|test]" >&2
    exit 2
fi
mode=${1:-all}
case "$mode" in
    all|lint|test) ;;
    *) echo "Usage: sh tb/run_checks.sh [all|lint|test]" >&2; exit 2 ;;
esac

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

require_tool() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Missing required tool: $1. See docs/environment_setup.md." >&2
        exit 1
    fi
}

# Check dependencies before starting either stage of the combined workflow.
case "$mode" in all|lint) require_tool verilator ;; esac
case "$mode" in all|test) require_tool iverilog; require_tool vvp ;; esac

if [ "$mode" = all ] || [ "$mode" = lint ]; then
    lint_count=0
    # Separate tops ensure every primitive is linted without MULTITOP waivers.
    for primitive in mux2 mux4 latch latch_reset latch_set; do
        echo "Lint: $primitive"
        # DECLFILENAME is intentional for this shared implementation file only.
        verilator --lint-only --language 1800-2012 -Wall -Wno-DECLFILENAME \
            --Mdir build/verilator_lint --top-module "$primitive" \
            rtl/primitives/behavioral/basic_primitives.sv
        lint_count=$((lint_count + 1))
    done
    echo "PASS: RTL lint ($lint_count primitives)"
fi

if [ "$mode" = all ] || [ "$mode" = test ]; then
    mkdir -p build
    for bench in basic_primitives controlled_latches; do
        iverilog -g2012 -Wall -s "${bench}_tb" -o "build/${bench}.vvp" \
            rtl/primitives/behavioral/basic_primitives.sv \
            "tb/primitives/${bench}_tb.sv"
        vvp "build/${bench}.vvp"
    done
fi

# End of file
