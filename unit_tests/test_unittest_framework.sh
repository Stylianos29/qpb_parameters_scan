#!/bin/bash


# TODO: Write description
######################################################################
# unit_tests/test_unittest_framework.sh - Script for 
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

# CUSTOM FUNCTIONS UNIT TESTS

# test_multiple_assert_validation()
# {
#     # Trivial helper function
#     is_equal_to_10() {
#         local value="$1"

#         if [[ "$value" -eq 10 ]]; then
#             return 0  # Indicates success, meaning the value is equal to 10
#         else
#             return 1  # Indicates failure, meaning the value is not equal to 10
#         fi
#     }

#     local test_input_list=(10 0 -10 "Test")
#     local expected_output_list=("True" "False" "False" "False")

#     local test_function_name="is_equal_to_10"

#     multiple_assert_validation $test_function_name test_input_list \
#                                                             expected_output_list
#     if [ $? -eq 0 ]; then
#         echo "Testing '$test_function_name' function successful."
#     fi
# }


test_assert_array() {

    local test_function_name="test_assert_array"
    local tested_array expected_array
    local test_passed="True"

    # POSITIVE TEST

    tested_array=("apples" "bananas" "oranges")
    expected_array=("apples" "bananas" "oranges")

    assert_array tested_array expected_array || test_passed="False"

    # NEGATIVE TESTS

    # Similar elements
    tested_array=("apples" "bananas" "oranges")
    expected_array=("apples" "bananas" "Oranges")

    ! assert_array tested_array expected_array || test_passed="False"

    # Arrays of different length
    tested_array=("apples" "bananas" "oranges")
    expected_array=("apples" "bananas" "Oranges" "peaches")

    ! assert_array tested_array expected_array || test_passed="False"

    if [[ "$test_passed" == "False" ]]; then
        echo "Testing '$test_function_name' function failed."
    fi
}

test_assert_array