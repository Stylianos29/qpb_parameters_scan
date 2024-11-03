#!/bin/bash


# TODO: Write description
######################################################################
# library/parameters.sh - Script for 
#
#
######################################################################


# MULTIPLE SOURCING GUARD

# Prevent multiple sourcing of this script by exiting if INTERFACE_SH_INCLUDED 
# is already set. Otherwise, set INTERFACE_SH_INCLUDED to mark it as sourced.
[[ -n "${INTERFACE_SH_INCLUDED}" ]] && return
INTERFACE_SH_INCLUDED=1

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


# TODO: Potential improvement: identify the common part among the configuration
# files and define the label as the different part
extract_configuration_label_from_file()
{
:   '
    Function: extract_configuration_label_from_file

    Description:
    This function extracts the configuration label from a given gauge links 
    configuration file full path. The configuration label is defined as the 
    substring after the last dot (.) in the filename, typically representing 
    a configuration identifier. If no dot is present, an error is printed.

    Parameters:
    1. file_full_path: The full path to the gauge links configuration file.

    Returns:
    The configuration label extracted from the file full path if a dot is 
    present. If no dot is found, an error message is printed, and the 
    function returns 1.

    Example Usage:
    file_full_path="./conf_Nf0_b6p20_L24T48_apeN1a0p72.0024200"
    configuration_label=$(extract_configuration_label_from_file \
                                                            "$file_full_path")
    echo "$configuration_label"  # Outputs: 0024200
    '

    local file_full_path="$1"

    # Check if the path contains a dot
    if [[ "$file_full_path" != *.* ]]; then
        echo "Error: No dot found in the file path '$file_full_path'."
        return 1
    fi

    # Extract the configuration label (substring after the last dot)
    local configuration_label="${file_full_path##*.}"
    
    echo "$configuration_label"
}


