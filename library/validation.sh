#!/bin/bash


# TODO: Write description
######################################################################
# library/validation.sh - Script for 
#
#
######################################################################


# MULTIPLE SOURCING GUARD

# Prevent multiple sourcing of this script by exiting if VALIDATION_SH_INCLUDED
# is already set. Otherwise, set VALIDATION_SH_INCLUDED to mark it as sourced.
[[ -n "${VALIDATION_SH_INCLUDED}" ]] && return
VALIDATION_SH_INCLUDED=1

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

check_if_directory_exists()
{
:   '
    Description: Checks if a directory exists at the specified path. If the 
    directory does not exist, it prints a user-defined error message, 
    optionally appending a termination message, and exits the script with a 
    status code of 1.

    Parameters:
    - directory_path (string): The full path to the directory to check.
    - error_message (string): The error message to print if the directory 
      does not exist.
    - script_termination_message (string, optional): A message to be appended 
      to the log file upon termination. If not provided, a global variable 
      SCRIPT_TERMINATION_MESSAGE will be used if set, or a default message 
      will be assigned.

    Returns: None
    Exits: Exits the script with status 1 if the directory does not exist, after 
    logging the error.

    This function ensures that required directories are present before 
    proceeding with further script execution. It enhances error handling by 
    allowing for a customizable termination message.

    Usage Example:
        # Define the directory path and error message
        destination_directory="/path/to/destination_directory"
        error_message="Invalid destination directory path. Check again."
        
        # Call the function to check if the directory exists
        check_if_directory_exists "$destination_directory" "$error_message"
    '

    local directory_path="$1"
    local error_message="$2"
    local script_termination_message="$3"
    set_script_termination_message script_termination_message

    # Set a default error message if none is provided
    if [ -z "$error_message" ]; then
      error_message="Directory '$directory_path' does not exist. "
      error_message+="Please check again."
    fi

    # Check if the path is a directory
    if [ ! -d "$directory_path" ]; then
        termination_output "${error_message}" "${script_termination_message}"
        return 1
    fi

    return 0
}


check_if_file_exists()
{
:   '
    Description: Checks if a file exists at the specified path. If the file 
    does not exist, it prints a user-defined error message, optionally 
    appending a termination message, and exits the script with a status code 
    of 1.

    Parameters:
    - file_path (string): The full path to the file to check.
    - error_message (string): The error message to print if the file does 
      not exist.
    - script_termination_message (string, optional): A message to be appended 
      to the log file upon termination. If not provided, a global variable 
      SCRIPT_TERMINATION_MESSAGE will be used if set, or a default message 
      will be assigned.

    Returns: None
    Exits: Exits the script with status 1 if the file does not exist, after 
    logging the error.

    This function ensures that required files are present before proceeding 
    with further script execution. It enhances error handling by allowing for 
    a customizable termination message.

    Usage Example:
        # Define the file path and error message
        empty_parameters_file="/path/to/empty_parameters_file"
        error_message="Invalid empty parameters file path. Check again."
        
        # Call the function to check if the file exists
        check_if_file_exists "$empty_parameters_file" "$error_message"
    '

    local file_path="$1"
    local error_message="$2"
    local script_termination_message="$3"
    set_script_termination_message script_termination_message

    # Set a default error message if none is provided
    if [ -z "$error_message" ]; then
      error_message="Path '$file_path' to file is invalid or "
      error_message+="file does not exist. Please check again."
    fi

    # Check if the file exists
    if [ ! -f "$file_path" ]; then
        termination_output "${error_message}" "${script_termination_message}"
        return 1
    fi

    return 0
}


copy_file_and_check()
{
    local source_file="$1"
    local destination_file="$2"

    cp "$source_file" "$destination_file"
    if [ $? -ne 0 ]; then
        # If copy fails, output error and terminate script
        local error_message="Copying '$(basename "$source_file")' file failed."
        termination_output "$error_message"
        return 1  # Return 1 for failure
    fi

    return 0  # Return 0 for success
}


