#!/bin/bash


# TODO: Write description
######################################################################
# unit_tests/test_auxiliary.sh - Script for 
#
#
######################################################################


# SOURCE DEPENDENCIES

LIBRARY_SCRIPTS_DIRECTORY_FULL_PATH="$(realpath ../library)"
# Source all custom functions scripts from "qpb_parameters_scan/library" using a
# loop avoiding this way name-specific sourcing and thus potential typos
for library_script in "$LIBRARY_SCRIPTS_DIRECTORY_FULL_PATH";
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

# CUSTOM FUNCTIONS UNIT TESTS

test_check_directory_path_failed()
{
    test_directory_path="/path/to/directory"
    expected_output=1

    output=($(check_directory_path $test_directory_path))

    assert $output $expected_output
}


test_check_directory_path_successful()
{
    test_directory_path="../library"
    expected_output=0

    output=($(check_directory_path $test_directory_path))

    assert $output $expected_output
}


test_is_decimal_number()
{
    test_values_list=("1.2" "something" "28.9191" "-0.5")
    expected_outputs_list=(0 1 0 0)

    multiple_assert is_decimal_number test_values_list expected_outputs_list
}


test_modify_decimal_format()
{
    local TESTED_FUNCTION_NAME="modify_decimal_format"
    local ERROR_MESSAGE="\nError: '$TESTED_FUNCTION_NAME' function"

    # Case of valid float input
    parameter_value="15.69"
    parameter_value=$(modify_decimal_format "$parameter_value")
    assert "$parameter_value" "15p69" || {
        echo -e "$ERROR_MESSAGE gives incorrect output for valid float input"\
        "values";
        return 1;
        }

    # Case of valid exponential input
    parameter_value="1.23e-4"
    parameter_value=$(modify_decimal_format "$parameter_value")
    assert "$parameter_value" "1p23e-4" || {
    echo -e "$ERROR_MESSAGE gives incorrect output for valid exponential input"\
        "values";
        return 1;
        }

    # Case of valid integer input
    parameter_value="123"
    parameter_value=$(modify_decimal_format "$parameter_value")
    assert "$parameter_value" "123" || {
    echo -e "$ERROR_MESSAGE gives incorrect output for valid integer input"\
        "values";
        return 1;
        }

}


unittest $unittest_option
