#!/bin/bash


# TODO: Write description
######################################################################
# library/output.sh - Script for 
#
#
######################################################################


# MULTIPLE SOURCING GUARD

# Prevent multiple sourcing of this script by exiting if OUTPUT_SH_INCLUDED is
# already set. Otherwise, set OUTPUT_SH_INCLUDED to mark it as sourced.
[[ -n "${OUTPUT_SH_INCLUDED}" ]] && return
OUTPUT_SH_INCLUDED=1

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

setup_script_usage()
{
:   '
    Description: Displays usage information for the setup script and exits. 
    This function outlines the available options and their descriptions to 
    assist the user in running the script correctly.

    Parameters: 
    - None.

    Returns:
    - Prints the usage information.
    - Exits the script with a status code of 1 to indicate incorrect usage 
      or when the user explicitly requests usage information.

    Example Usage:
        # If the user runs the script without the required arguments
        setup_script_usage

    Notes:
    - This function is designed to be called when the user runs the setup.sh 
      script incorrectly or requests usage information with the `-u` or 
      `--usage` flag.
    '

    echo
    echo "Usage: $0 -p <directory> [--path <directory>] [-u|--usage]"
    echo "Options:"
    echo "  -p, --path   Specify the destination directory"
    echo "  -u, --usage  Display usage information"
}


print_list_of_parameters()
{
:   '
    Function: print_list_of_parameters
    Description: This function prints a list of parameters and their
    corresponding values from a given array. Optionally, it can print the list 
    with or without indices based on the "-noindices" option.

    Parameters:
    - parameter_names_array_name (string): The name of the array (passed as a 
      string) that contains the parameter names to be printed. The array name 
      is validated before being used as a reference.
    - options (string, optional): An optional argument, "-noindices", that when 
      included, suppresses printing indices and prints empty spaces instead.

    Returns: None
    Exits: Exits the script with status 1 if the provided array name is invalid.

    This function is useful for displaying parameters and their values, with 
    the option to format the output either with indices or without.

    Usage:
    print_list_of_parameters parameter_names_array_name [-noindices]

    Example:
    NON_ITERABLE_PARAMETERS_NAMES_ARRAY=("param1" "param2")
    ITERABLE_PARAMETERS_NAMES_ARRAY=("paramA" "paramB")

    # Example 1: Printing with indices
    print_list_of_parameters NON_ITERABLE_PARAMETERS_NAMES_ARRAY

    # Example 2: Printing without indices
    print_list_of_parameters ITERABLE_PARAMETERS_NAMES_ARRAY -noindices

    Sample Output:
    0  : param1=value1
    1  : param2=value2

    With "-noindices":
       : paramA=valueA
       : paramB=valueB

    Notes:
    - The function validates that the first argument is a valid array name
      before using it as a reference.
    - This function uses a loop to iterate through the provided array and prints 
      each parameter along with its value.
    - If the optional "-noindices" argument is provided, the function will print 
      empty spaces instead of indices.
    '
    
    local parameter_names_array_name=$1  # Store the first argument as a string
    if ! declare -p "$parameter_names_array_name" &>/dev/null; then
        echo "Error: Invalid list of parameters array name "\
                                        "'$parameter_names_array_name'."
        echo "Exiting..."
        exit 1
    fi
    # Use name reference after validation
    local -n parameter_names_array="$parameter_names_array_name"

    local noindices=false
    if [[ "$2" == "-noindices" ]]; then
        noindices=true
    fi

    local index=0
    for parameter_name in "${parameter_names_array[@]}"; do
        parameter_value="${!parameter_name}"
        if [ "$noindices" = true ]; then
            printf "# - %s=%s\n" "$parameter_name" "$parameter_value"
        else
            printf "# %2d : %s=%s\n" "$index" "$parameter_name" \
                                                            "$parameter_value"
        fi
        ((index++))
    done

    echo # Add new line
}


