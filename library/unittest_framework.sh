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

assert() {
:   '
    Function to assert the equality of two single values
    Usage: assert $value1 $value2
    Arguments:
        * value1: The first value to compare.
        * value2: The second value to compare.
    Returns:
        * 0 (true) if the values are equal.
        * 1 (false) if the values are not equal.
    Example:
        assert "hello" "hello"
        This returns 0 because the values are equal.
        assert "hello" "world"
        This returns 1 because the values are not equal.
    Notes:
       - The function compares the two values using the string quality 
       operator (==).
       - If the values are equal, the function returns 0, indicating success.
       - If the values are not equal, the function returns 1, indicating 
       failure.
    '

    local arg1="$1"
    local arg2="$2"

    if [ "$arg1" == "$arg2" ]; then
        return 0  # True 
    else
        return 1  # False
    fi
}


negative_assert() {
:   '
    Function: negative_assert
    Description: Asserts the opposite condition of the given command.
    Parameters:
      1. command (string): Command to be evaluated.
      2. error_message (string): Error message to display if the command fails.
    Returns:
      0 if the command fails (non-zero exit status), otherwise 1.
    Details:
      * Executes the specified command.
      * If the command fails (returns a non-zero exit status), it prints the 
      error_message
        to stderr and returns 0 (indicating failure).
      * Useful for testing scenarios where you expect a command to fail.
    Usage example:
      negative_assert \
          'validate_updated_constant_parameters_array "${LIST_OF_UPDATED_CONSTANT_VALUES[@]}"' \
          "$ERROR_MESSAGE must accept empty lists as valid input" || return 1
    '
    local command="$1"
    local error_message="$2"

    if eval "$command > /dev/null 2>&1"; then
        echo -e "$error_message" >&2
        return 1  # Return 1 for failure
    fi

    return 0  # Return 0 for success
}


multiple_assert() {
:   '
    Extension of the assert() function
    Description: This function iterates through two passed arrays and compares 
    the output of a specified function with the expected values. If the two 
    arrays are of different length or any assertion fails, it exits with a 
    status of 1.
    Usage: multiple_assert function_name input_values_array expected_values_array
    Parameters:
        $1 - The name of the function to be called for each test value.
        $2 - A nameref to an array containing the test values.
        $3 - A nameref to an array containing the expected values.
    Details:
        * The function uses local -n to create nameref variables, allowing the 
        arrays to be passed by reference.
        * It iterates over the test values array using a for loop.
        * For each test value, the specified function is called with the current
         test value, and the output is captured.
        * The assert function is used to compare the output with the expected 
        value.
        * If any assertion fails (i.e., assert returns 1), the function exits 
        with status 1.
        * If all assertions pass, the function exits with status 0.
    '

    local function_name="$1"
    shift
    local -n input_values_array=$1
    local -n expected_outputs_arrays=$2

    # Check if the passed arrays are of the same length
    if [ ${#input_values_array[@]} != ${#expected_outputs_arrays[@]} ]; then
        return 1
    fi

    for index in "${!input_values_array[@]}"; do
        output=$($function_name "${input_values_array[index]}")
        assert "$output" "${expected_outputs_arrays[index]}"

        if [ $? -eq 1 ]; then
            return 1
        fi
    done

    return 0
}


multiple_validation_assert() {
    # TODO: Write description

    local function_to_test="$1"
    local -n inputs="$2"            # Array of test inputs
    local -n expected_outputs="$3"  # Array of expected outputs
    local actual_output

    # Check if the lengths of the inputs and expected_outputs arrays are the
    # same
    if [ "${#inputs[@]}" -ne "${#expected_outputs[@]}" ]; then
        error_message="Error: The number of passed inputs (${#inputs[@]}) does "
        error_message+="not match the number of passed expected outputs "
        error_message+="(${#expected_outputs[@]})."
        echo $error_message
        return 1  # Return failure if lengths do not match
    fi

    for i in "${!inputs[@]}"; do
        local test_input="${inputs[$i]}"
        local expected="${expected_outputs[$i]}"

        # Run the specified function and determine actual output
        if "$function_to_test" "$test_input"; then
            actual_output="True"
        else
            actual_output="False"
        fi

        # Compare actual and expected outputs, stop if there's a mismatch
        if [ "$actual_output" != "$expected" ]; then
            error_message="Test of function '$function_to_test' failed for "
            error_message+="input '$test_input': expected '$expected', got "
            error_message+="'$actual_output'."
            echo "$error_message"
            return 1  # Stop further iteration and return failure
        fi
    done

    return 0  # Return success if all tests pass
}


array_assert() {
:   '
    Function to assert the equality of two arrays
    Usage: array_assert array1[@] array2[@]
    Arguments:
        * array1: The first array to compare, passed by reference.
        * array2: The second array to compare, passed by reference.
    Output:
        Prints a message indicating the index at which the arrays differ, 
        if any.
    Returns:
        * 0 (true) if the arrays are equal.
        * 1 (false) if the arrays are not equal.
    Example:
        array1=("one" "two" "three")
        array2=("one" "two" "three")
        array_assert array1[@] array2[@]
        This returns 0 because the arrays are equal.
        array3=("one" "two" "four")
        array_assert array1[@] array3[@]
        This returns 1 and prints "Arrays differ at index 2: three != four".
    Notes:
        - The function compares each element of the arrays.
        - If any elements differ, the function prints a message indicating the 
        index and values that differ.
        - The function returns 0 if the arrays are identical, and 1 if they 
        differ.
        - Both arrays must be of the same length; otherwise, it will only 
        compare up to the length of the shorter array.
    '

    local array1=("${!1}")
    local array2=("${!2}")

    for ((i = 0; i < ${#array2[@]}; i++)); do
        if [ "${array1[i]}" != "${array2[i]}" ]; then
            echo "Arrays differ at index $i: ${array1[i]} != ${array2[i]}"
            return 1  # False
        fi
    done

    return 0  # True
}


unittest() {
    : '
    Function to run unit tests for functions that start with "test_" and report 
    the results.
    Usage: unittest [-v|--verbose]
    Arguments:
        -v, --verbose: Print the summary even if all tests pass.
    Output:
        - Prints the names of the test functions that failed.
        - Prints a summary of the number of tests passed and failed.
    Example:
        unittest
        This function will find all functions in the script that start with 
        "test_", execute them, and then print a summary of how many tests 
        passed and failed.
    Notes:
        - Each test function should return 0 (true) if the test passes, and 1 
        (false) if the test fails.
        - The script must contain functions prefixed with "test_" for the 
        unittest function to find and run.
        - The summary will include the total number of tests passed and failed.
    '
    
    local verbose=0

    # Parse the optional argument
    if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
        verbose=1
    fi

    local passed=0
    local failed=0

    # Get a list of all functions starting with "test_"
    local test_functions=$(declare -F | awk '{print $3}' | grep '^test_')

    # Run each test function and capture the results
    for test_func in $test_functions; do
        $test_func
        if [ $? -eq 0 ]; then
            (( passed++ ))
        else
            echo "'$test_func' failed!"
            # TODO: echo "[ error code: $? ]"
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
