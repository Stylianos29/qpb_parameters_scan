#!/bin/bash


######################################################################
# library/parameters_conversions.sh - Script for transforming and handling
# parameter values for the qpb project
#
# This script contains functions that perform various transformations and
# conversions on parameters used in the C/C++ qpb project. It includes utilities
# for extracting and calculating values related to lattice dimensions, operator
# types, bare mass, kappa value, and MPI geometry. These functions ensure that
# input parameters are correctly processed and transformed for further use in
# calculations within the project.
######################################################################


# MULTIPLE SOURCING GUARD

# Prevent multiple sourcing of this script by exiting if PARAMETERS_SH_INCLUDED
# is already set. Otherwise, set PARAMETERS_SH_INCLUDED to mark it as sourced.
[[ -n "${PARAMETERS_SH_INCLUDED}" ]] && return
PARAMETERS_SH_INCLUDED=1

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

extract_overlap_operator_method() {
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

    # Extract the relative path starting from "mainprogs"
    relative_path="${path#*mainprogs/}"
    # Check if "mainprogs" was actually in the path
    if [[ "$relative_path" == "$path" ]]; then
        warning_message="'mainprogs' directory was not found in gauge links "
        warning_message+="configurations directory path."
        log "WARNING" "$warning_message"
        # If not, then extract the last 4 levels of the directory path
        relative_path=$(echo "$path" \
            | awk -F'/' '{for(i=NF-3;i<=NF;i++) printf (i<NF? $i "/": $i)}')
    fi

    # 1. Check for "Chebyshev", "chebyshev", or "CHEBYSHEV"
    if [[ "$relative_path" =~ [Cc][Hh][Ee][Bb][Yy][Ss][Hh][Ee][Vv] ]]; then
        echo "Chebyshev"

    # 2. Check for "KL" or "kl"
    elif [[ "$relative_path" =~ [Kk][Ll] ]]; then
        echo "KL"

    # 3. Default case
    else
        echo "Bare"
    fi
}


extract_kernel_operator_type() {
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
            local error_message="Invalid kernel operator type flag value: "
            error_message+="'$KERNEL_OPERATOR_TYPE_FLAG'.\n"
            error_message+="Valid values are:\n"
            error_message+="- 'Standard', 'Stan', '0', or\n"
            error_message+="- 'Brillouin', 'Bri', '1'."
            termination_output "${error_message}"
            return 1
            ;;
    esac
}


extract_QCD_beta_value() {
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
        local error_message="QCD beta value not found in the given path."
        termination_output "${error_message}"
        return 1
    fi
}


extract_lattice_dimensions() {
:   '
    Function: extract_lattice_dimensions
    Description: Extracts lattice dimensions from a given directory path. The 
    function looks for a substring in the format 
    "_L{spatial_side}T{temporal_side}" within the directory path and returns the
     dimensions in a specified format.

    Parameters:
    - directory_path (string): The full directory path from which to extract the
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

    local directory_path="$1"
    
    # Use a regex to extract the substring of the form
    # "_L{spatial_side}T{temporal_side}"
    if [[ "$directory_path" =~ _L([0-9]+)T([0-9]+) ]]; then
        local spatial_side="${BASH_REMATCH[1]}"  # Extract the spatial side (L)
        local temporal_side="${BASH_REMATCH[2]}" # Extract the temporal side (T)

        # Print the desired output: "$temporal_side $spatial_side $spatial_side
        # $spatial_side"
        echo "$temporal_side $spatial_side $spatial_side $spatial_side"
    else
        local error_message="Lattice dimensions not found in the "
        error_message+="directory path."
        termination_output "${error_message}"
        return 1
    fi
}