# TODO: Error handling
write_list_of_parameters_to_file()
{
:   '
    Function: write_list_of_parameters_to_file
    Description: Inserts the output of the print_list_of_parameters function 
    into a specified file below a given search line. The function captures 
    the formatted output of parameters and appends it to the file, allowing 
    for the customization of how parameters are printed based on the provided 
    options.

    Parameters:
    - parameter_names_array_name (string): The name of the array (passed as a 
      string) that contains the parameter names to be printed. This name is 
      validated before being used as a reference.
    - search_line (string): The line in the file below which the parameters 
      output will be inserted.
    - file (string): The path to the file where the parameters will be written.
    - flag (string, optional): An optional argument that can include 
      "-noindices". If provided, this flag suppresses printing of indices and 
      prints empty spaces instead.

    Returns: None
    Exits: Exits the script with status 1 if the provided array name is invalid.

    This function is useful for dynamically updating files. It ensures that the 
    array name is valid before attempting to print the parameters and utilizes 
    a temporary file to avoid issues with modifying the file while reading from 
    it.

    Usage Example:
        write_list_of_parameters_to_file NON_ITERABLE_PARAMETERS_NAMES_ARRAY 
        "List of parameters:" "config.txt" "-noindices"

    Notes:
    - The function validates that the first argument is a valid array name 
      before using it as a reference.
    - A temporary file is created to store the modified content before moving 
      it back to the original file to ensure data integrity during the update 
      process.
    - This function relies on the print_list_of_parameters function to format 
      the parameter names and their corresponding values.
    '
    
    local parameter_names_array_name=$1  # Store the first argument as a string
    local search_line="$2"               # Line to search for in the file
    local file="$3"                      # File where the output will be written
    local flag="$4"                      # Optional "-noindices" flag

    # Step 0: Validate the array name before using it as a reference
    if ! declare -p "$parameter_names_array_name" &>/dev/null; then
        echo "Error: Invalid list of parameters array name "\
                                        "'$parameter_names_array_name'."
        echo "Exiting..."
        return 1
    fi
  
    # Use name reference after validation
    local -n parameter_names_array="$parameter_names_array_name"  

    # Step 1: Capture the output of the print_list_of_parameters function
    local parameters_output=$(print_list_of_parameters \
                                          "$parameter_names_array_name" "$flag")

    # Step 2: Create a temporary file for the modified content
    local tmp_file=$(mktemp)

    # Step 3: Use sed to insert the parameters_output below the search_line
    sed "/${search_line}/r /dev/stdin" "$file" > "$tmp_file" \
                                                        <<< "$parameters_output"

    # Step 4: Move the temporary file back to the original file
    mv "$tmp_file" "$file"
}


# TODO: Work out the error messages more
insert_message() {
    : '
    Description: Inserts a specified warning message into a script file after a specified line.
    ...
    '

    local script_file="$1"
    local target_line="$2"
    shift 2
    local warning_message="$*"

    # Check if the script file exists and is writable
    if [[ ! -f "$script_file" || ! -w "$script_file" ]]; then
        echo "Error: Specified script file does not exist or is not writable."
        return 1
    fi

    # Store original file permissions
    local original_permissions
    original_permissions=$(stat -c %a "$script_file")

    # Create a temporary file to store the modified content
    local temporary_file
    temporary_file=$(mktemp) || { echo "Error: Could not create a temporary file."; return 1; }
    
    # Process the file, inserting the warning message after the target line
    while IFS= read -r line; do
        echo "$line" >> "$temporary_file" || { echo "Error: Could not write to temporary file."; return 1; }
        
        if [[ "$line" == *"$target_line"* ]]; then
            echo -e "$warning_message" >> "$temporary_file" || { echo "Error: Could not write warning message."; return 1; }
        fi
    done < "$script_file"
    
    # Move the modified content back to the original script file and restore permissions
    if mv "$temporary_file" "$script_file"; then
        chmod "$original_permissions" "$script_file" || { echo "Error: Could not restore original permissions."; return 1; }
        return 0
    else
        echo "Error: Failed to move temporary file to original script location."
        return 1
    fi
}


