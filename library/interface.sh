#!/bin/bash


######################################################################
# library/constants.sh - ?
#
# This script contains a collection of custom functions to
# check and analyze parameters, not related to their nature?
# functions directly related to the user's input
# 
#
# Author: Stylianos Gregoriou Date last modified: 22nd May 2024
#
# Usage: Source this script in other Bash scripts to access the custom functions
#        defined herein.
#
######################################################################


CURRENT_SCRIPT_FULL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_SCRIPT_FULL_PATH/constants.sh"
source "$CURRENT_SCRIPT_FULL_PATH/parameters.sh"


extract_overlap_operator_method()
{
:   '
    Description: This function extracts the overlap operator method from a 
    given file or directory path. It checks for specific substrings related to 
    the operator method ("Chebyshev" or "KL") and echoes the corresponding 
    method. If no match is found, it defaults to "Bare."

    Parameters:
    - path (string): The full path that is checked for specific substrings to 
      identify the overlap operator method.

    Returns:
    - "Chebyshev" if the path contains "Chebyshev", "chebyshev", or "CHEBYSHEV".
    - "KL" if the path contains "KL" or "kl".
    - "Bare" if none of the above substrings are found.

    Usage Example:
        method=$(extract_overlap_operator_method "/path/to/file_with_Chebyshev")
        echo "Operator method: $method"  # Outputs: Operator method: Chebyshev

    Notes:
    - The function performs case-insensitive substring matching using regular 
      expressions to check for "Chebyshev" or "KL" in the provided path.
    - If neither "Chebyshev" nor "KL" is found, it assumes the operator method 
      is "Bare."
    '
    
    local path="$1"  # Input path

    # 1. Check for "Chebyshev", "chebyshev", or "CHEBYSHEV"
    if [[ "$path" =~ [Cc][Hh][Ee][Bb][Yy][Ss][Hh][Ee][Vv] ]]; then
        echo "Chebyshev"

    # 2. Check for "KL" or "kl"
    elif [[ "$path" =~ [Kk][Ll] ]]; then
        echo "KL"

    # 3. Default case
    else
        echo "Bare"
    fi
}


extract_kernel_operator_type()
{
:   '
    Function: extract_kernel_operator_type
    Description: Maps the values of the KERNEL_OPERATOR_TYPE_FLAG variable to 
    the corresponding operator type name based on predefined mappings.

    Parameters:
    - KERNEL_OPERATOR_TYPE_FLAG (string): The flag indicating the operator type. 
      This can be one of the predefined values: "Standard", "Stan", "0", 
      "Brillouin", "Bri", or "1".

    Returns:
    - Outputs the operator type based on the value of KERNEL_OPERATOR_TYPE_FLAG:
        - "Standard" for "Standard", "Stan", or "0"
        - "Brillouin" for "Brillouin", "Bri", or "1"
    - Returns 1 if the flag value is invalid, along with an error message.

    Usage Example:
        KERNEL_OPERATOR_TYPE_FLAG="0"
        operator_type=$(extract_kernel_operator_type \
                                                "$KERNEL_OPERATOR_TYPE_FLAG")
        echo $operator_type  # Output: Standard

        KERNEL_OPERATOR_TYPE_FLAG="Bri"
        operator_type=$(extract_kernel_operator_type \
                                                "$KERNEL_OPERATOR_TYPE_FLAG")
        echo $operator_type  # Output: Brillouin

    Notes:
    - This function uses a case statement to match the values of 
      KERNEL_OPERATOR_TYPE_FLAG and return the corresponding operator type.
    - If the value of KERNEL_OPERATOR_TYPE_FLAG does not match any of the 
      expected values, the function prints an error message with valid options 
      and returns 1.
    '

    local kernel_operator_type_flag="$1"

    case "$kernel_operator_type_flag" in
        "Standard" | "Stan" | "0")
            echo "Standard"
            return 0
            ;;
        "Brillouin" | "Bri" | "1")
            echo "Brillouin"
            return 0
            ;;
        *)
            echo "Error: Invalid KERNEL_OPERATOR_TYPE_FLAG value "\
                                                "'$kernel_operator_type_flag'."
            echo "Valid values are:"
            echo "'Standard', 'Stan', '0', or"
            echo " 'Brillouin', 'Bri', '1'."
            return 1
            ;;
    esac
}


