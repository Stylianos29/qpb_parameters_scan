#!/bin/bash -l


################################################################################
# auxiliary.sh
#
# Description:
# This script is part of the "multiple_runs" project and contains a collection 
# of custom BASH functions that are not unit-tested due to their complexity 
# within the BASH context. These functions are primarily used to handle logging, 
# error handling, and file/directory validation in the project.
#
# Purpose:
# - This script serves as a library of auxiliary functions used by various 
#   scripts in the "multiple_runs" project.
# - These functions have been separated into this file for organizational 
#   clarity, ensuring that utility functions are grouped together and easy 
#   to locate when needed.
# - Unlike other library scripts in the project, the functions in this script 
#   are not unit-tested due to the challenging nature of testing such functions 
#   in a BASH environment.
#
# Usage:
# - Source this script in other BASH scripts within the "multiple_runs" project 
#   to access the defined custom functions.
# - Example: source /path/to/library/auxiliary.sh
#
# Note:
# - For unit-tested functions, refer to other library scripts in the "library" 
#   directory.
################################################################################


# MULTIPLE SOURCING GUARD

# Prevent multiple sourcing of this script by exiting if AUXILIARY_SH_INCLUDED
# is already set. Otherwise, set AUXILIARY_SH_INCLUDED to mark it as sourced.
[[ -n "${AUXILIARY_SH_INCLUDED}" ]] && return
AUXILIARY_SH_INCLUDED=1

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

