#!/bin/bash -l


CURRENT_SCRIPT_FULL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_SCRIPT_FULL_PATH/constants.sh"


check_if_directory_exists()
{
:   '
    Function: check_if_directory_exists
    Description: Checks if a directory exists at the given path and prints an 
    error message if it does not exist.
    Parameters:
      1. directory_path (string): The full path to the directory to check.
      2. error_message (string): The error message to print if the directory 
      does not exist.
    Returns: None
    Exits: Exits the script with status 1 if the directory does not exist.

    This function checks whether a directory exists at the specified path. If 
    the directory does not exist, it prints a user-provided error message and 
    exits the script with a status code of 1. This is useful for ensuring that 
    required directories are present before proceeding with further script 
    execution.

    Usage example:
        # Define the directory path and error message
        destination_directory="/path/to/destination_directory"
        error_message="Invalid destination directory path. Check again."
        
        # Call the function to check if the directory exists
        check_if_directory_exists "$destination_directory" "$error_message"
    '

    local directory_path="$1"
    local error_message="$2"

    if [ ! -d "$directory_path" ]; then
        echo "$error_message"
        echo "Exiting..."
        exit 1
    fi
}


check_if_file_exists()
{
:   '
    Function: check_if_file_exists
    Description: Checks if a file exists at the given path and prints an error 
    message if it does not exist.
    Parameters:
      1. file_path (string): The full path to the file to check.
      2. error_message (string): The error message to print if the file does 
      not exist.
    Returns: None
    Exits: Exits the script with status 1 if the file does not exist.

    This function checks whether a file exists at the specified path. If the 
    file does not exist, it prints a user-provided error message and exits the 
    script with a status code of 1. This is useful for ensuring that required 
    files are present before proceeding with further script execution.

    Usage example:
        # Define the file path and error message
        empty_parameters_file="/path/to/empty_parameters_file"
        error_message="Invalid empty parameters file path. Check again."
        
        # Call the function to check if the file exists
        check_if_file_exists "$empty_parameters_file" "$error_message"
    '

    local file_path="$1"
    local error_message="$2"

    if [ ! -f "$file_path" ]; then
        echo "$error_message"
        echo "Exiting..."
        exit 1
    fi
}


insert_message()
{
:   '
    insert_message
    
    Function: insert_message
    Description: This function inserts a specified warning message into a script
     file after a specified line.
    Parameters:
      1. script_file (string): The full path to the script file where the 
      warning message will be inserted.
      2. target_line (string): The line after which the warning message should 
      be inserted.
      3. warning_message (string): The warning message to be inserted into the 
      script.
    Returns: None
    
    This function reads the original script file line by line and inserts the 
    warning message right after the line that contains the specified target 
    line as a substring. It creates a temporary file to store the modified 
    content and then moves this temporary file back to the original script file 
    to make the changes effective.
    
    Usage example:
        # Define the script file path
        script_file_path="/path/to/script.sh"
    
        # Define the partial target line after which the warning message should 
        be inserted
        target_line="#!/bin/bash -l"
    
        # Define the multi-line warning message using the $'\n' notation
        WARNING_MESSAGE=\
    "#======================================================================
    \n# This script is auto-generated and should not be modified manually.
    \n# ====================================================================="
    
        # Call the function to append the warning message, quoting the target 
        line
        insert_message "$script_file_path" "$target_line" 
        "$WARNING_MESSAGE"
    
    Note:
        This function assumes that the target line is unique within the script 
        file. If the target line appears multiple times, the warning message 
        will be inserted after each occurrence.
    
        The function uses the `shift` command to properly handle multi-line 
        strings and spaces in the `target_line`
        argument, ensuring that the entire `warning_message` is treated as a 
        single argument.
    
        The `-e` option in `echo` enables the interpretation of backslash 
        escapes, ensuring that the newline characters in the `warning_message` 
        are correctly processed and printed.
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
        # if [[ $line == "#!/bin/bash -l" ]]; then
        if [[ "$line" == *"$target_line"* ]]; then
            echo "$line" >> "$temporary_file"
            # echo >> "$temporary_file"  # Add an empty line
            # echo >> "$temporary_file"  # Add an empty line
            echo -e "$warning_message" >> "$temporary_file"
        else
            echo "$line" >> "$temporary_file"
        fi
    done < "$script_file"
    
    # Move the modified content back to the original script file
    mv "$temporary_file" "$script_file"
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


# TODO: This function needs to be retired
check_directory_path()
{
:   '
    Function to check if a given directory path exists and is a directory
    Usage: check_directory_path <directory_full_path>
    Arguments: directory_full_path: The full path of the directory to check.
    Output:
        - Echoes 0 if the path exists and is a directory.
        - Echoes 1 and exits the script if the path does not exist or is not
        a directory.
    Example:
        check_directory_path "/path/to/directory"
        Output:
            - If the directory exists and is a directory, it will echo 0.
            - If the directory does not exist or is not a directory, it will 
            echo 1 and exit the script.
    Notes:
        - The function uses the `-e` test to check if the path exists.
        - The function uses the `-d` test to check if the path is a directory.
        - If the path does not exist or is not a directory, the function echoes
         1 and exits with status 1.
        - If the path exists and is a directory, the function echoes 0.
    '

    local directory_full_path="$1"

    # Check if the path exists
    if [ ! -e "$directory_full_path" ]; then
        echo 1
        exit 1
    fi

    # If it exists, then check if it is a directory
    if [ ! -d "$directory_full_path" ]; then
        echo 1
        exit 1
    fi

    # If both checks pass, return success
    echo 0
}


modify_decimal_format()
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
