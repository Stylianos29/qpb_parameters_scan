#!/bin/bash


CURRENT_SCRIPT_FULL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_SCRIPT_FULL_PATH/constants.sh"


extract_configuration_label_from_file()
{
:   '
    Function: extract_configuration_label_from_file

    Description:
    This function extracts the configuration label from a given gauge links 
    configuration file full path. The configuration label is defined as the 
    substring after the last dot in the file path.

    Parameters:
    1. file_full_path: The full path to the gauge links configuration file.

    Returns:
    The configuration label extracted from the file full path.

    Example Usage:
    file_full_path="/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE/conf_Nf0_b6p20_L24T48_apeN1a0p72.0024200"
    configuration_label=$(extract_configuration_label_from_file "$file_full_path")
    echo "$configuration_label"  # Outputs: 0024200
    '

    local file_full_path="$1"
    local configuration_label="${file_full_path##*.}"
    echo "$configuration_label"
}


print_list_of_modifiable_parameters()
{
:   '
    Function to print the array elements with their indices and current values.
    
    Usage:
        print_list_of_modifiable_parameters
    
    Arguments:
        None
    
    Output:
        Prints each element of the MODIFIABLE_PARAMETERS_LIST array with its 
        index and current value.
    
    Example Output:
        1  : LATTICE_DIMENSIONS=48 24 24 24
        2  : CONFIG_LABEL=002
    
    Notes:
        - The function uses a for loop to iterate over each element in the 
          MODIFIABLE_PARAMETERS_LIST array.
        - Indirect variable expansion is used to dynamically access the value 
          of each parameter.
        - The printf command is used for formatted output, ensuring the index 
          is right-aligned and takes up at least 2 characters.
        - The index variable is incremented in each iteration to keep track of 
          the index of the current element.
    
    Example:
        MODIFIABLE_PARAMETERS_LIST=("PARAM1" "PARAM2")
        PARAM1="value1"
        PARAM2="value2"
        print_list_of_modifiable_parameters
        Output:
            1  : PARAM1=value1
            2  : PARAM2=value2
    '

    local index=0

    for parameter_name in "${MODIFIABLE_PARAMETERS_LIST[@]}"; do
        # "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH" needs different treatment
        if [ "$parameter_name" == "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH" ]; then
            # Indirect variable expansion to get the value of the parameter
            local parameter_value
            parameter_value=$(extract_configuration_label_from_file "${!parameter_name}")
            printf "%2d : CONFIGURATION_LABEL=%s\n" "$index" "$parameter_value"
        else
            local parameter_value="${!parameter_name}"
            printf "%2d : %s=%s\n" "$index" "$parameter_name" "$parameter_value"
        fi

        ((index++))
    done

    # Additional new line
    echo
}


extract_operator_method()
{
:   '
    Function to extract the operator method from a given script path
    Usage: extract_operator_method $multiple_runs_script_full_path
    Arguments:
        *multiple_runs_script_full_path: The full path of the script to extract 
        the operator method from.
    Output:
        Prints the extracted operator method based on the presence of predefined
         operator types in the script path. If no matching operator method is 
         found, it returns the default operator method.
    Example:
        operator_method=$(extract_operator_method \
                                        "/path/to/script/Brillouin_analysis.sh")
        This sets operator_method to "Brillouin" since the script path contains 
        the "Brillouin" operator type.
    Notes:
        - This function iterates over a predefined array of operator types and 
        checks if any of them are present in the script path.
        - If a match is found, it returns the matched operator method.
        - If no match is found, it returns the default operator method, which is
         the first element of the OPERATOR_METHODS_ARRAY.
        - The function assumes that the OPERATOR_METHODS_ARRAY is defined 
        globally or accessible within the scope of the script.
        - The function uses pattern matching to check if the operator method is 
        present in the script path.
    '

    local multiple_runs_script_full_path="$1"
    
    for operator_method in "${OPERATOR_METHODS_ARRAY[@]}"; do
        if [[ "$multiple_runs_script_full_path" == *"$operator_method"* ]]; then
            echo "$operator_method"
            return 0
        fi
    done

    echo ${OPERATOR_METHODS_ARRAY[0]}
}