extract_QCD_beta_value()
{
:   '
    Function: extract_QCD_beta_value
    Description: Extracts the QCD beta value from a given gauge links
    configurations directory path. The QCD beta value is defined as the
    substring between "_b" and "_L" in the directory path.
    
    Parameters:
    - path (string): The full gauge links configurations directory path from
      which to extract the QCD beta value. Example:
      "/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE".
    
    Returns: 
    - Prints the extracted QCD beta value if found.
    - Returns 0 on successful extraction.
    - Prints an error message and returns 1 if the QCD beta value is not found.
    
    Example Usage:
        beta_value=$(extract_QCD_beta_value \
                            "/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE")
        if [ $? -eq 0 ]; then
            echo "Extracted QCD beta value: $beta_value"
        else
            echo "Failed to extract QCD beta value."
        fi
    '

    local gauge_links_configurations_directory_path="$1"

    # Use parameter expansion to extract the QCD beta value
    if [[ "$gauge_links_configurations_directory_path" =~ _b([^_]+)_L ]]; then
        local beta_value="${BASH_REMATCH[1]}"
        beta_value="${beta_value//p/.}"
        echo "$beta_value"
        return 0
    else
        echo "Error: QCD beta value not found in the given path."
        return 1
    fi
}


extract_lattice_dimensions()
{
:   '
    Function: extract_lattice_dimensions
    Description: Extracts lattice dimensions from a given directory path. The 
    function looks for a substring in the format 
    "_L{spatial_side}T{temporal_side}" within the directory path and returns the
     dimensions in a specified format.

    Parameters:
    - dir_path (string): The full directory path from which to extract the
      lattice dimensions. Example path: "/path/to/directory/_L24T48".

    Returns:
    - Prints the dimensions in the format: 
                    "$temporal_side $spatial_side $spatial_side $spatial_side".
    - Returns 1 if the expected substring is not found in the directory path.

    Usage Example:
        dimensions=$(extract_lattice_dimensions \
                            "/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE")
        if [ $? -eq 0 ]; then
            echo "Lattice dimensions: $dimensions"
        else
            echo "Failed to extract lattice dimensions."
        fi

    Notes:
    - The function uses a regular expression to identify and extract the spatial 
      and temporal sides from the provided directory path.
    - If the expected format is not found, the function prints an error message 
      and returns 1, indicating failure.
    '

    local dir_path="$1"
    
    # Use a regex to extract the substring of the form
    # "_L{spatial_side}T{temporal_side}"
    if [[ "$dir_path" =~ _L([0-9]+)T([0-9]+) ]]; then
        spatial_side="${BASH_REMATCH[1]}"   # Extract the spatial side (L)
        temporal_side="${BASH_REMATCH[2]}"  # Extract the temporal side (T)

        # Print the desired output: "$temporal_side $spatial_side $spatial_side
        # $spatial_side"
        echo "$temporal_side $spatial_side $spatial_side $spatial_side"
    else
        echo "Error: Lattice dimensions not found in the directory path"
        return 1
    fi
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
            echo "Error: Index '$index' in array '$indices_array_name' "\
                                                        "is not an integer."
            return 1
        fi

        # 2. Check for duplicates
        if [[ -n "${seen[$index]}" ]]; then
            echo "Error: Duplicate index '$index' found in "\
                                                "array '$indices_array_name'."
            return 1
        fi
        seen[$index]=1  # Mark the index as seen

        # 3. Check if the index is within the valid range
        if (( index < 0 || index > max_index )); then
            echo "Error: Index '$index' in array '$indices_array_name' is out "\
                                "of range (valid range is 0 to $max_index)."
            return 1
        fi
    done

    return 0
}


