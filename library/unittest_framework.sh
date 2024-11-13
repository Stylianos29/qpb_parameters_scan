#!/bin/bash


# TODO: Write description
######################################################################
# library/unittest_framework.sh - Script for 
#
#
######################################################################

# MULTIPLE SOURCING GUARD

# Prevent multiple sourcing of this script by exiting if
# UNITTEST_FRAMEWORK_SH_INCLUDED is already set. Otherwise, set
# UNITTEST_FRAMEWORK_SH_INCLUDED to mark it as sourced.
[[ -n "${UNITTEST_FRAMEWORK_SH_INCLUDED}" ]] && return
UNITTEST_FRAMEWORK_SH_INCLUDED=1

# SOURCE DEPENDENCIES

LIBRARY_SCRIPTS_DIRECTORY_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source all custom functions scripts from "qpb_parameters_scan/library" using a
# loop avoiding this way name-specific sourcing and thus potential typos
for library_script in "$LIBRARY_SCRIPTS_DIRECTORY_PATH";
do
    # Check if the current file in the loop is a regular file
    if [ -f "$library_script" ]; then
        source "$library_script"
    fi
done
unset LIBRARY_SCRIPTS_DIRECTORY_PATH

# FUNCTIONS DEFINITIONS

assert_arrays_equal() {
:   '
    Function: assert_arrays_equal
    Description: Compares two arrays and asserts whether they are equal in terms
    of both length and content. Returns success (0) if the arrays are equal, or 
    failure (1) if they are not.

    Parameters:
    - tested_array_name (string): The name of the array to be tested. This array
     is passed by name, and its contents will be compared to the expected array.
    - expected_array_name (string): The name of the array containing the 
    expected values. This array is also passed by name, and its contents will 
    be compared with the tested array.

    Returns:
    - 0: If the arrays are equal in both length and content.
    - 1: If the arrays are either of different lengths or contain different 
      elements.

    Usage Example:
    TESTED_ARRAY=("apple" "banana" "cherry")
    EXPECTED_ARRAY=("apple" "banana" "cherry")
    assert_arrays_equal TESTED_ARRAY EXPECTED_ARRAY
    # This will return 0 (success) since the arrays are equal.

    Notes:
    - The function uses `check_arrays_same_length` to first verify that the 
      arrays are of the same length before comparing their contents.
    - If the arrays are of different lengths, an error message is printed 
      and the function returns 1.
    - The arrays are compared as strings, meaning that their elements must 
      be in the same order to be considered equal.
    '
    
    local tested_array_name=$1               # Name of the tested array
    local expected_array_name=$2             # Name of the expected array

    check_arrays_same_length $tested_array_name $expected_array_name 
    if [ $? -ne 0 ]; then
        error_message="ERROR: Passed arrays are not of the same length."
        echo "$error_message"
        return 1
    fi

    # Create a reference to the tested array
    local -n tested_array_reference=$tested_array_name
    # Create a reference to the expected array
    local -n expected_array_reference=$expected_array_name

    # Compare arrays as strings
    if [[ "${tested_array_reference[*]}" == "${expected_array_reference[*]}" ]];
     then
        return 0  # Success
    else
        error_message="ERROR: Passed arrays are not identical."
        echo "$error_message"
        return 1  # Failure
    fi
}


assert_function_output() {
:   '
    Function: assert_function_output
    Description: Compares the output of a function when given a specific 
    input to the expected output. If the actual output matches the expected 
    output, the function returns success (0); otherwise, it returns failure (1).

    Parameters:
    - function_name (string): The name of the function to be tested. This 
      function must accept a single input argument and produce an output.
    - input_value (string): The input to be passed to the function under test.
      The input should be a string value.
    - expected_output (string): The expected output that the function should 
      return when given the input_value.

    Returns:
    - 0: If the actual output of the function matches the expected output.
    - 1: If the actual output differs from the expected output.

    Usage Example:
    test_function() {
        echo "Hello, $1!"
    }

    assert_function_output test_function "World" "Hello, World!"
    # This will return 0 (success) since the function output matches the
    # expected output.

    Notes:
    - The function compares outputs using a simple string comparison.
    - The function returns success if the actual output and expected output 
      are identical.
    - If the outputs differ, an error message will not be printed in this 
      function, but the return code will indicate failure.
    '
    
    local function_name="$1"   # Name of the function to be tested
    local input_value="$2"     # Input to the function under test
    local expected_output="$3" # Expected output from the function

    # Capture the actual output of the function with the provided input
    local actual_output="$($function_name "$input_value")"

    # Compare the actual output to the expected output
    if [ "$actual_output" == "$expected_output" ]; then
        return 0  # Success
    else
        error_message="ERROR: Test failed for input: '$input_value'. Actual "
        error_message+="output: '$($function_name "$input_value")', "
        error_message+="but got: '$expected_output'."
        echo "$error_message"
        return 1  # Failure
    fi
}