extract_operator_type()
{
:   '
    Function: extract_operator_type
    Description: Maps the values of the OPERATOR_TYPE_FLAG variable to the
    corresponding operator type name.
    
    Parameters:
    1. OPERATOR_TYPE_FLAG (string): The flag indicating the operator type.
    
    Output:
        Sets the global variable OPERATOR_TYPE to "Standard" if 
        OPERATOR_TYPE_FLAG is "Standard", "Stan", or "0". 
        Sets OPERATOR_TYPE to "Brillouin" if OPERATOR_TYPE_FLAG is 
        "Brillouin", "Bri", or "1". 

    Usage example:
        OPERATOR_TYPE_FLAG=0
        extract_operator_type "$OPERATOR_TYPE_FLAG"
        echo $OPERATOR_TYPE  # Output: Standard

        OPERATOR_TYPE_FLAG=Bri
        extract_operator_type "$OPERATOR_TYPE_FLAG"
        echo $OPERATOR_TYPE  # Output: Brillouin

    Notes:
        - This function uses a case statement to match the values of 
        OPERATOR_TYPE_FLAG and set the OPERATOR_TYPE accordingly.
        - If the value of OPERATOR_TYPE_FLAG does not match any of the expected
        values, an error message is printed, and the function returns 1.
    '

    local flag="$1"

    case "$flag" in
        "Standard" | "Stan" | "0")
            OPERATOR_TYPE="Standard"
            ;;
        "Brillouin" | "Bri" | "1")
            OPERATOR_TYPE="Brillouin"
            ;;
        *)
            echo "Error: Invalid OPERATOR_TYPE_FLAG value '$flag'."
            echo "Valid values are 'Standard', 'Stan', '0', 'Brillouin', 'Bri', '1'."
            return 1
            ;;
    esac

    echo $OPERATOR_TYPE
    return 0
}


validate_indices_array()
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
            echo "Invalid value '$element' found in '$indices_array_name'" \
                 "indices array."
            echo "All elements must be integers."
            return 1
        fi
        # Check for any out-of-range integer elements in the input array
        if (( element < 0 || element >= list_length )); then
            echo "Invalid value '$element' found in '$indices_array_name'" \
                 "indices array."
            echo "All elements must be between 0 and $((list_length - 1))."
            return 1
        fi
        # Check if any elements of the input array correspond to the index of 
        # the "OPERATOR_TYPE" element of the "MODIFIABLE_PARAMETERS_LIST" 
        # global constant array
        if [[ "${MODIFIABLE_PARAMETERS_LIST[$element]}" == "OPERATOR_TYPE" ]];
        then
            echo "Invalid value '$element' found in '$indices_array_name'" \
                 "indices array."
            echo "Index corresponds to 'OPERATOR_TYPE'."
            return 1
        fi
        # Check for any duplicates in the input array
        if [[ -n "${already_encountered_indices[$element]}" ]]; then
            echo "Duplicate index '$element' found in '$indices_array_name'" \
                 "indices array."
            return 1
        else
            already_encountered_indices[$element]=1
        fi
    done

    return 0
}


