#!/bin/bash


# Get the directory path of the current script
CURRENT_SCRIPT_FULL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_SCRIPT_FULL_PATH/constants.sh"


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

    This function takes a single input value and checks if it is a floating-point
    number. It uses a regular expression to determine if the value is a valid
    floating-point number, which can be either positive or negative, and may
    contain a decimal point. If the value is a floating-point number, the function
    outputs "0". Otherwise, it outputs "1".

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


# is_float()
# {
#     local value="$1"

#     if [[ "$value" =~ ^[+-]?[0-9]+(\.[0-9]+)?$ ]]; then
#         return 0  # Return true if the value is a float
#     fi
# }

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
            echo 0  # Output 0 (true) if the value is a positive floating-point number
        else
            echo 1  # Output 1 (false) if the value is not a positive floating-point number
        fi
    else
        echo 1  # Output 1 (false) if the value is not a floating-point number
    fi
}


# is_positive_float()
# {
# :   '
#     is_positive_float() - Check if a value is a positive floating-point number

#     This function takes a single input value and checks if it is a positive
#     floating-point number. It uses the is_float function to determine if the 
#     value is a valid floating-point number and additionally checks if it is 
#     positive. If the value is a positive floating-point number, the function 
#     outputs "0". Otherwise, it outputs "1".

#     Usage:
#     result=$(is_positive_float value)

#     Parameters:
#     value: The value to be checked. This can be any string.

#     Output:
#     0 if the value is a positive floating-point number, otherwise 1.

#     Example:
#     result=$(is_positive_float 42)     # result will be "0"
#     result=$(is_positive_float 3.14)   # result will be "0"
#     result=$(is_positive_float -42.0)  # result will be "1"
#     result=$(is_positive_float abc)    # result will be "1"
#     '

#     local value="$1"

#     # Check if the value is a float using the is_float function
#     # if [[ $(is_float "$value") -eq 0 && $(echo "$value > 0" | bc -l) -eq 1 ]];
#     #  then

#     if [[ $(is_float "$value") -eq 0 && $(echo "$value > 0" | bc -l) -eq 1 ]]; then
#         echo 0  # Output 0 (true) if the value is a positive floating-point number
#     else
#         echo 1  # Output 1 (false) if the value is not a positive floating-point number
#     fi
# }


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
    Description: Calculates the KAPPA parameter based on the given BARE_MASS.
    Parameters:
    1. BARE_MASS: The bare mass value used in the calculation.
    Returns: None (prints the KAPPA value to the console).

    This function calculates the KAPPA value using the formula 0.5 / (4 + BARE_MASS)
    with a precision of at least 16 decimal places.
    '

    local BARE_MASS="$1"
    local KAPPA

    # Use bc to perform the calculation with high precision
    KAPPA=$(echo "scale=20; 0.5 / (4 + $BARE_MASS)" | bc)

    # Print the KAPPA value to the console, trimming trailing zeros in the decimal part
    printf "%.16f\n" "$KAPPA" | awk '{ sub(/\.?0+$/, ""); if ($0 ~ /^\./) print "0"$0; else print }'
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
            range+=("${files[index]}")
        done
    else
        for ((index = start - 1; index >= end - 1; index += step)); do
            range+=("${files[index]}")
        done
    fi

    # Print the range of file paths
    echo "${range[@]}"
}
