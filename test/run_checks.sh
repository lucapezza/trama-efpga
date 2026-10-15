#!/bin/sh
# File: run_checks.sh
# Project: trama-efpga
# Author: luke
# Description: Run Verilator RTL lint and Icarus four-state hardware tests.

set -eu

if [ "$#" -gt 1 ]; then
    echo "Usage: sh test/run_checks.sh [all|lint|test]" >&2
    exit 2
fi
mode=${1:-all}
case "$mode" in
    all|lint|test) ;;
    *) echo "Usage: sh test/run_checks.sh [all|lint|test]" >&2; exit 2 ;;
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
    for primitive in mux2 mux4 latch latch_reset latch_set ff; do
        echo "Lint: $primitive"
        # DECLFILENAME is intentional for this shared implementation file only.
        verilator --lint-only --language 1800-2012 -Wall -Wno-DECLFILENAME \
            --Mdir build/verilator_lint --top-module "$primitive" \
            rtl/basic_primitives.sv
        lint_count=$((lint_count + 1))
    done
    echo "Lint: config_memory_element (10 bits, 4 columns, 3 rows)"
    verilator --lint-only --language 1800-2012 -Wall -Wno-DECLFILENAME \
        --Mdir build/verilator_lint --top-module config_memory_element \
        -GNUM_BITS=10 -GNUM_COLUMNS=4 -GNUM_ROWS=3 \
        rtl/basic_primitives.sv rtl/config_memory_element.sv
    echo "Lint: logic_element"
    verilator --lint-only --language 1800-2012 -Wall -Wno-DECLFILENAME \
        --Mdir build/verilator_lint --top-module logic_element \
        rtl/basic_primitives.sv rtl/logic_element.sv
    echo "PASS: RTL lint ($lint_count primitives, config_memory_element, logic_element)"
fi

if [ "$mode" = all ] || [ "$mode" = test ]; then
    mkdir -p build
    iverilog -g2012 -Wall -s basic_primitives_tb -o build/basic_primitives.vvp \
        rtl/basic_primitives.sv \
        test/basic_primitives_tb.sv
    vvp build/basic_primitives.vvp

    iverilog -g2012 -Wall -s ff_tb -o build/ff.vvp \
        rtl/basic_primitives.sv test/ff_tb.sv
    vvp build/ff.vvp

    iverilog -g2012 -Wall -s logic_element_tb -o build/logic_element.vvp \
        rtl/basic_primitives.sv rtl/logic_element.sv test/logic_element_tb.sv
    vvp build/logic_element.vvp

    iverilog -g2012 -Wall -s config_memory_element_tb \
        -o build/config_memory_element.vvp \
        rtl/basic_primitives.sv rtl/config_memory_element.sv \
        test/config_memory_element_tb.sv
    vvp build/config_memory_element.vvp

    # Require failure AND the intended diagnostic, not an unrelated crash.
    for invalid_case in 0 1 2 3 4 5 6 7; do
        iverilog -g2012 -Wall -s config_memory_element_invalid_tb \
            -Pconfig_memory_element_invalid_tb.CASE_TB="$invalid_case" \
            -o build/config_memory_element_invalid.vvp \
            rtl/basic_primitives.sv rtl/config_memory_element.sv \
            test/config_memory_element_invalid_tb.sv
        if vvp build/config_memory_element_invalid.vvp > build/config_memory_element_invalid.log 2>&1; then
            echo "FAIL: invalid configuration case $invalid_case was accepted" >&2
            exit 1
        fi
        case "$invalid_case" in
            0|1|2|3|4|5) expected_message="config_memory_element: parameters must be positive" ;;
            6|7) expected_message="config_memory_element: NUM_ROWS must equal ceil(NUM_BITS / NUM_COLUMNS)" ;;
        esac
        case "$(cat build/config_memory_element_invalid.log)" in
            *"$expected_message"*) ;;
            *) cat build/config_memory_element_invalid.log >&2; exit 1 ;;
        esac
    done
    echo "PASS: config_memory_element (8 invalid parameter cases rejected)"
fi

# End of file