validate_indices_array()
{
:   '
    Function: validate_indices_array
    Description: Validates that each element in an indices array is a
    non-negative integer, is unique, and falls within the valid range of indices
    for the given parameters array. Error messages refer to the name of the
    indices array being validated.

    Parameters:
    - indices_array_name (string): The name of the array containing the indices
    to validate. This array is passed by name and validated against the
    parameters array.
    - parameters_array_name (string): The name of the array representing the
    valid parameters. The indices in the indices_array must refer to valid
    indices within this array.

    Returns:
    - Returns 0 if all indices are valid.
    - Returns 1 and prints an error message if an invalid index is found.

    Usage Example:
        indices=(0 1 2)
        parameters=("param1" "param2" "param3")
        validate_indices_array indices parameters
        if [ $? -eq 0 ]; then
            echo "Indices are valid."
        else
            echo "Invalid indices found."
        fi

    Notes:
    - The function checks if each index in the indices_array is a valid integer, 
      checks for duplicates, and ensures that each index falls within the valid 
      range for the parameters_array.
    '

    local indices_array_name="$1"      # Name of the indices array
    local parameters_array_name="$2"   # Name of the parameters array
    
    # Array of indices passed by name
    local -n indices_array="$indices_array_name"
    # Parameters array passed by name
    local -n parameters_array="$parameters_array_name"

    local -A seen                 # Associative array to check for duplicates
    local max_index=$(( ${#parameters_array[@]} - 1 ))  # Maximum valid index

    # Check each element of indices_array
    for index in "${indices_array[@]}"; do
        
        # 1. Check if the index is an integer
        if ! [[ "$index" =~ ^[0-9]+$ ]]; then
            error_message="Invalid value '$index' found in "
            error_message+="'$indices_array_name' indices array. "
            error_message+="All elements must be integers."
            termination_output "${error_message}" \
                                                "${SCRIPT_TERMINATION_MESSAGE}"
            return 1
        fi

        # 2. Check for duplicates
        if [[ -n "${seen[$index]}" ]]; then
            error_message="Duplicate index '$index' found in array "
            error_message+="'$indices_array_name'."
            termination_output "${error_message}" \
                                                "${SCRIPT_TERMINATION_MESSAGE}"
            return 1
        fi
        seen[$index]=1  # Mark the index as seen

        # 3. Check if the index is within the valid range
        if (( index < 0 || index > max_index )); then
            error_message="Invalid value '$index' found in "
            error_message+="'$indices_array_name' indices array. "
            error_message+="All elements must be between 0 and $max_index."
            termination_output "${error_message}" \
                                                "${SCRIPT_TERMINATION_MESSAGE}"
            return 1
        fi
    done

    return 0
}


# TODO: It needs to be retired
is_range_string_old()
{
:   '
    Function: is_range_string
    
    Description:
      Checks if a string is formatted as a range string enclosed in square 
      brackets. A range string consists of three numerical values (integers or 
      floats) separated by spaces, enclosed in square brackets.
    
    Parameters:
      var_value: The string value to be checked.
    
    Returns:
      Returns 0 if the input string matches the range string format, otherwise 
      returns 1.
    
    Example:
      is_range_string "[1.0 2 3.5]"   # Returns 0 (true)
      is_range_string "[10 20 30]"    # Returns 0 (true)
      is_range_string "1.0 2 3.5"     # Returns 1 (false)
      is_range_string "[1 2 3 4]"     # Returns 1 (false)
    
    Regex Explanation:
        ^\[ :
        - Asserts the start of the string followed by an opening square bracket 
        '['.
        [0-9]+(\.[0-9]+)? :
        - Matches one or more digits optionally followed by a decimal point and 
        one or more digits (for floating point numbers).
        [[:space:]] :
        - Matches any whitespace character (space).
        \] :
        - Matches a closing square bracket ']'.
        $ :
        - Asserts the end of the string.
    
    Notes:
      - The function does not handle negative numbers or leading/trailing
      whitespace within the range string.
    
    '

    local var_value="$1"

    if [[ $var_value =~ ^\[[0-9]+(\.[0-9]+)?[[:space:]][0-9]+(\.[0-9]+)?[[:space:]][0-9]+(\.[0-9]+)?\]$ ]]; then
        return 0  # True: It is a range string
    else
        return 1  # False: It is not a range string
    fi
}


# Function to validate a varying parameter values array
# Takes the name of the array as input
# TODO: Log output properly
validate_varying_parameter_values_array()
{
    local parameter_name="$1"
    local varying_parameter_values_array_name="$2"

    # Check if the input is an array
    if [[ -z "$(declare -p "$varying_parameter_values_array_name" 2>/dev/null)"\
 || "$(declare -p "$varying_parameter_values_array_name")" != "declare -a"* ]]; 
    then
        # echo "Error: $varying_parameter_values_array_name is not a valid array."
        return 1
    fi

    # Access the array by its name
local -n varying_parameter_values_array="$varying_parameter_values_array_name"

    # Check if the array is empty
    if [[ ${#varying_parameter_values_array[@]} -eq 0 ]]; then
        echo "Error: $varying_parameter_values_array_name is empty."
        return 1
    fi

    # Check for duplicates
    local unique_elements=()
    for element in "${varying_parameter_values_array[@]}"; do
        if [[ " ${unique_elements[*]} " == *" $element "* ]]; then
            echo "Error: Duplicate value '$element' found in "\
            "$varying_parameter_values_array_name."
            return 1
        else
            unique_elements+=("$element")
        fi
    done

    # Create a shorter alias for parameters validation functions dictionary
    declare -n checks_dict=MODIFIABLE_PARAMETERS_VALIDATION_FUNCTIONS_DICTIONARY

    local validating_function="${checks_dict[$parameter_name]}"
    for element in "${varying_parameter_values_array[@]}"; do
        if ! $validating_function "$element"; then
            local error_message="Invalid element '$element' passed to the "
            error_message+="'$varying_parameter_values_array_name' array."
            echo "$error_message"
            return 1
        fi
    done

    return 0
}


validate_updated_constant_parameters_array()
{
:   '
    Function: validate_updated_constant_parameters_array
    Description: Validates that the keys in the provided list of updated 
    constants are present in the list of valid iterable parameters and ensures
    that none of the keys correspond to varying parameters. All three arrays
    are passed by name.

    Parameters:
    - list_of_updated_constant_values_name (string): The name of the array 
      containing key-value pairs in the format "KEY=VALUE". These pairs
      represent constants and their updated values.
    - iterable_parameters_names_array_name (string): The name of the array
      containing the list of valid iterable parameters.
    - varying_iterable_parameters_names_array_name (string): The name of the
      array containing the list of parameters that are varying (i.e., not allowed 
      to be fixed or assigned new constant values).

    Returns:
    - 0 if all keys are valid and none correspond to varying parameters.
    - 1 if any key is invalid or corresponds to a varying parameter, along with 
      an error message specifying the invalid key.

    Usage Example:
    LIST_OF_UPDATED_CONSTANT_VALUES=( 
        "NUMBER_OF_VECTORS=5" 
        "NUMBER_OF_CHEBYSHEV_TERMS=25"
    )
    VARYING_ITERABLE_PARAMETERS_NAMES_ARRAY=(
        NUMBER_OF_VECTORS
        BARE_MASS
    )
    validate_updated_constant_parameters_array \
        LIST_OF_UPDATED_CONSTANT_VALUES \
        ITERABLE_PARAMETERS_NAMES_ARRAY \
        VARYING_ITERABLE_PARAMETERS_NAMES_ARRAY
    if [ $? -eq 0 ]; then
        echo "All parameters are valid."
    else
        echo "Invalid parameters found."
    fi

    Notes:
    - This function expects the names of three arrays as input. It checks if each 
      key in the list_of_updated_constant_values array is present in the iterable 
      parameters array.
    - It also checks if any key corresponds to a varying parameter (if so, an 
      error is raised).
    - If any key is invalid or corresponds to a varying parameter, the function 
      prints an error message and returns 1.
    '

    # Name of array of updated constant values
    local list_of_updated_constant_values_name="$1"
    # Name of iterable parameters array
    local iterable_parameters_names_array_name="$2"
    # Name of varying iterable parameters array
    local varying_iterable_parameters_names_array_name="$3"

    # updated constant values array passed by name
    local -n list_of_updated_constant_values="$list_of_updated_constant_values_name"
    # iterable parameters array passed by name
    local -n iterable_parameters_array="$iterable_parameters_names_array_name"
    # varying iterable parameters array passed by name
    local -n varying_iterable_parameters_array="$varying_iterable_parameters_names_array_name"

    local key

    # Loop through each item in the list_of_updated_constant_values array
    for item in "${list_of_updated_constant_values[@]}"; do
        # Extract the key from the key-value pair
        IFS='=' read -r key _ <<< "$item"

        # Check if the key is in the iterable_parameters_array
        if [[ ! " ${iterable_parameters_array[@]} " =~ " ${key} " ]]; then
            error_message="Invalid parameter name to be updated: '$key'."
            termination_output "${error_message}" \
                                                "${SCRIPT_TERMINATION_MESSAGE}"
            return 1
        fi

        # Check if the key is in the varying_iterable_parameters_array
        if [[ " ${varying_iterable_parameters_array[@]} " =~ " ${key} " ]]; then
            error_message="A fixed value cannot be assigned to the "
            error_message+="varying parameter: '$key'."
            termination_output "${error_message}" \
                                                "${SCRIPT_TERMINATION_MESSAGE}"
            return 1
        fi
    done

    return 0
}


validate_updated_constant_parameters_array_old()
{
:   '
    Function: validate_updated_constant_parameters_array
    Description: Validates that the keys in the provided list of updated 
    constants are present in the list of iterable parameters. Both arrays 
    are passed by name.

    Parameters:
    - list_of_updated_constant_values_name (string): The name of the array 
      containing key-value pairs in the format "KEY=VALUE". These pairs
      represent constants and their updated values.
    - iterable_parameters_names_array_name (string): The name of the array
      containing the list of valid iterable parameters.

    Returns:
    - 0 if all keys are valid.
    - 1 if any key is invalid, along with an error message specifying the
      invalid key.

    Usage Example:
    LIST_OF_UPDATED_CONSTANT_VALUES=(
        "NUMBER_OF_VECTORS=5"
        "NUMBER_OF_CHEBYSHEV_TERMS=25"
    )
    validate_updated_constant_parameters_array \
        LIST_OF_UPDATED_CONSTANT_VALUES ITERABLE_PARAMETERS_NAMES_ARRAY
    if [ $? -eq 0 ]; then
        echo "All parameters are valid."
    else
        echo "Invalid parameters found."
    fi

    Notes:
    - This function expects the names of two arrays as input. It checks if each 
      key in the list_of_updated_constant_values array is present in the
      iterable parameters array.
    - If any key is not found in the iterable parameters array, an error
      message is printed, and the function returns 1.
    '

    # Name of array of updated values
    local list_of_updated_constant_values_name="$1"
    # Name of iterable parameters array
    local iterable_parameters_names_array_name="$2"

    # updated constant values array passed by name
local -n list_of_updated_constant_values="$list_of_updated_constant_values_name"
    # iterable parameters array passed by name
    local -n iterable_parameters_array="$iterable_parameters_names_array_name"
    local key

    # Loop through each item in the list_of_updated_constant_values array
    for item in "${list_of_updated_constant_values[@]}"; do
        # Extract the key from the key-value pair
        IFS='=' read -r key _ <<< "$item"

        # Check if the key is in the iterable_parameters_array
        if [[ ! " ${iterable_parameters_array[@]} " =~ " ${key} " ]]; then
            echo "Error: Invalid parameter name to be updated: '$key'."
            return 1
        fi
    done

    return 0
}


validate_indices_array_old()
{
:   '
    Function: validate_indices_array
    This function validates each element in the input array to ensure they are
    valid indices for the globally accessible array "MODIFIABLE_PARAMETERS_LIST".

    The function performs the following checks:
    1. Ensures each element is an integer.
    2. Ensures each element is within the valid index range for 
       "MODIFIABLE_PARAMETERS_LIST".
    3. Ensures there are no duplicate indices.
    4. Ensures no index corresponds to the element "OPERATOR_TYPE" in 
       "MODIFIABLE_PARAMETERS_LIST".

    Parameters:
    - indices_array_name (string): The name of the array containing indices to
      be validated. This should be passed as a string.

    Usage:
    - Call this function with the name of an array containing indices to
      validate them against MODIFIABLE_PARAMETERS_LIST. Example:
      parameters_indices_array=(5 6 10)
      validate_indices_array "parameters_indices_array"

    Returns:
    - 0 if all indices are valid.
    - 1 if any invalid indices are found, with appropriate warning messages.
    '

    local indices_array_name="$1"
    local -n indices_array="$indices_array_name"

    local list_length="${#MODIFIABLE_PARAMETERS_LIST[@]}"

    # Associative array to track already encountered elements in the input array
    # for removing duplicates
    declare -A already_encountered_indices

    for element in "${indices_array[@]}"; do
        # Check for any non-integer elements in the input array
        if ! [[ "$element" =~ ^-?[0-9]+$ ]]; then
            error_message="Invalid value '$element' found in "\
                                    "'$indices_array_name' indices array.\n"
            error_message+="All elements must be integers."
            termination_output "${error_message}" "${script_termination_message}"
            echo "Exiting..."
            return 1
        fi
        # Check for any out-of-range integer elements in the input array
        if (( element < 0 || element >= list_length )); then
            error_message="Invalid value '$element' found in "\
                                    "'$indices_array_name' indices array.\n"
            error_message+="All elements must be between 0 and $((list_length - 1))."
            termination_output "${error_message}" "${script_termination_message}"
            echo "Exiting..."
            return 1
        fi
        # Check if any elements of the input array correspond to the index of 
        # the "OPERATOR_TYPE" element of the "MODIFIABLE_PARAMETERS_LIST" 
        # global constant array
        if [[ "${MODIFIABLE_PARAMETERS_LIST[$element]}" == "OPERATOR_TYPE" ]];
        then
            error_message="Invalid value '$element' found in "\
                                    "'$indices_array_name' indices array.\n"
            error_message+="Index corresponds to 'OPERATOR_TYPE'."
            termination_output "${error_message}" "${script_termination_message}"
            echo "Exiting..."
            return 1
        fi
        # Check for any duplicates in the input array
        if [[ -n "${already_encountered_indices[$element]}" ]]; then
            error_message="Duplicate index '$element' found in '$indices_array_name'" \
                 "indices array."
            termination_output "${error_message}" "${script_termination_message}"
            echo "Exiting..."
            return 1
        else
            already_encountered_indices[$element]=1
        fi
    done

    return 0
}


check_for_range_input()
{
    local helper_function="$1"
    local input_array="$2"

    if [[ "${input_array}" =~ ^\[(.+)\]$ ]]; then
        local range_str="${BASH_REMATCH[1]}"
        IFS=' ' read -r start end step <<< "${range_str}"
        output_array=($("$helper_function" "$start" "$end" "$step"))
        printf '%s\n' "${output_array[@]}"
        return 0
    else
        return 1
    fi
}


# TODO: This function is way too large and needs to be split
validate_varying_parameter_values_array_old()
{
:   '
    Function: validate_varying_parameter_values_array

    Description:
    This function validates and processes an array of parameter values for a 
    given index. It checks if the parameter values need to be generated as a 
    range and then validates each value against a corresponding test function.

    Parameters:
    1. index: An integer (0, 1, or 2) representing the index of the parameter 
    in the VARYING_PARAMETERS_INDICES_LIST.
    2. parameter_values_array: The name of the array containing the parameter 
    values (e.g., INNER_LOOP_VARYING_PARAMETER_RANGE_OF_VALUES, 
    OUTER_LOOP_VARYING_PARAMETER_RANGE_OF_VALUES, 
    OVERALL_OUTER_LOOP_VARYING_PARAMETER_RANGE_OF_VALUES).

    Process:
    1. Extracts the parameter name using the provided index from 
       VARYING_PARAMETERS_INDICES_LIST.
    2. Checks if the parameter values array contains a range string. If yes, it 
       generates the range of values using the corresponding generator function 
       and updates the array.
    3. Validates each element in the parameter values array using the 
       corresponding test function. If any element is invalid, it prints an 
       error message and exits.
    4. If the parameter values array does not contain a range string, it checks
       for duplicates.

    Example Usage:
    validate_varying_parameter_values_array 0 \
                        INNER_LOOP_VARYING_PARAMETER_RANGE_OF_VALUES
    validate_varying_parameter_values_array 1 \
                        OUTER_LOOP_VARYING_PARAMETER_RANGE_OF_VALUES
    validate_varying_parameter_values_array 2 \
                        OVERALL_OUTER_LOOP_VARYING_PARAMETER_RANGE_OF_VALUES

    Notes:
    - The function uses nameref (name reference) to refer to the array passed as 
      the second argument.
    - It ensures that the code is not repetitive and maintains clarity and 
      simplicity by centralizing the validation and range generation logic.

    Error Handling:
    - If the step value is zero, the function prints an error message and exits.
    - If any element in the parameter values array is invalid, the function 
      prints an error message and exits.
    - If duplicates are found in the parameter values array, the function 
      prints an error message and exits.
    '

    local index="$1"
    local -n parameter_values_array="$2"
    local -n parameters_list="$3"

    local varying_parameter_index=${VARYING_PARAMETERS_INDICES_LIST[$index]}
  local parameter_name="${parameters_list[$varying_parameter_index]}"

    # Check if a range of values was requested.
    if is_range_string "${parameter_values_array[*]}"; then
        # If indeed, then generate range and assign it back to the varying
        # parameter values array
        # TODO: I need to find a way to handle error
        local range_of_values_function=\
"${MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATORS_DICTIONARY[$parameter_name]}"

        local parameter_range_of_values_string=$(\
            parameter_range_of_values_generator "$range_of_values_function"\
                                                 "${parameter_values_array[*]}")
        read -r -d '' -a parameter_values_array \
                        < <(printf '%s\0' "$parameter_range_of_values_string")
    else
        # Check for duplicates in the parameter values array
        local duplicates_found=0
        local seen=()
        for element in "${parameter_values_array[@]}"; do
            if [[ " ${seen[*]} " == *" $element "* ]]; then
                duplicates_found=1
                break
            fi
            seen+=("$element")
        done
        
        if [ $duplicates_found -ne 0 ]; then
            echo "Error. '${parameter_values_array[*]}' array contains"\
                            "duplicate elements."
            echo "Exiting..."
            exit 1
        fi

        # TODO: Check validity of config labels in parameter_values_array
        if [ "$parameter_name" == "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH" ]; then
            for index in "${!parameter_values_array[@]}"; do
                parameter_values_array[$index]=$(match_configuration_label_to_file "${parameter_values_array[$index]}")
            done
        fi
    fi

    # Check validity of each element of the varying parameter values array
    if [ "$parameter_name" != "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH" ]; then
        local test_function="\
            ${MODIFIABLE_PARAMETERS_VALIDATION_FUNCTIONS_DICTIONARY[$parameter_name]}"
        for element in "${parameter_values_array[@]}"; do
            if [ $($test_function "$element") -ne 0 ]; then
                echo "Error. '${parameter_values_array[*]}' array contains"\
                "invalid elements with respect to the chosen varying parameter."
                echo "Exiting..."
                exit 1
            fi
        done
    fi
}


is_decimal_number()
{
:   '
    Function to check if a value is a decimal number
    Parameters:
            $1 - The value to be checked
        Returns:
            0 if the value is a decimal number, 1 otherwise
    Usage:
        value="15.69"
        if [ $(is_decimal_number "$value") -eq 0 ]; then
            echo "$value is a decimal number."
        else
            echo "$value is not a decimal number."
        fi
    Explanation:
        - This function takes one argument and checks if it is a decimal number.
        - A decimal number is defined as an optional minus sign, followed by 
        one or more digits,
            followed optionally by a decimal point and one or more digits.
        - The function uses a regular expression to match this pattern.
        - If the value matches the pattern, the function returns 0 (True).
        - If the value does not match the pattern, the function returns 1 
        (False).
    '

    local value="$1"

    if [[ $value =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
        echo 0  # True
    else
        echo 1  # False
    fi
}


validate_updated_constant_parameters_array_old()
{
:   '
    Function: validate_updated_constant_parameters_array
    Description: Validates that the keys in the provided list of updated 
    constants are present in the list of modifiable parameters. If any key 
    is not found in the list, an error is returned.

    Parameters:
    - list_of_updated_constant_values (array): An array containing key-value 
      pairs in the format "KEY=VALUE". Each key represents a constant whose 
      value is being updated, and the value is the new value to be assigned.

    Returns:
    - 0 if all keys are valid.
    - 1 if any key is invalid, along with an error message specifying the 
      invalid key.

    Usage Example:
    # Define an array of constants to update
    constants=(
        "NUMBER_OF_CHEBYSHEV_TERMS=3"
        "RHO_VALUE=0.3"
    )
    # Validate the constants
    validate_updated_constant_parameters_array "${constants[@]}"
    if [ $? -eq 0 ]; then
        echo "All parameters are valid."
    else
        echo "Invalid parameters found."
    fi

    Notes:
    - The function expects the input array to contain strings in the format 
      "KEY=VALUE". It extracts the "KEY" from each entry and checks whether it 
      is present in the predefined `MODIFIABLE_PARAMETERS_LIST` array.
    - The function excludes the special key "CONFIGURATION_LABEL" from
      validation.
    - If any key is not found in the `MODIFIABLE_PARAMETERS_LIST`, an error 
      message is printed, and the function returns 1.
    - This function is useful when validating constant parameters before
      updating them to ensure they are part of a predefined modifiable set.
    '

    local list_of_updated_constant_values=("$@")
    local key

    # Loop through each item in the list_of_updated_constant_values array
    for item in "${list_of_updated_constant_values[@]}"; do
        # Extract the key from the key-value pair
        IFS='=' read -r key _ <<< "$item"

        # Check if the key is in the MODIFIABLE_PARAMETERS_LIST array
        if [[ "$key" != "CONFIGURATION_LABEL" \
            && ! " ${MODIFIABLE_PARAMETERS_LIST[@]} " =~ " ${key} " ]]; then
            echo "Error: Invalid parameter name to be updated: '$key'."
            return 1
        fi
    done

    return 0
}


check_mpi_geometry() {
    local input="$1"

    # Use regex to check if input matches the form "even,even,even"
    if [[ "$input" =~ ^([0-9]+),([0-9]+),([0-9]+)$ ]]; then
        # Check each number to see if it's an even integer
        if (( ${BASH_REMATCH[1]} % 2 == 0 && ${BASH_REMATCH[2]} % 2 == 0 && ${BASH_REMATCH[3]} % 2 == 0 )); then
            return 0  # Valid input
        fi
    fi
  
    error_message="Invalid 'MPI_GEOMETRY' input value."
    termination_output "${error_message}" "${SCRIPT_TERMINATION_MESSAGE}"
    return 1  # Not valid input
}


check_walltime() {
    local input="$1"

    # Use regex to match "HOURS:MINUTES:SECONDS" format
    if [[ "$input" =~ ^([0-9]{1,2}):([0-9]{1,2}):([0-9]{1,2})$ ]]; then
        local hours="${BASH_REMATCH[1]}"
        local minutes="${BASH_REMATCH[2]}"
        local seconds="${BASH_REMATCH[3]}"

        # Validate the ranges for hours, minutes, and seconds
        if (( hours >= 0 && hours <= 24 && minutes >= 0 && minutes < 60 && seconds >= 0 && seconds < 60 )); then
            # Ensure the input is not "00:00:00"
            if ! [[ "$hours" == "0" && "$minutes" == "0" && "$seconds" == "0" ]]; then
                return 0  # Valid input
            fi
        fi
    fi

    error_message="Invalid 'WALLTIME' input value."
    termination_output "${error_message}" "${SCRIPT_TERMINATION_MESSAGE}"
    return 1  # Not valid input
}

############################ UNIT-TESTED FUNCTIONS #############################

is_integer() {
:   '
    is_integer() - Check if a value is an integer

    This function takes a single input value and checks if it is an integer.
    It uses a regular expression to determine if the value is an integer,
    which can be either positive or negative. If the value is an integer,
    the function returns 0 (success). Otherwise, it returns 1 (failure).

    Usage:
    if is_integer value; then
        echo "Value is an integer"
    else
        echo "Value is not an integer"
    fi

    Parameters:
    value: The value to be checked. This can be any string.

    Returns:
    0 if the value is an integer, otherwise 1.

    Example:
    is_integer 42    # returns 0 (true)
    is_integer -42   # returns 0 (true)
    is_integer 3.14  # returns 1 (false)
    is_integer abc   # returns 1 (false)
    '

    local value="$1"

    # Check if the value is an integer using a regular expression
    if [[ "$value" =~ ^-?[0-9]+$ ]]; then
        return 0  # Return 0 (success) if the value is an integer
    else
        return 1  # Return 1 (failure) if the value is not an integer
    fi
}


is_positive_integer() {
:   '
    is_positive_integer() - Check if a value is a positive integer

    This function takes a single input value and checks if it is a positive integer.
    It first calls is_integer() to ensure the value is an integer, then checks if 
    the value is positive. If both conditions are met, the function returns 0 (success).
    Otherwise, it returns 1 (failure).

    Usage:
    if is_positive_integer value; then
        echo "Value is a positive integer"
    else
        echo "Value is not a positive integer"
    fi

    Parameters:
    value: The value to be checked. This can be any string.

    Returns:
    0 if the value is a positive integer, otherwise 1.

    Example:
    is_positive_integer 42    # returns 0 (true)
    is_positive_integer 0     # returns 1 (false)
    is_positive_integer -42   # returns 1 (false)
    is_positive_integer 3.14  # returns 1 (false)
    is_positive_integer abc   # returns 1 (false)
    '

    local value="$1"

    # First, check if the value is an integer
    if is_integer "$value" && [ "$value" -gt 0 ]; then
        return 0  # Return 0 (success) if the value is a positive integer
    else
        return 1  # Return 1 (failure) if the value is not a positive integer
    fi
}


is_non_negative_integer() {
:   '
    is_non_negative_integer() - Check if a value is a non-negative integer

    This function takes a single input value and checks if it is a non-negative
    integer. It first calls is_integer() to ensure the value is an integer, then
    checks if the value is zero or positive. If both conditions are met, the
    function returns 0 (success). Otherwise, it returns 1 (failure).

    Usage:
    if is_non_negative_integer value; then
        echo "Value is a non-negative integer"
    else
        echo "Value is not a non-negative integer"
    fi

    Parameters:
    value: The value to be checked. This can be any string.

    Returns:
    0 if the value is a non-negative integer, otherwise 1.

    Example:
    is_non_negative_integer 42    # returns 0 (true)
    is_non_negative_integer 0     # returns 0 (true)
    is_non_negative_integer -42   # returns 1 (false)
    is_non_negative_integer 3.14  # returns 1 (false)
    is_non_negative_integer abc    # returns 1 (false)
    '

    local value="$1"

    # First, check if the value is an integer
    if is_integer "$value" && [ "$value" -ge 0 ]; then
        return 0  # Return 0 (success) if the value is a non-negative integer
    else
        return 1  # Return 1 (failure) if the value is not a non-negative integer
    fi
}


is_float() {
:   '
    is_float() - Check if a value is a floating-point number

    This function takes a single input value and checks if it is a
    floating-point number. It uses a regular expression to determine if the 
    value is a valid floating-point number, which can be either positive or
    negative, and may contain a decimal point. If the value is a floating-point
    number, the function returns 0. Otherwise, it returns 1.

    Usage:
    result=$(is_float value)

    Parameters:
    value: The value to be checked. This can be any string.

    Output:
    0 if the value is a floating-point number, otherwise 1.

    Example:
    result=$(is_float 42)       # result will be "0"
    result=$(is_float -42.0)    # result will be "0"
    result=$(is_float 3.14)     # result will be "0"
    result=$(is_float abc)      # result will be "1"
    result=$(is_float 3.14e-10) # result will be "0"
    '

    local value="$1"

    # Check if the value is a floating-point number using a regular expression
    if [[ "$value" =~ ^-?[0-9]+([.][0-9]+)?([eE][-+]?[0-9]+)?$ ]]; then
        return 0  # Return 0 (true) if the value is a floating-point number
    else
        return 1  # Return 1 (false) if the value is not a floating-point number
    fi
}


is_positive_float() {
:   '
    is_positive_float() - Check if a value is a positive floating-point number

    This function takes a single input value and checks if it is a positive
    floating-point number. It first calls is_float() to ensure the value is
    a floating-point number, then checks if the value is positive. If both
    conditions are met, the function returns 0 (success). Otherwise, it returns
    1 (failure).

    Usage:
    if is_positive_float value; then
        echo "Value is a positive float"
    else
        echo "Value is not a positive float"
    fi

    Parameters:
    value: The value to be checked. This can be any string.

    Returns:
    0 if the value is a positive floating-point number, otherwise 1.

    Example:
    is_positive_float 3.14     # returns 0 (true)
    is_positive_float 0.0      # returns 1 (false)
    is_positive_float -3.14    # returns 1 (false)
    is_positive_float abc       # returns 1 (false)
    is_positive_float 3.14e-10  # returns 0 (true)
    '

    local value="$1"

    # First, check if the value is a floating-point number
    if is_float "$value" && awk 'BEGIN { exit !('"$value"' > 0) }'; then
        return 0  # Return 0 (success) if the value is a positive float
    else
        return 1  # Return 1 (failure) if the value is not a positive float
    fi
}


is_non_negative_float() {
:   '
    is_non_negative_float() - Check if a value is a non-negative floating-point number

    This function takes a single input value and checks if it is a non-negative
    floating-point number. It first calls is_float() to ensure the value is
    a floating-point number, then checks if the value is non-negative. If both
    conditions are met, the function returns 0 (success). Otherwise, it returns
    1 (failure).

    Usage:
    if is_non_negative_float value; then
        echo "Value is a non-negative float"
    else
        echo "Value is not a non-negative float"
    fi

    Parameters:
    value: The value to be checked. This can be any string.

    Returns:
    0 if the value is a non-negative floating-point number, otherwise 1.

    Example:
    is_non_negative_float 3.14     # returns 0 (true)
    is_non_negative_float 0.0      # returns 0 (true)
    is_non_negative_float -3.14    # returns 1 (false)
    is_non_negative_float abc      # returns 1 (false)
    is_non_negative_float 3.14e-10 # returns 0 (true)
    '

    local value="$1"

    # First, check if the value is a floating-point number
    if is_float "$value" && awk 'BEGIN { exit !('"$value"' >= 0) }'; then
        return 0  # Return 0 (success) if the value is a non-negative float
    else
        return 1  # Return 1 (failure) if the value is not a non-negative float
    fi
}


is_valid_rho_value() {
:   '
    is_valid_rho_value() - Check if a value is a valid rho value

    This function takes a single input value and checks if it is a valid
    rho value, which must be a float between 0 and 2, inclusive. It first
    calls is_float() to ensure the value is a float, then checks if the
    value is within the specified range. If both conditions are met,
    the function returns 0 (success). Otherwise, it returns 1 (failure).

    Usage:
    if is_valid_rho_value rho_value; then
        echo "Value is a valid rho value"
    else
        echo "Value is not a valid rho value"
    fi

    Parameters:
    rho_value: The value to be checked. This can be any string.

    Returns:
    0 if the value is a valid rho value, otherwise 1.

    Example:
    is_valid_rho_value 1.5    # returns 0 (true)
    is_valid_rho_value 2      # returns 0 (true)
    is_valid_rho_value 0      # returns 0 (true)
    is_valid_rho_value 2.1    # returns 1 (false)
    is_valid_rho_value -0.5   # returns 1 (false)
    is_valid_rho_value abc     # returns 1 (false)
    '

    local rho_value="$1"

    # First, check if the value is a float
    if is_float "$rho_value" && awk -v val="$rho_value" 'BEGIN { exit !(val >= 0 && val <= 2) }'; then
        return 0  # Return 0 (success) if the value is a valid rho value
    else
        return 1  # Return 1 (failure) if the value is not a valid rho value
    fi
}


is_valid_clover_term_coefficient() {
:   '
    is_valid_clover_term_coefficient() - Check if a value is a valid clover term
    coefficient

    This function takes a single input value and checks if it is a valid
    clover term coefficient, which must be a float between 0 and 1, inclusive.
    It first calls is_float() to ensure the value is a float, then checks if the
    value is within the specified range. If both conditions are met, the
    function returns 0 (success). Otherwise, it returns 1 (failure).

    Usage:
    if is_valid_clover_term_coefficient clover_term_coefficient; then
        echo "Value is a valid clover term coefficient"
    else
        echo "Value is not a valid clover term coefficient"
    fi

    Parameters:
    clover_term_coefficient: The value to be checked. This can be any string.

    Returns:
    0 if the value is a valid clover term coefficient, otherwise 1.

    Example:
    is_valid_clover_term_coefficient 0.5    # returns 0 (true)
    is_valid_clover_term_coefficient 1.0    # returns 0 (true)
    is_valid_clover_term_coefficient 0.0    # returns 0 (true)
    is_valid_clover_term_coefficient 1.1    # returns 1 (false)
    is_valid_clover_term_coefficient -0.1   # returns 1 (false)
    is_valid_clover_term_coefficient abc     # returns 1 (false)
    '

    local clover_term_coefficient="$1"

    # First, check if the value is a float
    if is_float "$clover_term_coefficient" && awk -v val="$clover_term_coefficient" 'BEGIN { exit !(val >= 0 && val <= 1) }'; then
        return 0  # Return 0 (success) if the value is a valid clover term coefficient
    else
        return 1  # Return 1 (failure) if the value is not a valid clover term coefficient
    fi
}

# TODO: Accept "GAUGE_LINKS_CONFIGURATIONS_DIRECTORY" as input for unit-testing
# purposes
is_valid_gauge_links_configuration_label() {
    local gauge_configurations_label="$1"

    # Call match_configuration_label_to_file, discarding output
    if match_configuration_label_to_file "$gauge_configurations_label" >/dev/null 2>&1; then
        return 0  # Success
    else
        return 1  # Failure
    fi
}


# is_range_string()
# {
# :   '
#     Function: is_range_string
    
#     Description:
#       Checks if a variable (passed by name) contains a string formatted as a 
#       range string enclosed in square brackets. A range string consists of 
#       three numerical values (integers or floats) separated by spaces, enclosed 
#       in square brackets.
    
#     Parameters:
#       var_name: The name of the variable to be checked.
    
#     Returns:
#       Returns 0 if the variable matches the range string format, otherwise 
#       returns 1.
    
#     Example:
#       # Checks if the variable contains a valid range string
#       is_range_string OUTER_LOOP_VARYING_PARAMETER_SET_OF_VALUES
#     '

#     local var_name="$1"

#     # Use name reference to access the variable content
#     local -n var_value="$var_name"

#     # Check if the content matches the range string format
#     if [[ $var_value =~ ^\[[0-9]+(\.[0-9]+)?[[:space:]][0-9]+(\.[0-9]+)?[[:space:]][0-9]+(\.[0-9]+)?\]$ ]]; then
#         return 0  # True: It is a range string
#     else
#         return 1  # False: It is not a range string
#     fi
# }

is_range_string() {
:   '
    Function: is_range_string
    
    Description:
      Checks if a string contains a valid range string formatted as 
      "[{START} {END} {STEP}]". A range string consists of three numerical 
      values (integers or floats, including exponential form) separated by 
      spaces (allowing for multiple spaces), enclosed in square brackets.
    
    Parameters:
      range_string: The string to be checked.
    
    Returns:
      Returns 0 if the string matches the range string format, otherwise 
      returns 1.
    
    Example:
      # Checks if the string contains a valid range string
      is_range_string "[5 1 -1]"
    '

    local range_string="$1"

    # Check if the content matches the range string format
    if [[ $range_string =~ ^\[[+-]?([0-9]*[.])?[0-9]+([eE][+-]?[0-9]+)?[[:space:]]+[+-]?([0-9]*[.])?[0-9]+([eE][+-]?[0-9]+)?[[:space:]]+[+-]?([0-9]*[.])?[0-9]+([eE][+-]?[0-9]+)?\]$ ]]; then
        return 0  # True: It is a valid range string
    else
        return 1  # False: It is not a valid range string
    fi
}