calculate_kappa_value_from_bare_mass() {
    : '
    Function: calculate_kappa_value_from_bare_mass

    Description:
    This function calculates the "kappa" value from a given "bare mass" value 
    using the formula: kappa = 0.5 / (4 + bare_mass). The function ensures that 
    the input value for bare mass is a valid floating-point number and then 
    performs the calculation with high precision. The resulting kappa value is 
    printed to the console with at least one decimal place, omitting unnecessary
    trailing zeros.

    Parameters:
    bare_mass (float) - A floating-point value representing the "bare mass"
    used in calculating the kappa value. This value should be positive,
    finite, and expressed as a valid float.

    Return Value:
    On success, the function prints the calculated kappa value to the console 
    with up to 16 decimal places, ensuring at least one decimal place. 
    On failure, if the input "bare_mass" is invalid (i.e., not a float), the 
    function outputs an error message and terminates with a return code of 1.

    Usage Example:
    calculate_kappa_value_from_bare_mass 1.5
    # Expected output: 0.0833333333333333

    Additional Notes:
    - The function uses `awk` to perform the high-precision calculation and 
        also to trim any trailing zeros in the decimal output. If `bare_mass` 
        is not a valid float, the function uses `termination_output` to display 
        an error message and return a failure code.
    - By using a precision of 20 decimal places in the `awk` calculation, the 
        function ensures high accuracy, even for values of `bare_mass` that 
        might require precision to avoid rounding issues.
    '

    local bare_mass="$1"
    if ! is_float "$bare_mass"; then
        local error_message="Invalid bare mass value."
        termination_output "${error_message}"
        return 1
    fi

    # Perform the calculation with high precision using `awk`
    local kappa_value=$(awk -v bare_mass="$bare_mass" \
                            'BEGIN { printf "%.20f", 0.5 / (4 + bare_mass) }')

    # Print kappa_value value to console, ensuring at least one decimal place
    printf "%.16f\n" "$kappa_value" \
        | awk '{
            sub(/\.?0+$/, "", $0)  # Remove unnecessary trailing zeros
            if ($0 !~ /\./) $0 = $0 ".0"  # Add ".0" if result is an integer
            print
        }'
}


calculate_bare_mass_from_kappa_value() {
    : '
    Function: calculate_bare_mass_from_kappa_value

    Description: This function calculates the "bare mass" value from a given
    "kappa" value using the formula: bare_mass = (0.5 / kappa) - 4. It first
    verifies that the input is a valid floating-point number, then performs
    the calculation with high precision, and finally outputs the result to the
    console with trailing zeros in the decimal part removed.

    Parameters: kappa_value (float) - A floating-point value representing the
    "kappa" used to calculate the corresponding bare mass value. This value 
    should be positive, finite, and expressed as a valid float.

    Return Value: On success, the function prints the calculated bare mass
    value to the console with at least one decimal place, omitting unnecessary
    trailing zeros. On failure, if the input "kappa_value" is invalid (i.e.,
    not a float), the function outputs an error message and terminates with a
    return code of 1.

    Usage Example: calculate_bare_mass_from_kappa_value 0.125
    # Expected output: 0.0833333333333333

    Additional Notes:
    - The function uses `awk` to perform the calculation with 20 decimal
        places for high precision and also uses `awk` to trim any trailing
        zeros in the output. If `kappa_value` is not a valid float, the
        function uses `termination_output` to display an error message and
        return a failure code.
    - By applying a precision of 20 decimal places, the function ensures
        accurate results, particularly useful for `kappa_value` inputs that
        may require precision to prevent rounding errors.
    '

    local kappa_value="$1"
    if ! is_float "$kappa_value"; then
        local error_message="Invalid kappa value."
        termination_output "${error_message}"
        return 1
    fi

    # Perform the calculation with high precision using `awk`
    local bare_mass=$(awk -v kappa_value="$kappa_value" \
                            'BEGIN { printf "%.20f", 0.5 / kappa_value - 4.0 }')

    # Print bare_mass value to the console, ensuring at least one decimal place
    printf "%.16f\n" "$bare_mass" \
        | awk '{
            sub(/\.?0+$/, "", $0)  # Remove unnecessary trailing zeros
            if ($0 !~ /\./) $0 = $0 ".0"  # Add ".0" if result is an integer
            print
        }'
}

# TODO: Potential improvement: identify the common part among the configuration
# files and define the label as the different part
extract_configuration_label_from_file() {
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
        local error_message="No dot found in the file path '$file_full_path'."
        termination_output "${error_message}"
        return 1
    fi

    # Extract the configuration label (substring after the last dot)
    local configuration_label="${file_full_path##*.}"
    
    echo "$configuration_label"
}