assert_multiple_function_outputs() {
:   '
    Function: assert_multiple_function_outputs
    Description: Tests a function against multiple input-output pairs to verify 
    that its output matches the expected output for each input value. This 
    wrapper function calls "assert_function_output" for each pair and returns 
    success only if all tests pass.

    Parameters:
    - function_name (string): The name of the function to be tested. The
      function must accept a single input argument and produce an output.
    - input_array_name (string): The name of the array containing input values 
      to be passed to the function under test. This array is passed by name.
    - expected_output_array_name (string): The name of the array containing the 
      expected outputs corresponding to each input in the input array. This 
      array is passed by name.

    Returns:
    - 0: If the function output matches the expected output for all input
      values.
    - 1: If any test fails, an error message is printed indicating the input 
      value that failed, the actual output, and the expected output.

    Usage Example:
    test_function() {
        echo "Hello, $1!"
    }
    
    INPUT_VALUES=("World" "Alice" "Bob")
    EXPECTED_OUTPUTS=("Hello, World!" "Hello, Alice!" "Hello, Bob!")
    
    assert_multiple_function_outputs test_function INPUT_VALUES EXPECTED_OUTPUTS
    # This will return 0 (success) if all actual outputs match the expected
    # outputs.

    Notes:
    - This function relies on "assert_function_output" to perform the individual 
      output comparisons.
    - The input and expected output arrays must have the same length. If they
      do not, the function will print an error message and return failure (1).
    - Upon encountering the first test failure, the function outputs a message 
      indicating the failing input, the actual output, and the expected
      output, then exits.
    '
    
    local function_name="$1"
    local input_array_name="$2"
    local expected_output_array_name="$3"

    check_arrays_same_length $input_array_name $expected_output_array_name
    if [ $? -ne 0 ]; then
        error_message="ERROR: Passed arrays are not of the same length."
        echo "$error_message"
        return 1
    fi

    # Referencing the arrays by name
    local -n input_array_reference=$input_array_name
    local -n expected_output_array_reference=$expected_output_array_name

    # Loop through the input and expected output arrays
    for index in "${!input_array_reference[@]}"; do
        local input="${input_array_reference[$index]}"
        local expected_output="${expected_output_array_reference[$index]}"

        # Call "assert_function_output" for each input/output pair
        assert_function_output "$function_name" "$input" "$expected_output" \
                                                              > /dev/null 2>&1
        # Check if the test passed or failed
        if [ $? -ne 0 ]; then
            error_message="ERROR: Test failed for input: '$input'. Actual "
            error_message+="output: '$($function_name "$input")', "
            error_message+="but got: '$expected_output'."
            echo "$error_message"
            return 1  # Exit on the first failure
        fi
    done

    return 0
}


assert_validation_function() {
:   '
    Function: assert_validation_function
    # Description: Tests a validation function that takes a single argument as
    # input and returns 0 (success) if the input satisfies the validation
    # criteria or 1 (failure) if it does not.

    Parameters:
    - validation_function_name (string): The name of the validation function
      to be tested. This function should accept one argument and return 0 for
      valid input or 1 for invalid input.
    - test_input (string/int): The input value to pass to the validation
      function.
    - expected_status (string/int): The expected return status. Accepts 0,
      "True", "TRUE" for success; 1, "False", or "FALSE" for failure.

    Returns:
    - 0 (Success) if the output of the validation function matches the
      expected status.
    - 1 (Failure) if the output of the validation function does not match the
      expected status.

    Usage Example:
    assert_validation_function "is_greater_than_10" 15 "True" # Expected: Passes
    assert_validation_function "is_greater_than_10" 5 "FALSE" # Expected: Passes
    assert_validation_function "is_greater_than_10" 10 1      # Expected: Passes

    Notes:
    - This function is intended for testing validation functions that return 0
      for a pass and 1 for a fail without producing other output.
    '

    local validation_function_name="$1"
    local test_input="$2"
    local expected_status="$3"

    # Normalize expected_status to either 0 (success) or 1 (failure)
    case "$expected_status" in
        0 | "True" | "TRUE")
            expected_status=0
            ;;
        1 | "False" | "FALSE")
            expected_status=1
            ;;
        *)
            error_message="ERROR: Invalid expected_status value. Use 0, 1, "
            error_message+="'True', 'TRUE', 'False', or 'FALSE'."
            echo "$error_message"
            return 1
            ;;
    esac

    # Call the validation function with the test input
    "$validation_function_name" "$test_input"
    local actual_status=$?

    # Compare the actual status with the expected status
    if [ "$actual_status" -eq "$expected_status" ]; then
        return 0  # Success
    else
        error_message="ERROR: Validation failed for '$validation_function_name'"
        error_message+=" with input '$test_input'. Expected status: "
        error_message+="$actual_status, but got: $expected_status."
        echo "$error_message"
        return 1  # Failure
    fi
}