insert_message_old()
{
:   '
    Description: Inserts a specified warning message into a script file after 
    a specified line.

    Parameters:
    - script_file (string): The full path to the script file where the 
      warning message will be inserted.
    - target_line (string): The line after which the warning message should 
      be inserted.
    - warning_message (string): The warning message to be inserted into the 
      script.

    Returns: None

    This function reads the original script file line by line and inserts the 
    warning message immediately after the line that contains the specified 
    target line as a substring. It creates a temporary file to store the 
    modified content and then moves this temporary file back to the original 
    script file to make the changes effective.

    Usage Example:
      # Define the script file path
      script_file_path="/path/to/script.sh"
  
      # Define target line after which the warning message should be inserted
      target_line="#!/bin/bash -l"
  
      # Define the multi-line warning message
      WARNING_MESSAGE=$'# This script is auto-generated.\n'
  
      # Call the function to append the warning message, quoting the target line
      insert_message "$script_file_path" "$target_line" "$WARNING_MESSAGE"
    
    Notes:
    - This function assumes that the target line is unique within the script 
      file. If the target line appears multiple times, the warning message 
      will be inserted after each occurrence.
    - The function uses `shift` to handle multi-line strings and spaces in the 
      `target_line` argument, ensuring the entire `warning_message` is treated 
      as a single argument.
    - The `-e` option in `echo` enables interpretation of backslash escapes, 
      ensuring that newline characters in the `warning_message` are processed 
      correctly.
    '

    local script_file="$1"
    local target_line="$2"
    shift 2
    local warning_message="$*"

    # Create a temporary file to store the modified content
    local temporary_file=$(mktemp)
    
    # Read the original script file line by line
    while IFS= read -r line; do
        # Insert the warning message right after the target line
        if [[ "$line" == *"$target_line"* ]]; then
            echo "$line" >> "$temporary_file"
            echo -e "$warning_message" >> "$temporary_file"
        else
            echo "$line" >> "$temporary_file"
        fi
    done < "$script_file"
    
    # Move the modified content back to the original script file
    mv "$temporary_file" "$script_file"
}


replace_string_in_file()
{
    local file_path="$1"
    local target_string="$2"
    local replacement_string="$3"
    
    # Perform the replacement using sed
    sed -i "s@${target_string}@${replacement_string}@g" "$file_path"
    if [ $? -ne 0 ]; then
        local error_message="Could not replace '${target_string}' string "
        error_message+="in '${file_path}'."
        termination_output "$error_message" "$SCRIPT_TERMINATION_MESSAGE"
        return 1  # Return 1 for failure
    fi

    return 0  # Return 0 for success
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


print_lattice_dimensions() {
    local temporal_dimension="$1"
    local spatial_dimension="$2"

    # Output the string in the form "T${temporal_dimension}L${spatial_dimension}"
    echo "T${temporal_dimension}L${spatial_dimension}"
}


print_array_limited() {
    local -n array=$1  # Use nameref to pass array by name
    local limit=${2:-10}  # Max number of elements to show, default is 10

    # If the array length is within the limit, print all elements
    if [ "${#array[@]}" -le "$limit" ]; then
        echo "${array[@]}"
    else
        # Calculate the split points
        local half_limit=$((limit / 2))
        
        # Print first half, then '...', then last half
        echo "${array[@]:0:half_limit} ... ${array[@]: -half_limit}"
    fi
}


fill_in_parameter_file()
{

  for constant_parameter in "${constant_parameters_list[@]}"; do
    # Get the value of the replacement variable
    value="${!constant_parameter}"

    # Use sed to perform the replacement
    sed -i "s@_${constant_parameter}_@${value}@g" "$EMPTY_PARAMETERS_TEMPLATE_FILE"
  done

}