is_range_string()
{
:   '
    Function: is_range_string
    
    Description:
      Checks if a variable (passed by name) contains a string formatted as a 
      range string enclosed in square brackets. A range string consists of 
      three numerical values (integers or floats) separated by spaces, enclosed 
      in square brackets.
    
    Parameters:
      var_name: The name of the variable to be checked.
    
    Returns:
      Returns 0 if the variable matches the range string format, otherwise 
      returns 1.
    
    Example:
      # Checks if the variable contains a valid range string
      is_range_string OUTER_LOOP_VARYING_PARAMETER_SET_OF_VALUES
    '

    local var_name="$1"

    # Use name reference to access the variable content
    local -n var_value="$var_name"

    # Check if the content matches the range string format
    if [[ $var_value =~ ^\[[0-9]+(\.[0-9]+)?[[:space:]][0-9]+(\.[0-9]+)?[[:space:]][0-9]+(\.[0-9]+)?\]$ ]]; then
        return 0  # True: It is a range string
    else
        return 1  # False: It is not a range string
    fi
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
validate_varying_parameter_values_array_new()
{
    local parameter_name="$1"
    local varying_parameter_values_array_name="$2"

    # Check if the input is an array
    if [[ -z "$(declare -p "$varying_parameter_values_array_name" 2>/dev/null)"\
 || "$(declare -p "$varying_parameter_values_array_name")" != "declare -a"* ]]; 
    then
        echo "Error: $varying_parameter_values_array_name is not a valid array."
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
    
    # Check validity of each element of the varying parameter values array
    local validating_function="\
            ${MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY[$parameter_name]}"
    for element in "${varying_parameter_values_array[@]}"; do
        if [ $($validating_function "$element") -ne 0 ]; then
            echo "Error. '${varying_parameter_values_array[*]}' array contains"\
                "invalid elements with respect to the chosen varying parameter."
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
            echo "Error: Invalid parameter name to be updated: '$key'."
            return 1
        fi

        # Check if the key is in the varying_iterable_parameters_array
        if [[ " ${varying_iterable_parameters_array[@]} " =~ " ${key} " ]]; then
            echo "Error: A fixed value cannot be assigned to the varying parameter: '$key'."
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


constant_parameters_update()
{
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
                echo "Error: Invalid configuration label '$value'."
                continue  # Skip updating this key if there was an error
            fi
            eval "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH='$updated_file_path'"
        fi

        # Check for BARE_MASS and KAPPA_VALUE updates
        if [[ "$key" == "BARE_MASS" ]]; then
            if [ "$kappa_value_updated" = true ]; then
                echo "Error: Cannot update both 'BARE_MASS' and 'KAPPA_VALUE' at the same time."
                return 1
            fi
            bare_mass_updated=true
            KAPPA_VALUE=$(calculate_kappa_value "$value")
        elif [[ "$key" == "KAPPA_VALUE" ]]; then
            if [ "$bare_mass_updated" = true ]; then
                echo "Error: Cannot update both 'BARE_MASS' and 'KAPPA_VALUE' at the same time."
                return 1
            fi
            kappa_value_updated=true
            BARE_MASS=$(calculate_bare_mass_from_kappa_value "$value")
        fi

    done
}


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



################################################################################


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





# TODO: Remove
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


parameter_range_of_values_generator()
{
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



parameter_range_of_values_generator_old()
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


# TODO: This function is way too large and needs to be split
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
    local -n parameters_list="$3"

    local varying_parameter_index=${VARYING_PARAMETERS_INDICES_LIST[$index]}
  local parameter_name="${parameters_list[$varying_parameter_index]}"

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
        echo "Error: Common elements found: '${common_elements[@]}'"
        return 1
    # else
    #     echo "No common elements found."
        return 0
    fi
}


print_lattice_dimensions() {
    local temporal_dimension="$1"
    local spatial_dimension="$2"

    # Output the string in the form "T${temporal_dimension}L${spatial_dimension}"
    echo "T${temporal_dimension}L${spatial_dimension}"
}





modify_decimal_format() {
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


modify_decimal_format_old()
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