validate_updated_constant_parameters_array()
{
:   '
    Function: validate_updated_constant_parameters_array
    Description: Validates that the keys in the provided list of updated 
    constants are present in the list of modifiable parameters.
    Parameters:
    1. list_of_updated_constant_values (array): An array containing 
        key-value pairs in the format "KEY=VALUE". These pairs represent
        constants and their updated values.
    Returns: 
    0 if all keys are valid, otherwise 1 if any key is invalid.

    This function reads a list of updated constants from the 
    list_of_updated_constant_values array parameter. Each item in the array
    is expected to be a string in the format "KEY=VALUE", where KEY is the
    name of the constant to be updated and VALUE is its new value. It checks
    each key against the list of valid modifiable parameters and returns 1 
    if any key is not in the list.

    Usage example:
    # Define an array of constants to update
    constants=(
        "NUMBER_OF_CHEBYSHEV_TERMS=3"
        "RHO=0.3"
        )
    # Call the function to validate constants
    validate_updated_constant_parameters_array "${constants[@]}"
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


match_configuration_label_to_file()
{
:   '
    Function to find a file in a specified directory that ends with a given 
    suffix.
    Usage: match_configuration_label_to_file <configuration_label>
    Arguments:
        * configuration_label: The suffix that the target file should end with.
    Output:
        - If exactly one file is found with the specified suffix, the function
          prints the full path of the file.
        - If no file or more than one file is found with the specified suffix,
          the function prints an error message and returns 1.
    Example:
        file_path=$(match_configuration_label_to_file "0024200")
        if [ $? -eq 0 ]; then
            echo "File found: $file_path"
        else
            echo "An error occurred."
        fi
    Notes:
        - The function uses the `find` command to search for files.
        - The function assumes that the `find` command is available on the 
        system.
        - If no files or more than one file is found, the function returns 1.
        - Ensure the search directory path (stored in
         GAUGE_LINKS_CONFIGURATIONS_DIRECTORY) and file suffix are correctly
          specified.
    '
    
    local configuration_label="$1"

    # Find files that end with the specified suffix in the global directory
    local files=($(find "$GAUGE_LINKS_CONFIGURATIONS_DIRECTORY" -type f -name \
                                                    "*$configuration_label"))

    # Check the number of files found
    if [ ${#files[@]} -eq 0 ]; then
        echo "Error: No configuration file ending with '$configuration_label'"\
        "found."
        return 1
    elif [ ${#files[@]} -gt 1 ]; then
        echo "Error: More than one configuration file ending with"\
        "'$configuration_label' found:"
        for file in "${files[@]}"; do
            echo "$file"
        done
        return 1
    else
        echo "${files[0]}"
    fi
}


constant_parameters_update() {
:   '
    Function: constant_parameters_update
    Description: Updates constants with new values based on input data.
    Parameters:
    1. list_of_updated_constant_values (array): An array containing 
        key-value pairs in the format "KEY=VALUE". These pairs represent
        constants and their updated values.
    Returns: None

    This function reads a list of updated constants from the 
    list_of_updated_constant_values array parameter. Each item in the array
    is expected to be a string in the format "KEY=VALUE", where KEY is the
    name of the constant to be updated and VALUE is its new value. It splits
    each item into KEY and VALUE using the '=' delimiter and updates the 
    corresponding constant using indirect reference with eval.

    Usage example:
    # Define an array of constants to update
    constants=(
        "NUMBER_OF_CHEBYSHEV_TERMS=3"
        "RHO=0.3"
    )
    # Call the function to update constants
    constant_parameters_update "${constants[@]}"
    '

    local list_of_updated_constant_values=("$@")

    # Temporary variable to store the updated file path
    local updated_file_path

    # Read updated constants from input.txt
    for item in "${list_of_updated_constant_values[@]}"; do
        # Split the key-value pair
        IFS='=' read -r key value <<< "$item"
        
        # Check if the key is CONFIGURATION_LABEL
        if [[ "$key" == "CONFIGURATION_LABEL" ]]; then
            # Attempt to update GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH
            updated_file_path=$(match_configuration_label_to_file "$value")
            if [ $? -ne 0 ]; then
                echo "Error: Invalid configuration label '$value'."
                continue  # Skip updating this key if there was an error
            fi
            eval "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH='$updated_file_path'"
        else
            # Update the constant using indirect reference
            eval "$key='$value'"
        fi
    done
}


is_range_string()
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


parameter_range_of_values_generator()
{
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

# TODO: What about a general integer numbers range function?
construct_number_of_Chebyshev_terms_range()
{
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


validate_varying_parameter_values_array()
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

    local varying_parameter_index=${VARYING_PARAMETERS_INDICES_LIST[$index]}
  local parameter_name="${MODIFIABLE_PARAMETERS_LIST[$varying_parameter_index]}"

    # Check if a range of values was requested.
    if is_range_string "${parameter_values_array[*]}"; then
        # If indeed, then generate range and assign it back to the varying
        # parameter values array
        # TODO: I need to find a way to handle error
        local range_of_values_function=\
"${MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY[$parameter_name]}"

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
    fi

    # Check validity of each element of the varying parameter values array
    if [ "$parameter_name" != "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH" ]; then
        local test_function="\
            ${MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY[$parameter_name]}"
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
