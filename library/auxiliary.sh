#!/bin/bash -l


######################################################################
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
######################################################################


CURRENT_SCRIPT_FULL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_SCRIPT_FULL_PATH/constants.sh"


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

    echo "Usage: $0 -p <directory> [--path <directory>] [-u|--usage]"
    echo "Options:"
    echo "  -p, --path   Specify the destination directory"
    echo "  -u, --usage  Display usage information"
    
    exit 1
}


log()
{
:   '
    Description: This function logs messages with a specified log level to a 
    designated log file. It wraps long messages at 80 characters for improved 
    readability and includes a timestamp in the log entry.

    Parameters:
    - log_level (string): The severity level of the log (e.g., INFO, ERROR).
    - message (string): The message to be logged.

    Returns:
    - Logs the message to the specified log file if the log file path is set.
    - If the log file path is not set, it prints an error message and exits 
      the script with a status code of 1.

    Example Usage:
      log "INFO" "This is a log message that will be recorded in the log file."

    Notes:
    - The log file path should be defined globally as LOG_FILE_PATH before 
      calling this function.
    - If the log file path is not set, the function will terminate the script 
      to prevent logging failures.
    '
    
    local log_level="$1"
    local message="$2"

    # Log only if the global variable of the log file path has been set properly
    if [ ! -z "$LOG_FILE_PATH" ]; then
        # Use fold to wrap the message at 80 characters
        wrapped_message=$(echo -e \
           "$(date '+%Y-%m-%d %H:%M:%S') [$log_level] : $message" | fold -sw 80)
        echo -e "$wrapped_message" >> "$LOG_FILE_PATH"
    else
        # Otherwise exit with error
        echo "No current script's log file path has been provided."
        echo "Exiting..."
        exit 1
    fi
}


termination_output()
{
:   '
    Description: This function handles error reporting and script termination 
    procedures. It prints an error message to the console, logs the error using 
    the log function, and appends a termination message to the log file.

    Parameters:
    - error_message (string): The error message to be displayed and logged.
    - script_termination_message (string): The message to be appended to the 
      log file indicating the reason for script termination.

    Returns:
    - Prints the error message to standard output.
    - Logs the error message using the log function.
    - Appends the script termination message to the log file specified by 
      LOG_FILE_PATH.

    Example Usage:
        termination_output "File not found" "\n\t\tSCRIPT EXECUTION TERMINATED"

    Notes:
    - The function expects that the log file path (LOG_FILE_PATH) has been 
      set properly before it is called.
    - This function is designed to be called when a critical error occurs that 
      requires stopping the script execution.
    '
    
    local error_message="$1"
    local script_termination_message="$2"

    echo "Error: $error_message"
    log "ERROR" "$error_message"
    echo -e "$script_termination_message" >> "$LOG_FILE_PATH"
}


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

    # Check if the 3rd argument was passed
    if [ -z "$script_termination_message" ]; then
        # If no 3rd argument, check if global variable is not empty
        if [ -n "$SCRIPT_TERMINATION_MESSAGE" ]; then
            script_termination_message="$SCRIPT_TERMINATION_MESSAGE"
        else
            # If global variable is empty, assign default message
            script_termination_message="\n\t\t SCRIPT EXECUTION TERMINATED"
        fi
    fi

    if [ ! -d "$directory_path" ]; then
        termination_output "${error_message}" "${script_termination_message}"
        echo "Exiting..."
        exit 1
    fi
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

    # Check if the 3rd argument was passed
    if [ -z "$script_termination_message" ]; then
        # If no 3rd argument, check if global variable is not empty
        if [ -n "$SCRIPT_TERMINATION_MESSAGE" ]; then
            script_termination_message="$SCRIPT_TERMINATION_MESSAGE"
        else
            # If global variable is empty, assign default message
            script_termination_message="\n\t\t SCRIPT EXECUTION TERMINATED"
        fi
    fi

    # Check if the file exists
    if [ ! -f "$file_path" ]; then
        termination_output "${error_message}" "${script_termination_message}"
        echo "Exiting..."
        exit 1
    fi
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
        exit 1
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


insert_message()
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