check_gauge_configurations_label() {
    local gauge_configurations_label="$1"

    # Call match_configuration_label_to_file and check if it succeeds
    if match_configuration_label_to_file "$gauge_configurations_label"; then
        return 0  # Success
    else
        return 1  # Failure
    fi
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


check_lattice_dimensions()
{
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


is_integer()
{
:   '
    is_integer() - Check if a value is an integer

    This function takes a single input value and checks if it is an integer.
    It uses a regular expression to determine if the value is an integer, which
    can be either positive or negative. If the value is an integer, the function
    outputs "1". Otherwise, it outputs "0".

    Usage:
    result=$(is_integer value)

    Parameters:
    value: The value to be checked. This can be any string.

    Output:
    1 if the value is an integer, otherwise 0.

    Example:
    result=$(is_integer 42)   # result will be "1"
    result=$(is_integer -42)  # result will be "1"
    result=$(is_integer 3.14) # result will be "0"
    result=$(is_integer abc)  # result will be "0"
    '

    local value="$1"

    # Check if the value is an integer using a regular expression
    if [[ "$value" =~ ^-?[0-9]+$ ]]; then
        echo 0  # Output 0 (true) if the value is an integer
    else
        echo 1  # Output 0 (false) if the value is not an integer
    fi
}


is_positive_integer()
{
:   '
    is_positive_integer() - Check if a value is a positive integer

    This function takes a single input value and checks if it is a positive 
    integer. It first checks if the value is an integer using the is_integer 
    function. If the value is an integer and greater than zero, the function 
    outputs "0". Otherwise, it outputs "1".

    Usage:
    result=$(is_positive_integer value)

    Parameters:
    value: The value to be checked. This can be any string.

    Output:
    0 if the value is a positive integer, otherwise 1.

    Example:
    result=$(is_positive_integer 42)   # result will be "0"
    result=$(is_positive_integer -42)  # result will be "1"
    result=$(is_positive_integer 3.14) # result will be "1"
    result=$(is_positive_integer abc)  # result will be "1"
    result=$(is_positive_integer 0)    # result will be "1"
    '

    local value="$1"

    # Check if the value is an integer using the is_integer function
    if [ $(is_integer "$value") -eq 0 ] && [ "$value" -gt 0 ]; then
        echo 0  # Output 0 (true) if the value is a positive integer
    else
        echo 1  # Output 1 (false) if the value is not a positive integer
    fi
}


is_non_negative_integer()
{
:   '
    is_non_negative_integer() - Check if a value is a non-negative integer

    This function takes a single input value and checks if it is a non-negative 
    integer. It first checks if the value is an integer using the is_integer 
    function. If the value is an integer and greater than or equal to zero, the 
    function outputs "0". Otherwise, it outputs "1".

    Usage:
    result=$(is_non_negative_integer value)

    Parameters:
    value: The value to be checked. This can be any string.

    Output:
    0 if the value is a non-negative integer, otherwise 1.

    Example:
    result=$(is_non_negative_integer 42)   # result will be "0"
    result=$(is_non_negative_integer -42)  # result will be "1"
    result=$(is_non_negative_integer 3.14) # result will be "1"
    result=$(is_non_negative_integer abc)  # result will be "1"
    result=$(is_non_negative_integer 0)    # result will be "0"
    '

    local value="$1"

    # Check if the value is an integer using the is_integer function
    if [ $(is_integer "$value") -eq 0 ] && [ "$value" -ge 0 ]; then
        echo 0  # Output 0 (true) if the value is a non-negative integer
    else
        echo 1  # Output 1 (false) if the value is not a non-negative integer
    fi
}


is_float()
{
:   '
    is_float() - Check if a value is a floating-point number

    This function takes a single input value and checks if it is a
    floating-point number. It uses a regular expression to determine if the 
    value is a valid floating-point number, which can be either positive or
    negative, and may contain a decimal point. If the value is a floating-point
    number, the function outputs "0". Otherwise, it outputs "1".

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
    # if [[ "$value" =~ ^-?[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?$ ]]; then
        # echo 0 
        echo 0  # Output 0 (true) if the value is a floating-point number
    else
        echo 1  # Output 1 (false) if the value is not a floating-point number
    fi
}


is_positive_float() {
:   '
    is_positive_float() - Check if a value is a positive floating-point number

    This function takes a single input value and checks if it is a positive
    floating-point number. It uses the is_float function to determine if the 
    value is a valid floating-point number and additionally checks if it is 
    positive. If the value is a positive floating-point number, the function 
    outputs "0". Otherwise, it outputs "1".

    Usage:
    result=$(is_positive_float value)

    Parameters:
    value: The value to be checked. This can be any string.

    Output:
    0 if the value is a positive floating-point number, otherwise 1.

    Example:
    result=$(is_positive_float 42)     # result will be "0"
    result=$(is_positive_float 3.14)   # result will be "0"
    result=$(is_positive_float 3.14e-10) # result will be "0"
    result=$(is_positive_float -42.0)  # result will be "1"
    result=$(is_positive_float abc)    # result will be "1"
    '

    local value="$1"

    # Check if the value is a float using the is_float function
    if [[ $(is_float "$value") -eq 0 ]]; then
        # Use awk to check if the value is greater than 0
        if echo "$value" | awk '{exit ($1 <= 0)}'; then
            # Output 0 (true) if value is a positive floating-point number
            echo 0  
        else
            # Output 1 (false) if value is not a positive floating-point number
            echo 1
        fi
    else
        echo 1  # Output 1 (false) if the value is not a floating-point number
    fi
}



check_rho_value()
{
:   '
    check_rho_value() - Check if a value is a float within the range [0, 2]

    This function takes a single input value and checks if it is a floating-point 
    number within the range [0, 2]. It uses the is_float function to determine 
    if the value is a valid floating-point number and additionally checks if it 
    is within the specified range. If the value meets these criteria, the function 
    outputs "0". Otherwise, it outputs "1".

    Usage:
    result=$(check_rho_value value)

    Parameters:
    value: The value to be checked. This can be any string.

    Output:
    0 if the value is a float within the range [0, 2], otherwise 1.

    Example:
    result=$(check_rho_value 1.5)   # result will be "0"
    result=$(check_rho_value 2.1)   # result will be "1"
    result=$(check_rho_value -1.0)  # result will be "1"
    result=$(check_rho_value abc)   # result will be "1"
    '

    local value="$1"

    # Check if the value is a float using the is_float function
    if [[ $(is_float "$value") -eq 0 && $(echo "$value >= 0 && $value <= 2" | bc -l) -eq 1 ]]; then
        echo 0  # Output 0 (true) if the value is a float within the range [0, 2]
    else
        echo 1  # Output 1 (false) if the value is not a float within the range [0, 2]
    fi
}


check_clover_term_coefficient_value()
{
:   '
    check_clover_term_coefficient_value() - Check if a value is a float within the range [0, 1]

    This function takes a single input value and checks if it is a floating-point 
    number within the range [0, 1]. It uses the is_float function to determine 
    if the value is a valid floating-point number and additionally checks if it 
    is within the specified range. If the value meets these criteria, the function 
    outputs "0". Otherwise, it outputs "1".

    Usage:
    result=$(check_clover_term_coefficient_value value)

    Parameters:
    value: The value to be checked. This can be any string.

    Output:
    0 if the value is a float within the range [0, 1], otherwise 1.

    Example:
    result=$(check_clover_term_coefficient_value 0.5)   # result will be "0"
    result=$(check_clover_term_coefficient_value 1.1)   # result will be "1"
    result=$(check_clover_term_coefficient_value -0.5)  # result will be "1"
    result=$(check_clover_term_coefficient_value abc)   # result will be "1"
    '

    local value="$1"

    # Check if the value is a float using the is_float function
    if [[ $(is_float "$value") -eq 0 && $(echo "$value >= 0 && $value <= 1" | bc -l) -eq 1 ]]; then
        echo 0  # Output 0 (true) if the value is a float within the range [0, 1]
    else
        echo 1  # Output 1 (false) if the value is not a float within the range [0, 1]
    fi
}


check_operator_type()
{
:   '
    Function to check if a given operator type is valid.
    Usage: check_operator_type $operator_type
    Arguments:
        * operator_type: The operator type to be checked against the valid 
        operator types.
    Output:
        Prints 0 if the operator type is valid (i.e., it is one of the elements 
        in OPERATOR_TYPES_ARRAY), otherwise 
        prints 1 if it is not valid.
    Example:
        is_valid=$(check_operator_type "Brillouin")
        if [ "$is_valid" -eq 0 ]; then
            echo "Operator type is valid."
        else
            echo "Operator type is invalid."
        fi
    Notes:
        - The function iterates over the OPERATOR_TYPES_ARRAY constant array to 
        check for a match.
        - The function prints 0 (true) if the operator type is found in the 
        array.
        - The function prints 1 (false) if the operator type is not found in the
         array.
    '

    local operator_type="$1"

    for valid_operator in "${OPERATOR_TYPES_ARRAY[@]}"; do
        if [ "$operator_type" == "$valid_operator" ]; then
            echo 0  # True
            return
        fi
    done

    echo 1  # False
}


calculate_kappa_value() {
    : '
    Function: calculate_kappa_value
    Description: Calculates the kappa_value parameter based on the given bare_mass.
    Parameters:
    1. bare_mass: The bare mass value used in the calculation.
    Returns: None (prints the kappa_value value to the console).

    This function calculates the kappa_value value using the formula 0.5 / (4 + bare_mass)
    with a precision of at least 16 decimal places.
    '

    local bare_mass="$1"
    local kappa_value

    # Use bc to perform the calculation with high precision
    kappa_value=$(echo "scale=20; 0.5 / (4 + $bare_mass)" | bc)

    # Print the kappa_value value to the console, trimming trailing zeros in the decimal part
    printf "%.16f\n" "$kappa_value" | awk '{ sub(/\.?0+$/, ""); if ($0 ~ /^\./) print "0"$0; else print }'
}


calculate_bare_mass_from_kappa_value() {
    : '
    Function: calculate_kappa_value
    Description: Calculates the kappa_value parameter based on the given bare_mass.
    Parameters:
    1. bare_mass: The bare mass value used in the calculation.
    Returns: None (prints the kappa_value value to the console).

    This function calculates the kappa_value value using the formula 0.5 / (4 + bare_mass)
    with a precision of at least 16 decimal places.
    '

    local kappa_value="$1"
    local bare_mass

    # Use bc to perform the calculation with high precision
    bare_mass=$(echo "scale=20; 0.5/$kappa_value - 4.0" | bc)

    # Print the bare_mass value to the console, trimming trailing zeros in the decimal part
    printf "%.16f\n" "$bare_mass" | awk '{ sub(/\.?0+$/, ""); if ($0 ~ /^\./) print "0"$0; else print }'
}


general_range_of_values_generator()
{
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
        start=$(awk -v num="$start" 'BEGIN { print num + 0 }')
        end=$(awk -v num="$end" 'BEGIN { print num + 0 }')
        step=$(awk -v num="$step" 'BEGIN { print num + 0 }')
    fi

    # Determine precision of step
    precision=$(\
      echo "$step" | awk -F. '{ if (NF==1) print 0; else print length($2) }')

    # Use awk to generate the range of values
    range=$(awk -v start="$start" -v \
                        end="$end" -v step="$step" -v precision="$precision" '
    BEGIN {
        format = "%." precision "f"
        for (i = start; (step > 0 ? i <= end : i >= end); i += step) {
            printf format " ", i
        }
    }')

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


# TODO: The output of this function is not that useful
lattice_dimensions_range_of_strings_generator()
{
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


range_of_gauge_configurations_file_paths_generator()
{
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


check_rho_value()
{
:   '
    Function to check if the 'rho' parameter is a valid numerical value greater
     than 0 and smaller than 2
    Usage:    check_rho_value <rho>
    Arguments:    rho: The value of the rho parameter to check.
    Output:
        - Echoes 0 if the value is a valid numerical value greater than 0 and
         smaller than 2.
        - Echoes 1 if the value is not valid.
    Example:
        check_rho_value 1.5
    Output:
        - If the value is valid, it will echo 0.
        - If the value is not valid, it will echo 1.
    Notes:
        - The function uses regex to check if the value is a number.
        - The function checks if the value is within the valid range (0, 2).
    '

    local rho="$1"

    # Check if the value is a number
    if ! [[ "$rho" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        echo 1
        return 1
    fi

    # Check if the value is greater than 0 and smaller than 2
    if (( $(echo "$rho <= 0" | bc -l) )) || (( $(echo "$rho >= 2" | bc -l) ));
    then
        echo 1
        return 1
    fi

    # If all checks pass, return success
    echo 0
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


convert_mpi_geometry_to_number_of_tasks()
{
: '
  Takes an arr
  '

  local mpi_geometry_string=$1

  # Extract the numbers from the string
  IFS=',' read -r num1 num2 num3 <<< "$mpi_geometry_string"

  product=$((num1 * num2 * num3))

  echo $product
}

