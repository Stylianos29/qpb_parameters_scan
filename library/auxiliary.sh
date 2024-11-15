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


# Not unit-tested yetf
################################################################################

range_of_gauge_configurations_file_paths_generator() {
:   '
    Function: range_of_gauge_configurations_file_paths_generator

    Description:
    Generates an array of file paths from a directory based on the order of 
    appearance in the directory, using a specified range of indices.
    
    Usage: range_of_gauge_configurations_file_paths_generator <start> <end> <step>
    Arguments:
    * start: The starting index (1-based) of the range.
    * end: The ending index (1-based) of the range.
    * step: The step value between indices (positive or negative).
    Output:
    An array of file paths corresponding to the specified range of indices.
    Notes:
    - The function assumes that files in the directory are sorted in the 
        desired order of appearance.
    - The function checks for valid input arguments and ensures they are within 
        the bounds of the number of files in the directory.
    - If no files or multiple files are found at a specific index, an error 
        message is printed and the function returns 1.
    - The directory is specified by the global variable 
        "GAUGE_LINKS_CONFIGURATIONS_DIRECTORY".
    '

    local start="$1"
    local end="$2"
    local step="$3"

    # Check if step is zero
    if [ "$step" -eq 0 ]; then
        echo "Step cannot be zero."
        return 1
    fi

    # Use the global directory variable
    local directory="$GAUGE_LINKS_CONFIGURATIONS_DIRECTORY"

    # Get the list of files in the directory
    local files=("$directory"/*)
    local num_files=${#files[@]}

    # Check if start and end are within the bounds of the number of files
    if [ "$start" -lt 1 ] || [ "$start" -gt "$num_files" ] || [ "$end" -lt 1 ]\
     || [ "$end" -gt "$num_files" ]; then
        echo "Start and end indices must be within the range of the number of"\
        "files in the directory."
        return 1
    fi

    local range=()
    local index

    # Generate the range of file paths
    if [ "$step" -gt 0 ]; then
        for ((index = start - 1; index < end; index += step)); do
            range+=($(extract_configuration_label_from_file "${files[index]}"))
            # range+=("${files[index]}")
        done
    else
        for ((index = start - 1; index >= end - 1; index += step)); do
            range+=($(extract_configuration_label_from_file "${files[index]}"))
            # range+=("${files[index]}")
        done
    fi

    # Print the range of file paths
    echo "${range[@]}"
}


constant_parameters_update() {
:   '
    Function: constant_parameters_update
    Description: Updates constants with new values based on input data. The 
    array of updated constants is passed by name.

    Parameters:
    - list_of_updated_constant_values_name (string): The name of the array
      containing key-value pairs in the format "KEY=VALUE". These pairs
      represent constants and their updated values.

    Returns: None

    This function reads a list of updated constants from the array passed by
    name. Each item in the array is expected to be a string in the format
    "KEY=VALUE", where KEY is the name of the constant to be updated and VALUE
    is its new value. The function splits each item into KEY and VALUE using
    the '=' delimiter and updates the corresponding constant using indirect
    reference with `eval`.

    It also ensures that only one of the variables 'BARE_MASS' and 
    'KAPPA_VALUE' is updated at a time. If both are passed for update, the 
    function returns an error message and stops execution.

    Usage Example:
    # Define an array of constants to update
    LIST_OF_UPDATED_CONSTANT_VALUES=( 
        "NUMBER_OF_CHEBYSHEV_TERMS=3"
        "RHO_VALUE=0.3"
        "BARE_MASS=1.2"
    )
    # Call the function to update constants
    constant_parameters_update LIST_OF_UPDATED_CONSTANT_VALUES

    Notes:
    - This function also handles special updates for
    "GAUGE_LINKS_CONFIGURATION_LABEL" by calling an external function to match
    the configuration label to the file.
    - Indirect referencing is used with `eval` to dynamically update constants.
    - Simultaneous updating of "BARE_MASS" and "KAPPA_VALUE" is not allowed.
      If both are present in the updates, the function prints an error and 
      exits early.
    '

    local list_of_updated_constant_values_name="$1" # Name of the array
    # Array reference
    local -n list_of_updated_constant_values="$list_of_updated_constant_values_name"

    # Temporary variable to store the updated file path
    local updated_file_path

    # Track if either BARE_MASS or KAPPA_VALUE has been updated
    local bare_mass_updated=false
    local kappa_value_updated=false

    # Loop through updated constants
    for item in "${list_of_updated_constant_values[@]}"; do
        # Split the key-value pair
        IFS='=' read -r key value <<< "$item"
        
        eval "$key='$value'"

        # Check if the key is GAUGE_LINKS_CONFIGURATION_LABEL
        if [[ "$key" == "GAUGE_LINKS_CONFIGURATION_LABEL" ]]; then
            # Attempt to update GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH
            updated_file_path=$(match_configuration_label_to_file "$value")
            if [ $? -ne 0 ]; then
                warning_message="Invalid configuration label '$value' ignored."
                log "WARNING" "$warning_message"
                continue  # Skip updating this key if there was an error
            fi
            eval "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH='$updated_file_path'"
        fi

        # Check for BARE_MASS and KAPPA_VALUE updates
        if [[ "$key" == "BARE_MASS" ]]; then
            if [ "$kappa_value_updated" = true ]; then
                error_message="Cannot update both 'BARE_MASS' and "
                error_message+="'KAPPA_VALUE' at the same time."
                termination_output "${error_message}" \
                                "${script_termination_message}"
                return 1
            fi
            bare_mass_updated=true
            KAPPA_VALUE=$(calculate_kappa_value "$value")
        elif [[ "$key" == "KAPPA_VALUE" ]]; then
            if [ "$bare_mass_updated" = true ]; then
                error_message="Cannot update both 'BARE_MASS' and "
                error_message+="'KAPPA_VALUE' at the same time."
                termination_output "${error_message}" \
                                                "${script_termination_message}"
                return 1
            fi
            kappa_value_updated=true
            BARE_MASS=$(calculate_bare_mass_from_kappa_value "$value")
        fi

    done

    return 0
}


parameter_range_of_values_generator() {
    :   '
    Description:
    Generates a range of parameter values using the specified helper function.
    Assumes the validity of the range string format "[start end step]".

    Parameters:
    1. helper_function: The name of the function that generates the parameter 
    range.
    2. range_variable_name: The name of the variable that holds the range string
    in the format "[start end step]".

    Output:
    Prints the generated range of values as output from the helper function.

    Example:
    parameter_range_of_values_generator parameter_range_generator "INNER_LOOP_VARYING_PARAMETER_SET_OF_VALUES"
    '

    local helper_function="$1"
    local range_variable_name="$2"

    # Create a name reference to the range variable
    declare -n range_string="$range_variable_name"

    # Remove square brackets from range_string and extract start, end, and step
    range_string="${range_string//[\[\]]/}"
    
    # Extract start, end, and step from the range_string
    IFS=' ' read -r start end step <<< "${range_string}"

    # Call the helper function with start, end, and step arguments
    output_array=($("$helper_function" "$start" "$end" "$step"))

    # Print each value in the output_array
    echo "${output_array[@]}"
}


general_range_of_values_generator() {
:   '
    Function to construct a range of values (integer or float) given a start, 
    end, and step.
    Usage: general_range_of_values_generator $start $end $step
    Arguments:
        * start: The starting value of the range (integer or float).
        * end: The ending value of the range (integer or float).
        * step: The increment (positive or negative) between consecutive values 
        in the range (integer or float).
    Output:
        A space-separated string of values representing the range from start 
        to end, inclusive, incremented by step. If step is zero, the function 
        prints an error message and returns 1.
    Example:
        range=$(general_range_of_values_generator 1 10 2)
        This sets range to "1 3 5 7 9".
    Notes:
        - The function handles both positive and negative steps.
        - If start is less than or equal to end, the function generates an 
        increasing sequence.
        - If start is greater than or equal to end, the function generates a 
        decreasing sequence.
        - The function supports both integer and floating-point values, 
        including those in exponential form.
    '

    # Helper function
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

    local start="$1"
    local end="$2"
    local step="$3"

    local range=()
    local is_exponential=FALSE

    # Check if any of the arguments are in exponential form
    if [[ "$start" == *[eE]* || "$end" == *[eE]* || "$step" == *[eE]* ]]; then
        is_exponential=TRUE

        # Convert exponential form to decimal format
        start=$(awk -v num="$start" 'BEGIN { printf "%.25f", num }')
        end=$(awk -v num="$end" 'BEGIN { printf "%.25f", num }')
        step=$(awk -v num="$step" 'BEGIN { printf "%.25f", num }')
    fi

    # Determine precision
    local precision
    if [ "$is_exponential" == FALSE ]; then
        # If not exponential, calculate precision based on step
        precision=$(echo "$step" | awk -F. '{ if (NF==1) print 0; else print length($2) }')
    else
        # For exponential form, use precision based on the smallest of start, end, and step
        # smallest_value=$(awk 'BEGIN { print ('"$start"' < '"end"' ? ('"$start"' < '"step"' ? '"start"' : '"step"') : ('"$end"' < '"step"' ? '"end"' : '"step"')) }')
        # precision=$(echo "$smallest_value" | awk -F. '{ if (NF==1) print 0; else print length($2) }')

        # For exponential form, use precision based on the smaller of start and end
        smallest_value=$(awk 'BEGIN { print ('"$start"' < '"end"' ? '"start"' : '"end"') }')
        precision=$(echo "$smallest_value" | awk -F. '{ if (NF==1) print 0; else print length($2) }')

    fi


    # Use awk to generate the range of values
    if [ "$is_exponential" == FALSE ]; then
        range=$(awk -v start="$start" -v \
                            end="$end" -v step="$step" -v precision="$precision" '
        BEGIN {
            format = "%." precision "f"
            for (i = start; (step > 0 ? i <= end : i >= end); i += step) {
                printf format " ", i
            }
        }')

    else
    # for (i = start; (step > 1 ? i <= end : i >= end); i *= step) {
        range=$(awk -v start="$start" -v \
                            end="$end" -v step="$step" -v precision="$precision" '
        BEGIN {
            format = "%." precision "f"
            for (i = start; (start < end ? i <= end : i >= end); i *= step) {
                printf format " ", i
            }
        }')
    fi

    # Convert to exponential form if originally in exponential form
    if [ "$is_exponential" == TRUE ]; then
        range=$(echo "$range" | awk -v precision="$precision" '{
            for (i = 1; i <= NF; i++) {
                printf "%." precision "e ", $i
            }
        }')
    fi

    echo $(trim_whitespace "$range")
}


parameter_range_of_values_generator() {
    :   '
    Description:
    Generates a range of parameter values using the specified helper function.
    Assumes the validity of the range string format "[start end step]".

    Parameters:
    1. helper_function: The name of the function that generates the parameter 
    range.
    2. range_variable_name: The name of the variable that holds the range string
    in the format "[start end step]".

    Output:
    Prints the generated range of values as output from the helper function.

    Example:
    parameter_range_of_values_generator parameter_range_generator "INNER_LOOP_VARYING_PARAMETER_SET_OF_VALUES"
    '

    local helper_function="$1"
    local range_variable_name="$2"

    # Create a name reference to the range variable
    declare -n range_string="$range_variable_name"

    # Remove square brackets from range_string and extract start, end, and step
    range_string="${range_string//[\[\]]/}"
    
    # Extract start, end, and step from the range_string
    IFS=' ' read -r start end step <<< "${range_string}"

    # Call the helper function with start, end, and step arguments
    output_array=($("$helper_function" "$start" "$end" "$step"))

    # Print each value in the output_array
    echo "${output_array[@]}"
}


exponential_range_of_values_generator() {
    : '
    Function: exponential_range_of_values_generator

    Description:
      Generates a range of values in exponential form, based on integer exponents.
      Expects inputs in the form "1e{exponent}", with all exponents being integers.
      If the inputs deviate from this form, the function returns 1.

    Arguments:
      - start: Starting value in the form "1e{start_exponent}"
      - end: Ending value in the form "1e{end_exponent}"
      - step: Step value in the form "1e{step_exponent}"

    Output:
      A space-separated list of values in exponential notation (e.g., "1e-2 1e-4 1e-6"),
      representing the range from start to end, inclusive.

    Example:
      exponential_range_of_values_generator "1e1" "1e3" "1e1"
      Output: "1e+01 1e+02 1e+03"

    Returns:
      0 on success, 1 on failure (e.g., if input format is incorrect).
    '

    # Helper function to validate and extract exponent from "1e{exponent}" form
    extract_exponent() {
        local value="$1"
        if [[ "$value" =~ ^1e(-?[0-9]+)$ ]]; then
            echo "${BASH_REMATCH[1]}"
        else
            return 1  # Invalid format
        fi
    }

    # Extract exponents or return 1 if any argument is invalid
    local start_exponent end_exponent step_exponent
    start_exponent=$(extract_exponent "$1") || return 1
    end_exponent=$(extract_exponent "$2") || return 1
    step_exponent=$(extract_exponent "$3") || return 1

    # Generate range of values based on direction
    local range=()
    if (( start_exponent <= end_exponent )); then
        for (( exp=start_exponent; exp<=end_exponent; exp+=step_exponent )); do
            range+=("1e$exp")
        done
    else
        for (( exp=start_exponent; exp>=end_exponent; exp+=step_exponent )); do
            range+=("1e$exp")
        done
    fi

    # Output the range as a space-separated string
    echo "${range[@]}"
    return 0
}


# TO BE RETIRED
################################################################################

# TODO: What about a general integer numbers range function?
construct_number_of_Chebyshev_terms_range() {
:   '
    Function to construct a range of integer values given a start, end, and step
    Usage: construct_range $start $end $step
    Arguments:
        * start: The starting integer of the range.
        * end: The ending integer of the range.
        * step: The increment (positive or negative) between consecutive 
        integers in the range.
    Output:
        A space-separated string of integers representing the range from start 
        to end, inclusive, incremented by step. If step is zero, the function 
        prints an error message and returns 1.
    Example:
        range=$(construct_range 1 10 2)
        This sets range to "1 3 5 7 9".
    Notes:
        - The function handles both positive and negative steps.
        - If start is less than or equal to end, the function generates an 
        increasing sequence.
        - If start is greater than or equal to end, the function generates a 
        decreasing sequence.
    '
 
    local start="$1"
    local end="$2"
    local step="$3"
    local range=()

    if [ "$step" -eq 0 ]; then
        echo "Step cannot be zero."
        return 1
    fi

    if [ "$step" -gt 0 ]; then
        for ((i = start; i <= end; i += step)); do
            range+=("$i")
        done
    else
        for ((i = start; i >= end; i += step)); do
            range+=("$i")
        done
    fi

    echo "${range[@]}"
}


check_lattice_dimensions() {
:   '
    Function: check_lattice_dimensions
    This function checks if the given lattice dimensions match any value 
    in the predefined list of lattice dimensions.

    Parameters:
    - lattice_dimensions (string): The lattice dimensions to be checked, 
    passed as a single string.

    Global Variables:
    - LATTICE_DIMENSIONS_LIST: An array containing predefined lattice dimensions
       as strings.

    Usage:
    - Call this function with the lattice dimensions to check. Example:
      check_lattice_dimensions "24 12 12 12"

    Returns:
    - 0 if the lattice dimensions match any value in LATTICE_DIMENSIONS_LIST.
    - 1 if the lattice dimensions do not match any value in 
      LATTICE_DIMENSIONS_LIST.

    Output:
    - Echoes 0 if the lattice dimensions are found in the list.
    - Echoes 1 if the lattice dimensions are not found in the list.

    Example:
    LATTICE_DIMENSIONS_LIST=("24 12 12 12" "32 16 16 16" "40 20 20 20" 
    "48 24 24 24")
    check_lattice_dimensions "24 12 12 12"
    # Output: 0
    check_lattice_dimensions "30 15 15 15"
    # Output: 1

    Notes:
    - The function uses a for loop to iterate through the 
      LATTICE_DIMENSIONS_LIST and compares each element with the input 
      lattice dimensions.
    - If a match is found, it echoes 0 and returns 0.
    - If no match is found, it echoes 1 and returns 1.
    '
    local lattice_dimensions="$@"

    for listed_lattice_dimensions in "${LATTICE_DIMENSIONS_LIST[@]}"; do
        if [[ "$listed_lattice_dimensions" == "$lattice_dimensions" ]]; then
            echo 0
            return 0
        fi
    done

    echo 1
    return 1
}


# TODO: The output of this function is not that useful
lattice_dimensions_range_of_strings_generator() {
:   '
    Function: lattice_dimensions_range_of_strings_generator

    Description:
    This function generates a range of lattice dimension strings from the 
    LATTICE_DIMENSIONS_LIST array based on the specified start, end, and step 
    indices.

    Parameters:
    1. start: The starting index (0-based) of the range.
    2. end: The ending index (0-based) of the range.
    3. step: The step (increment) between consecutive indices.

    Output:
    An array of lattice dimension strings corresponding to the specified range 
    of indices, echoed as a space-separated string.

    Example Usage:
    range=$(lattice_dimensions_range_of_strings_generator 1 5 2)
    This sets range to "32 16 16 16 24 16 16 16 30 24 24 24".

    Notes:
    - The function checks if the step is zero and prints an error message if so.
    - The function ensures that the indices are within the valid range of 
      LATTICE_DIMENSIONS_LIST array.
    '

    local start="$1"
    local end="$2"
    local step="$3"
    local range=()

    # Check if step is zero
    if [ "$step" -eq 0 ]; then
        echo "Step cannot be zero."
        return 1
    fi

    # Validate indices
    local list_length="${#LATTICE_DIMENSIONS_LIST[@]}"
    if [ "$start" -lt 0 ] || [ "$end" -lt 0 ] || [ "$start" -ge "$list_length" ] || [ "$end" -ge "$list_length" ]; then
        echo "Indices are out of range."
        return 1
    fi

    # Generate the range of lattice dimension strings
    for ((i = start; (step > 0 ? i <= end : i >= end); i += step)); do
        range+=("${LATTICE_DIMENSIONS_LIST[$i]}")
    done

    # Echo the range as a space-separated string
    echo "${range[@]}"
}


parameter_range_of_values_generator_old() {
:   '
    Description:
    Generates a range of parameter values using the specified helper function.
    Assumes the validity of the range string format "[start end step]".

    Parameters:
    1. helper_function: The name of the function that generates the parameter 
    range.
    2. range_string: String specifying the range in the format 
    "[start end step]".

    Output:
    Prints the generated range of values as output from the helper function.

    Example:
    parameter_range_of_values_generator parameter_range_generator "[1 10 2]"
    '

    local helper_function="$1"
    local range_string="$2"

    # Remove square brackets from range_string and extract start, end, and step
    range_string="${range_string//[\[\]]/}"
    # Extract start, end, and step from the range_string
    IFS=' ' read -r start end step <<< "${range_string}"

    # Call the helper function with start, end, and step arguments
    output_array=($("$helper_function" "$start" "$end" "$step"))

    # Print each value in the output_array
    # printf '%s\n' "${output_array[@]}"
    echo "${output_array[@]}"
}