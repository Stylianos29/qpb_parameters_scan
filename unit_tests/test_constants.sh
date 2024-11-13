#!/bin/bash


# TODO: Write description
######################################################################
# unit_tests/test_output.sh - Script for 
#
#
######################################################################


# SOURCE DEPENDENCIES

LIBRARY_SCRIPTS_DIRECTORY_FULL_PATH="$(realpath ../library)"
# Source all custom functions scripts from "qpb_parameters_scan/library" using a
# loop avoiding this way name-specific sourcing and thus potential typos
for library_script in "$LIBRARY_SCRIPTS_DIRECTORY_FULL_PATH"/*;
do
    # Check if the current file in the loop is a regular file
    if [ -f "$library_script" ]; then
        source "$library_script"
    fi
done
unset LIBRARY_SCRIPTS_DIRECTORY_FULL_PATH

# COMMAND-LINE ARGUMENTS CHECKS

unittest_option_default_value="-v"
# Check if an argument is provided; if not, use the default value
unittest_option=${1:-$unittest_option_default_value}

# CUSTOM CONSTANTS VALUES UNIT TESTS

test_BARE_ITERABLE_PARAMETERS_NAMES_ARRAY() {

    local tested_array="BARE_ITERABLE_PARAMETERS_NAMES_ARRAY"
    local expected_array=("GAUGE_LINKS_CONFIGURATION_LABEL" "NUMBER_OF_VECTORS"\
            "APE_ITERATIONS" "APE_ALPHA" "CLOVER_TERM_COEFFICIENT" "BARE_MASS" \
            "KAPPA_VALUE")

    assert_arrays_equal "$tested_array" expected_array
}


test_BARE_INVERT_ITERABLE_PARAMETERS_NAMES_ARRAY() {

    local tested_array="BARE_INVERT_ITERABLE_PARAMETERS_NAMES_ARRAY"
    local expected_array=("GAUGE_LINKS_CONFIGURATION_LABEL" "NUMBER_OF_VECTORS"\
            "APE_ITERATIONS" "APE_ALPHA" "CLOVER_TERM_COEFFICIENT" "BARE_MASS" \
            "KAPPA_VALUE" "SOLVER_EPSILON" "SOLVER_MAX_ITERATIONS")

    assert_arrays_equal "$tested_array" expected_array
}


test_CHEBYSHEV_ITERABLE_PARAMETERS_NAMES_ARRAY() {

    local tested_array="CHEBYSHEV_ITERABLE_PARAMETERS_NAMES_ARRAY"
    local expected_array=("GAUGE_LINKS_CONFIGURATION_LABEL" "NUMBER_OF_VECTORS"\
            "APE_ITERATIONS" "APE_ALPHA" "CLOVER_TERM_COEFFICIENT" "BARE_MASS" \
            "RHO_VALUE" "NUMBER_OF_CHEBYSHEV_TERMS" "LANCZOS_EPSILON" \
            "LANCZOS_MAX_ITERATIONS" "DELTA_MIN" "DELTA_MAX")

    assert_arrays_equal "$tested_array" expected_array
}


test_CHEBYSHEV_INVERT_ITERABLE_PARAMETERS_NAMES_ARRAY() {

    local tested_array="CHEBYSHEV_INVERT_ITERABLE_PARAMETERS_NAMES_ARRAY"
    local expected_array=("GAUGE_LINKS_CONFIGURATION_LABEL" "NUMBER_OF_VECTORS"\
            "APE_ITERATIONS" "APE_ALPHA" "CLOVER_TERM_COEFFICIENT" "BARE_MASS" \
            "RHO_VALUE" "NUMBER_OF_CHEBYSHEV_TERMS" "LANCZOS_EPSILON" \
            "LANCZOS_MAX_ITERATIONS" "DELTA_MIN" "DELTA_MAX" "SOLVER_EPSILON" \
            "SOLVER_MAX_ITERATIONS")

    assert_arrays_equal "$tested_array" expected_array
}


test_KL_ITERABLE_PARAMETERS_NAMES_ARRAY() {

    local tested_array="KL_ITERABLE_PARAMETERS_NAMES_ARRAY"
    local expected_array=("GAUGE_LINKS_CONFIGURATION_LABEL" "NUMBER_OF_VECTORS"\
            "APE_ITERATIONS" "APE_ALPHA" "CLOVER_TERM_COEFFICIENT" "BARE_MASS" \
            "RHO_VALUE" "KL_DIAGONAL_ORDER" "SOLVER_INNER_EPSILON" \
            "SOLVER_INNER_MAX_ITERATIONS" "SCALING_FACTOR")

    assert_arrays_equal "$tested_array" expected_array
}


test_KL_INVERT_ITERABLE_PARAMETERS_NAMES_ARRAY() {

    local tested_array="KL_INVERT_ITERABLE_PARAMETERS_NAMES_ARRAY"
    local expected_array=("GAUGE_LINKS_CONFIGURATION_LABEL" "NUMBER_OF_VECTORS"\
            "APE_ITERATIONS" "APE_ALPHA" "CLOVER_TERM_COEFFICIENT" "BARE_MASS" \
            "RHO_VALUE" "KL_DIAGONAL_ORDER" "SOLVER_INNER_EPSILON" \
            "SOLVER_INNER_MAX_ITERATIONS" "SCALING_FACTOR" "SOLVER_EPSILON" \
            "SOLVER_MAX_ITERATIONS")

    assert_arrays_equal "$tested_array" expected_array
}


unittest $unittest_option