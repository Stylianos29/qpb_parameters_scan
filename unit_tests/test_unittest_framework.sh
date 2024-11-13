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

test_assert_arrays_equal() {

    local test_function_name="assert_arrays_equal"
    local tested_array expected_array
    local test_passed="True"

    # POSITIVE TEST

    tested_array=("apples" "bananas" "oranges")
    expected_array=("apples" "bananas" "oranges")

    assert_arrays_equal tested_array expected_array || test_passed="False"

    # NEGATIVE TESTS

    # Similar elements
    tested_array=("apples" "bananas" "oranges")
    expected_array=("apples" "bananas" "Oranges")

    ! assert_arrays_equal tested_array expected_array > /dev/null 2>&1 \
                                                        || test_passed="False"

    # Arrays of different length
    tested_array=("apples" "bananas" "oranges")
    expected_array=("apples" "bananas" "Oranges" "peaches")

    ! assert_arrays_equal tested_array expected_array > /dev/null 2>&1 \
                                                        || test_passed="False"

    # OUTPUT

    if [[ "$test_passed" == "True" ]]; then
        echo "- Testing '$test_function_name' function successful."
    else
        echo "- Testing '$test_function_name' function failed."
    fi
}


test_assert_function_output() {

    local test_function_name="assert_function_output"
    local test_input_value expected_output_value
    local test_passed="True"

    # Helper mock function
    my_test_function() {
        echo "Hello, $1!"
    }

    # POSITIVE TEST

    test_input_value="world"
    expected_output_value="Hello, world!"

    assert_function_output my_test_function "$test_input_value" \
                                "$expected_output_value" || test_passed="False"

    # NEGATIVE TEST

    test_input_value="world"
    expected_output_value="Hello, planet!"

    ! assert_function_output my_test_function "$test_input_value" \
                                "$expected_output_value" > /dev/null 2>&1 \
                                                        || test_passed="False"

    # OUTPUT

    if [[ "$test_passed" == "True" ]]; then
        echo "- Testing '$test_function_name' function successful."
    else
        echo "- Testing '$test_function_name' function failed."
    fi
}


test_assert_multiple_function_outputs() {

    local test_function_name="assert_multiple_function_outputs"
    local test_input_values_array expected_outputs_arrays
    local test_passed="True"

    # Helper mock function
    my_test_function() {
        echo "Hello, $1!"
    }

    # POSITIVE TEST

    test_input_values_array=("world" "there")
    expected_outputs_arrays=("Hello, world!" "Hello, there!")

    assert_multiple_function_outputs my_test_function test_input_values_array \
                                expected_outputs_arrays || test_passed="False"

    # NEGATIVE TEST

    test_input_values_array=("world" "there")
    expected_outputs_arrays=("Hello, world!" "Hello, everybody!")

    ! assert_multiple_function_outputs my_test_function test_input_values_array \
                expected_outputs_arrays > /dev/null 2>&1 || test_passed="False"

    # OUTPUT

    if [[ "$test_passed" == "True" ]]; then
        echo "- Testing '$test_function_name' function successful."
    else
        echo "- Testing '$test_function_name' function failed."
    fi
}


test_assert_validation_function() {

    local test_function_name="assert_validation_function"
    local test_input_value expected_status
    local test_passed="True"

    # Helper mock functions
    test_example_pass() {
        # Add test code that passes
        return 0
    }
    
    test_example_fail() {
        # Add test code that fails
        return 1
    }

    test_input_value="anything"

    # POSITIVE TESTS

    expected_status="0"

    assert_validation_function test_example_pass "$test_input_value" \
                                    "$expected_status" || test_passed="False"

    expected_status="True"

    assert_validation_function test_example_pass "$test_input_value" \
                                "$expected_status" || test_passed="False"

    expected_status="TRUE"

    assert_validation_function test_example_pass "$test_input_value" \
                                "$expected_status" || test_passed="False"

    expected_status="1"

    assert_validation_function test_example_fail "$test_input_value" \
                                "$expected_status" || test_passed="False"

    expected_status="False"

    assert_validation_function test_example_fail "$test_input_value" \
                                "$expected_status" || test_passed="False"
    
    expected_status="FALSE"

    assert_validation_function test_example_fail "$test_input_value" \
                                "$expected_status" || test_passed="False"

    # NEGATIVE TESTS

    expected_status="0"

    ! assert_validation_function test_example_fail "$test_input_value" \
                    "$expected_status" > /dev/null 2>&1 || test_passed="False"

    expected_status="True"

    ! assert_validation_function test_example_fail "$test_input_value" \
                    "$expected_status" > /dev/null 2>&1 || test_passed="False"

    expected_status="TRUE"

    ! assert_validation_function test_example_fail "$test_input_value" \
                    "$expected_status" > /dev/null 2>&1 || test_passed="False"

    expected_status="1"

    ! assert_validation_function test_example_pass "$test_input_value" \
                    "$expected_status" > /dev/null 2>&1 || test_passed="False"

    expected_status="False"

    ! assert_validation_function test_example_pass "$test_input_value" \
                    "$expected_status" > /dev/null 2>&1 || test_passed="False"
    
    expected_status="FALSE"

    ! assert_validation_function test_example_pass "$test_input_value" \
                    "$expected_status" > /dev/null 2>&1 || test_passed="False"

    # OUTPUT

    if [[ "$test_passed" == "True" ]]; then
        echo "- Testing '$test_function_name' function successful."
    else
        echo "- Testing '$test_function_name' function failed."
    fi
}


test_assert_multiple_validation_function_cases() {

    local test_function_name="assert_multiple_validation_function_cases"
    local test_input_values_array expected_status_arrays
    local test_passed="True"

    # Helper mock functions
    test_example_pass() {
        # Add test code that passes
        return 0
    }
    
    test_example_fail() {
        # Add test code that fails
        return 1
    }

    test_input_values_array=("anything" "goes" "here")
    
    # POSITIVE TESTS

    expected_status_arrays=("0" "True" "TRUE")

    assert_multiple_validation_function_cases test_example_pass \
        test_input_values_array expected_status_arrays || test_passed="False"

    expected_status_arrays=("1" "False" "FALSE")

    assert_multiple_validation_function_cases test_example_fail \
        test_input_values_array expected_status_arrays || test_passed="False"

    # NEGATIVE TESTS

    expected_status_arrays=("0" "True" "TRUE")

    ! assert_multiple_validation_function_cases test_example_fail \
                            test_input_values_array expected_status_arrays \
                                        > /dev/null 2>&1 || test_passed="False"

    expected_status_arrays=("1" "False" "FALSE")

    ! assert_multiple_validation_function_cases test_example_pass \
                            test_input_values_array expected_status_arrays \
                                        > /dev/null 2>&1 || test_passed="False"

    # OUTPUT

    if [[ "$test_passed" == "True" ]]; then
        echo "- Testing '$test_function_name' function successful."
    else
        echo "- Testing '$test_function_name' function failed."
    fi
}


# Get a list of all functions starting with "test_"
test_functions_list=$(declare -F | awk '{print $3}' | grep '^test_')
# Run each test function
for test_func in $test_functions_list; do
    $test_func
done