match_configuration_label_to_file() {
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

    # TODO: Accept "GAUGE_LINKS_CONFIGURATIONS_DIRECTORY" as input for
    # unit-testing purposes

    # Find files that end with the specified suffix in the global directory
    local files=($(find "$GAUGE_LINKS_CONFIGURATIONS_DIRECTORY" -type f -name \
                                                    "*$configuration_label"))

    # Check the number of files found
    if [ ${#files[@]} -eq 0 ]; then
        echo "No configuration file ending with '$configuration_label'"\
        "found."
        return 1
    elif [ ${#files[@]} -gt 1 ]; then
        echo "More than one configuration file ending with"\
        "'$configuration_label' found:"
        for file in "${files[@]}"; do
            echo "$file"
        done
        return 1
    else
        echo "${files[0]}"
    fi

    return 0
}

# TODO: How about validating input?
calculate_number_of_tasks_from_mpi_geometry() {
:   '
    Function: calculate_number_of_tasks_from_mpi_geometry

    Description: This function calculates the total number of tasks for an MPI
    (Message Passing Interface) run based on a given geometry string. The
    geometry is specified in the format "nX,nY,nZ", where nX, nY, and nZ
    represent the number of processes in the X, Y, and Z directions,
    respectively. The function multiplies these values to compute the total
    number of tasks.

    Parameters: mpi_geometry_string (string) - A comma-separated string
    specifying the MPI geometry dimensions in the form "nX,nY,nZ". Each
    dimension must be a positive integer.

    Return Value: On success, the function outputs the total number of tasks,
      calculated as the product of the nX, nY, and nZ values from the input
      string. This value is printed to the console as an integer. On failure
      (e.g., if the input format is incorrect or if non-integer values are
      provided), the function will not produce a valid output.

    Usage Example: calculate_number_of_tasks_from_mpi_geometry "4,2,3"
      # Expected output: 24

    Additional Notes:
      - The function uses the `IFS` (Internal Field Separator) to split the
        input string by commas, extracting the individual dimensions into
        separate variables nX, nY, and nZ. It then calculates the product of
        these variables.
      - To ensure robustness, consider validating the input format and
        checking that each extracted value is a positive integer before
        performing the multiplication.
      - This function assumes valid input in the "nX,nY,nZ" format; any
        deviation may lead to incorrect results or errors during execution.
'

  local mpi_geometry_string=$1

  # Extract the numbers from the string
  IFS=',' read -r nX nY nZ <<< "$mpi_geometry_string"

  local product=$((nX * nY * nZ))

  echo $product
}

# TODO: How about validating input?
extract_lattice_dimensions_label_with_value() {
:   '
    Function: extract_lattice_dimensions_label_with_value
    
    Description: This function generates a label representing the lattice
    dimensions of a system based on provided temporal and spatial dimensions.
    The label is output in the form
    "T{temporal_dimension}L{spatial_dimension}", where "T" indicates the
    temporal dimension and "L" indicates the spatial dimension. This
    standardized format can be used for labeling files, directories, or other
    outputs associated with the specified lattice dimensions.
    
    Parameters: temporal_dimension (integer or string) - The temporal
    dimension of the lattice. spatial_dimension (integer or string) - The
    spatial dimension of the lattice. Only the first spatial dimension
    argument is used; additional arguments are ignored, as they are assumed to
    match this value by definition.
    
    Return Value: Outputs a formatted string
      "T{temporal_dimension}L{spatial_dimension}" to the console.
    
    Usage Example: extract_lattice_dimensions_label_with_value 32 16
      # Expected output: "T32L16"
    
    Additional Notes:
      - This function does not validate the inputs. It assumes that valid
        temporal and spatial dimensions are provided.
      - If the function is used for labeling, ensure the input dimensions
        align with the intended lattice representation for clarity and
        accuracy.
      - Additional spatial dimensions passed as arguments are ignored.
'

    local temporal_dimension="$1"
    local spatial_dimension="$2"
    # Ignore the rest of the argument, they are identical to $2 by definition

    # Output the string in a form "T${temporal_dimension}L${spatial_dimension}"
    echo "T${temporal_dimension}L${spatial_dimension}"
}