exclude_elements_from_array()
{
:   '
    Function: exclude_elements_from_array
    Description: Returns a new array with elements excluded based on the 
    provided indices array. The original main array remains unmodified.

    Parameters:
    - main_array_name (string): The name of the array from which elements will 
      be excluded. This array is passed by name.
    - indices_array_name (string): The name of the array containing the indices 
      of elements to be excluded. This array is passed by name, and each index 
      must be a non-negative integer corresponding to a valid index in the 
      main array.

    Returns:
    - A new array with the specified elements removed.

    Usage Example:
    MAIN_ARRAY=("apple" "banana" "cherry" "date")
    INDICES_TO_REMOVE=(1 3)
    reduced_array=$(exclude_elements_from_array MAIN_ARRAY INDICES_TO_REMOVE)
    echo "${reduced_array[@]}"  # Output: "apple cherry"

    Notes:
    - The function does not modify the original main array. Instead, it returns 
      a new array with the specified elements excluded.
    - Indices must be valid non-negative integers, and they must refer to valid 
      positions in the main array.
    - The function sorts indices in descending order to avoid shifting issues 
      during removal.
    '

    local main_array_name="$1"         # Name of the main array
    local indices_array_name="$2"      # Name of the indices array
    local -n main_array="$main_array_name"   # Reference to the main array
    local -n indices_array="$indices_array_name" # Reference to the indices array
    local result_array=()              # New array to store the reduced elements

    # Sort the indices array in descending order to avoid shifting issues
    mapfile -t indices_array < <(for i in "${indices_array[@]}"; do echo "$i"; done | sort -rn)

    # Create a copy of the main array
    result_array=("${main_array[@]}")

    # Remove elements at the specified indices
    for index in "${indices_array[@]}"; do
        if (( index >= 0 && index < ${#main_array[@]} )); then
            unset "result_array[$index]"
        else
            echo "Error: Index '$index' is out of range for array '$main_array_name'."
            return 1
        fi
    done

    # Compact the array to remove gaps created by 'unset'
    result_array=("${result_array[@]}")

    # Print the resulting array with excluded elements
    echo "${result_array[@]}"
    
    return 0
}


exclude_elements_from_modifiable_parameters_list_by_index()
{
:   '
    Function to construct a subarray by excluding specified indices from the
     global array MODIFIABLE_PARAMETERS_LIST.
    This function takes a space-separated list of indices as its argument. It 
    iterates over the global array MODIFIABLE_PARAMETERS_LIST and constructs a
     new subarray that excludes the elements at the specified indices.
    Parameters:
      $1 - A space-separated list of indices to exclude.
    Returns:
      The subarray with the specified elements removed, printed as a 
      space-separated string.
    Usage - Example:
      indices_to_exclude="1 3"
      exclude_indices_from_modifiable_parameters_list "${indices_to_exclude[@]}"
    Notes:
      - This function assumes that the global array MODIFIABLE_PARAMETERS_LIST 
      is already defined.
      - The indices in the list to exclude should be valid indices of the global
       array MODIFIABLE_PARAMETERS_LIST.
      - The function uses string comparison to ensure accurate matching of 
      indices.
    '

    local indices_to_be_excluded_list=("$@")
    local modifiable_parameters_sublist=()

    for index in "${!MODIFIABLE_PARAMETERS_LIST[@]}"; do
        # Spaces are necessary around $i in " $i " ensure that the index is 
        # matched exactly, preventing partial matches with other indices.
        if [[ ! " ${indices_to_be_excluded_list[@]} " =~ " ${index} " ]]; then
            modifiable_parameters_sublist+=(\
                                        "${MODIFIABLE_PARAMETERS_LIST[$index]}")
        fi
    done

    echo "${modifiable_parameters_sublist[@]}"
}


compare_no_common_elements()
{
    local -n array1="$1"    # First array (non-negative integers)
    local -n array2="$2"    # Second array (non-negative integers)

    local -A elements_seen  # Associative array to track elements
    local common_elements=() # Array to store common elements

    # Mark all elements in array1
    for elem in "${array1[@]}"; do
        elements_seen[$elem]=1
    done

    # Check for common elements in array2
    for elem in "${array2[@]}"; do
        if [[ -n "${elements_seen[$elem]}" ]]; then
            common_elements+=("$elem")  # Add common element to list
        fi
    done

    # If common elements were found, print an error
    if [ ${#common_elements[@]} -gt 0 ]; then
        error_message="No varying parameters values can be printed as constant."
        termination_output "${error_message}" "${SCRIPT_TERMINATION_MESSAGE}"
        return 1
    fi

    return 0
}


modify_decimal_format() {
    local input_string="$1"
    local modified_string="${input_string//./p}"
    echo "$modified_string"
}


modify_decimal_format_old() {
:   '
    Function to check if a value contains a decimal number and modify its format.
    Parameters:
        $1 - The string to be checked and modified
    Returns:
        Modified string with the decimal point in the number replaced by "p" 
        if a decimal number is found in the string.
    Usage:
        parameter_value=$(modify_decimal_format "$parameter_value")
    Explanation:
        - This function searches for a decimal number in the input string.
        - If found, it replaces the decimal point in the number with "p".
        - If no decimal number is found, the function returns the original string.
    '

    local value="$1"

    # Use regex to match a decimal number in the string and replace only the decimal point
    echo "$value" | sed -E 's/([0-9]+)\.([0-9]+)/\1p\2/'
}


modify_decimal_format_old_old()
{
:   '
    Function to check if a value is a decimal number and modify its format.
    Parameters:
        $1 - The value to be checked and modified
    Returns:
        Modified value with the decimal point replaced by "p" if it is a decimal
         number, otherwise returns the original value.
    Usage:
        parameter_value=$(modify_decimal_format "$parameter_value")
    Explanation:
        - This function takes one argument and checks if it is a decimal number.
        - A decimal number is defined as an optional minus sign, followed by 
          one or more digits, followed optionally by a decimal point and one 
          or more digits.
        - If the value matches the pattern, the function replaces the decimal 
          point with the letter "p".
        - If the value does not match the pattern, the function returns the 
          original value unchanged.
    '

    local value="$1"

    if [[ $value =~ ^-?[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?$ ]]; then
        echo "${value//./p}"
    else
        echo "$value"
    fi
}


trim_whitespace()
{
:   '
    Function: trim_whitespace

    Description:
    Trims leading and trailing whitespace from a given string. This function 
    is useful for cleaning up strings that may have extra spaces at the 
    beginning or end, which can interfere with string comparisons and other 
    operations.

    Parameters:
    1. var: The input string that needs to be trimmed of leading and trailing 
    whitespace.

    Output:
    Prints the trimmed string without leading or trailing whitespace.

    Usage:
    trimmed_string=$(trim_whitespace "  example string  ")

    Example:
    input_string="   some text with spaces   "
    trimmed_string=$(trim_whitespace "$input_string")
    # trimmed_string now contains "some text with spaces"

    Notes:
    - This function uses Bash string manipulation techniques to remove 
    whitespace.
    - The function does not modify the original string but outputs the trimmed 
    result.
    '

    local var="$*"
    
    # Remove leading and trailing whitespace
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    
    echo -n "$var"
}


find_index()
{
:   '
    Function: find_index
    This function searches for an element in a given array and returns the 
    index of the first occurrence of that element.

    Parameters:
    - element (string): The element to search for in the array.
    - array (array): The array in which to search for the element. The array 
      should be passed as individual arguments.

    Returns:
    - If the element is found, the function prints the index of the first 
      occurrence of the element and returns 0.
    - If the element is not found, the function prints -1 and returns 1.

    Usage:
    find_index element "${array[@]}"

    Example:
    my_array=("apple" "banana" "cherry" "date")
    element_to_find="cherry"
    index=$(find_index "$element_to_find" "${my_array[@]}")

    if [[ $index -ne -1 ]]; then
        echo "Element '$element_to_find' found at index $index."
    else
        echo "Element '$element_to_find' not found in the array."
    fi

    Notes:
    - This function uses a loop to iterate through the array and compare each 
      element with the target element.
    - The function prints the index of the first match found and returns 0.
    - If no match is found, the function prints -1 and returns 1.
    '
    
    local element="$1"
    shift
    local array=("$@")

    for i in "${!array[@]}"; do
        if [[ "${array[$i]}" == "$element" ]]; then
            echo "$i"
            return 0
        fi
    done

    echo "-1"  # Return -1 if the element is not found
    return 1
}