assert_multiple_validation_function_cases() {
:   '
    Function: assert_multiple_validation_function_cases
    Description: Executes a specified validation function against multiple test 
    cases, comparing each result with an expected status and reporting any 
    mismatches. This function serves as a wrapper to simplify batch testing of 
    validation functions by leveraging "assert_validation_function".

    Parameters:
    - validation_function_name (string): The name of the validation function 
      to be tested. The function should accept one argument and return 0 for 
      success or 1 for failure.
    - input_array_name (string): The name of an array containing inputs to pass 
      to the validation function. This array is passed by name.
    - expected_status_array_name (string): The name of an array containing the 
      expected validation statuses (0, "True", or "TRUE" for success; 
      1, "False", or "FALSE" for failure). This array is passed by name.

    Returns:
    - 0 if all test cases pass.
    - 1 if any test case fails, with an error message indicating the failed 
      input and the mismatch between actual and expected status.

    Usage Example:
    INPUTS=(8 12 5)
    EXPECTED_STATUSES=(1 0 1)
    assert_multiple_validation_function_cases "is_greater_than_10" \
                                               "INPUTS" \
                                               "EXPECTED_STATUSES"
    # Expected output (if verbose): ERROR: Test failed for input: '8'. Actual 
    # output: '1', but expected: '0'.

    Notes:
    - This function calls "assert_validation_function" for each input and 
      status pair, exiting on the first failed case.
    - Both input and expected status arrays must have the same length.
    - "check_arrays_same_length" is used to validate array lengths prior to 
      testing.
    '
    
    local validation_function_name="$1"
    local input_array_name="$2"
    local expected_status_array_name="$3"

    check_arrays_same_length "$input_array_name" "$expected_status_array_name"
    if [ $? -ne 0 ]; then
        error_message="ERROR: Passed arrays are not of the same length."
        echo "$error_message"
        return 1
    fi

    # Referencing the arrays by name
    local -n input_array_reference="$input_array_name"
    local -n expected_status_array_reference="$expected_status_array_name"

    # Loop through the inputs and expected statuses
    for index in "${!input_array_reference[@]}"; do
        local input="${input_array_reference[$index]}"
        local expected_status="${expected_status_array_reference[$index]}"

        # Use "assert_validation_function" for each input/status pair
        assert_validation_function "$validation_function_name" "$input" \
                                            "$expected_status" > /dev/null 2>&1
        # Check if the test passed or failed
        if [ $? -ne 0 ]; then
            error_message="ERROR: Test failed for input: '$input'. Actual "
            error_message+="output: '$($validation_function_name "$input")', "
            error_message+="but expected: '$expected_status'."
            echo "$error_message"
            return 1  # Exit on the first failure
        fi
    done

    return 0
}


unittest() { # Not unit-tested
:   '
    Function: unittest
    Description: Runs all functions in the script with names starting with 
    "test_" as unit tests, keeping track of passed and failed tests. Provides a 
    summary at the end, with an optional verbose mode for detailed output.

    Parameters:
    - -v, --verbose (optional flag): If provided, enables verbose mode, which 
      prints the summary of passed and failed tests regardless of the number of 
      failures.

    Returns:
    - 0: Always returns 0 after completing the tests, with the summary output 
      reflecting the results of individual test functions.
    
    Usage Example:
    # Define test functions in the script
    test_example_pass() {
        # Add test code that passes
        return 0
    }
    
    test_example_fail() {
        # Add test code that fails
        return 1
    }
    
    # Run all test functions using unittest with verbose mode
    unittest -v

    Notes:
    - This function identifies test functions by looking for all functions in 
      the script with names that start with "test_".
    - Each test function should return 0 for success and any non-zero value for 
      failure.
    - The verbose flag (-v or --verbose) controls whether a detailed summary 
      of results is printed regardless of test outcomes.
    - The summary includes the number of passed and failed tests, and prints 
      the name of each failing test function.
    '

    local verbose=0            # Flag for enabling verbose output

    # Parse the optional argument
    if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
        verbose=1
    fi

    local passed=0             # Counter for passed tests
    local failed=0             # Counter for failed tests

    # Get a list of all functions starting with "test_"
    local test_functions_list=$(declare -F | awk '{print $3}' | grep '^test_')

    # Run each test function and capture the results
    for test_func in $test_functions_list; do
        $test_func
        if [ $? -eq 0 ]; then
            (( passed++ ))
        else
            echo "'$test_func' failed!"
            (( failed++ ))
        fi
    done

    # Print the summary if verbose is enabled or if there are failed tests
    if [ $verbose -eq 1 ] || [ $failed -ne 0 ]; then
        echo
        echo "Tests summary for '$(basename "$0")' script:"
        echo "Passed: $passed"
        echo "Failed: $failed"
        echo
    fi
}
