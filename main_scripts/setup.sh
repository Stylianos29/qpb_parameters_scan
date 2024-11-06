#!/bin/bash


###############################################################################
# main_scripts/setup.sh - Script for setting up qpb_parameters_scan
#
# This script automates the setup of qpb_parameters_scan by copying essential
# scripts and input files to a specified destination directory. It ensures that
# all required files are present, appropriately modified, and placed in a newly
# created dedicated directory inside the destination.
#
# Key functions of this script:
#   - Validates command-line arguments and creates necessary directories.
#   - Copies and modifies critical files for parameter scans.
#   - Appends warnings to auto-generated scripts to indicate they are read-only.
#   - Logs all actions and outputs any errors if steps fail.
#
# Files copied include:
#   1. "scan.sh" - Main script for cluster jobs for various
#      parameters values, with a read-only warning appended.
#   2. "input.txt" - Input file, with its paths and modifiable parameters
#      automatically updated.
#   3. "_params.ini_" - An empty parameters file selected based on the
#      destination path.
#   4. "update.sh" - Script for updating the copied setup files, with its path
#      variable auto-filled and a read-only warning appended.
#
# Usage: ./setup.sh -p <destination_directory> [-u|--usage]
#
# Notes:
#   - The destination directory must be provided as an argument.
#   - The appropriate "_params.ini_" file is chosen based on the destination
#     path.
#   - Warnings are appended to indicate which scripts are intended as read-only.
#   - All actions are logged, and the script exits if any errors occur.
#
###############################################################################


# CONSTRUCT LOG FILE

# NOTE: The log file must be in the same directory as the currently running
# script. Since "setup.sh" may be executed directly or sourced from another
# script, the actual current script's full path is checked to construct the log
# file path correctly.

# Use "setup.sh"'s path as the CURRENT_SCRIPT_FULL_PATH value unless it's
# already set by another script running "setup.sh"
if [ -z "$CURRENT_SCRIPT_FULL_PATH" ]; then
    CURRENT_SCRIPT_FULL_PATH=$(realpath "$0")
fi
# Extract the current script name from its full path
CURRENT_SCRIPT_NAME="$(basename "$CURRENT_SCRIPT_FULL_PATH")"
# Replace ".sh" with "_log.txt" to create the log file name
LOG_FILE_NAME=$(echo "$CURRENT_SCRIPT_NAME" | sed 's/\.sh$/_log.txt/')
export LOG_FILE_PATH="$(dirname "$CURRENT_SCRIPT_FULL_PATH")/${LOG_FILE_NAME}"

# Create or override a log file. Initiate logging
echo -e "\t\t"$(echo "$CURRENT_SCRIPT_NAME" | tr '[:lower:]' '[:upper:]') \
                "SCRIPT EXECUTION INITIATED\n" > "$LOG_FILE_PATH"

# Script termination message to be used for finalizing logging
export SCRIPT_TERMINATION_MESSAGE="\n\t\t"$(echo "$CURRENT_SCRIPT_NAME" \
                    | tr '[:lower:]' '[:upper:]')" SCRIPT EXECUTION TERMINATED"

# SOURCE LIBRARY SCRIPTS

# Extract full path of "qpb_parameters_scan/main_scripts" directory containing
# "setup.sh". "${BASH_SOURCE[0]}" ensures the correct path is obtained even when
# script is sourced.
MAIN_SCRIPTS_DIRECTORY_FULL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all custom functions scripts from "qpb_parameters_scan/library"
# using a loop avoiding this way name-specific sourcing and thus potential typos
sourced_scripts_count=0 # Initialize a counter for sourced files
for custom_functions_script in $(realpath \
                        "$MAIN_SCRIPTS_DIRECTORY_FULL_PATH/../library"/*.sh);
do
    # Check if the current file in the loop is a regular file
    if [ -f "$custom_functions_script" ]; then
        source "$custom_functions_script"
        ((sourced_scripts_count++)) # Increment counter for each sourced script
    fi
done
# Check whether any files were sourced
if [ $sourced_scripts_count -gt 0 ]; then
    log "INFO" "A total of $sourced_scripts_count custom functions scripts "\
"from qpb_parameters_scan/library were successfully sourced."
else
    ERROR_MESSAGE="No custom functions scripts were sourced at all."
    echo "ERROR: "$ERROR_MESSAGE
    echo "Exiting..."
    # Log error explicitly since "log()" function couldn't be sourced
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] : $ERROR_MESSAGE" \
                                                            >> "$LOG_FILE_PATH"
    echo -e $SCRIPT_TERMINATION_MESSAGE >> "$LOG_FILE_PATH"
    exit 1
fi

# COMMAND-LINE ARGUMENTS CHECKS

# Check if no arguments were passed
if [[ "$#" -eq 0 ]]; then
    # Print error message and exit if no arguments were passed at all
    ERROR_MESSAGE="No command-line arguments were provided at all."
    termination_output "$ERROR_MESSAGE"
    setup_script_usage
    exit 1
fi
# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        # Match the -p or --path option, expecting a directory argument after it
        -p|--path)
            if [[ -n $2 && $2 != -* ]]; then
                DESTINATION_DIRECTORY_PATH=$2
                shift  # Skip the next argument as it's the path
            else
                ERROR_MESSAGE="Argument for $1 is missing."
                termination_output "$ERROR_MESSAGE"
                setup_script_usage
                exit 1
            fi
            ;;
        # Match the -u or --usage option to display usage
        -u|--usage)
            log "WARNING" "Usage option invoked thus no further action allowed."
            echo -e $SCRIPT_TERMINATION_MESSAGE >> "$LOG_FILE_PATH"
            setup_script_usage  # Call the usage function to display help
            exit 1
            ;;
        # Handle unknown options
        -*)
            ERROR_MESSAGE="Unknown option: $1."
            termination_output "$ERROR_MESSAGE"
            setup_script_usage
            exit 1
            ;;
        # Break the loop if no more options are found
        *)
            break
            ;;
    esac
    shift  # Move to the next argument
done

# SET DESTINATION SETUP DIRECTORY

# Check if passed destination directory exists. If not, exit with error message
ERROR_MESSAGE="Destination directory does not exist. Please check again."
check_if_directory_exists "${DESTINATION_DIRECTORY_PATH}" "$ERROR_MESSAGE" \
                                                                    || exit 1
log "INFO" "Destination directory path is: '"$DESTINATION_DIRECTORY_PATH"'."

# NOTE: Setup files will be copied to a setup directory within the destination
# directory. If "setup.sh" runs directly, "qpb_parameters_scan_files" directory
# will be created (if absent) inside the destination directory for copying the
# files. If "setup.sh" is sourced by another script, the files will be copied to
# that script's parent directory.
if [[ "$CURRENT_SCRIPT_NAME" == "setup.sh" ]]; then
    DESTINATION_SETUP_DIRECTORY_PATH="${DESTINATION_DIRECTORY_PATH}"\
"/qpb_parameters_scan_files" # Default setup directory
    if [ ! -d "$DESTINATION_SETUP_DIRECTORY_PATH" ]; then
        mkdir -p "$DESTINATION_SETUP_DIRECTORY_PATH"
        log "INFO" "'qpb_parameters_scan_files' directory created inside "\
        "destination directory."
    fi
else
    DESTINATION_SETUP_DIRECTORY_PATH="$(dirname "$CURRENT_SCRIPT_FULL_PATH")"
fi
DESTINATION_SETUP_DIRECTORY_NAME=$(basename "$DESTINATION_SETUP_DIRECTORY_PATH")
log "INFO" "All files will be copied inside the "\
"'$DESTINATION_SETUP_DIRECTORY_NAME' directory."

# CONSTRUCT SETUP FILES LIST

SETUP_FILES_LIST=("input.txt" "input_file_instructions.md" "scan.sh"\
                                                "usage.sh" "update.sh" "run.sh")

# NOTE: An empty parameters file, determined by the destination directory
# path, must also be included in the list of setup files to be copied.

# Extract the overlap operator method from the destination directory path
overlap_operator_method=$(extract_overlap_operator_method \
                                                "$DESTINATION_DIRECTORY_PATH")
# Prefix for all empty parameters files is based on the overlap operator method
empty_parameters_filename="${overlap_operator_method}_"
# Check if the relative path (starting from "mainprogs") contains "invert"
if [[ "${DESTINATION_DIRECTORY_PATH#*mainprogs/}" == *"invert"* ]]; then
        # If "invert" is found, add "invert_" to the filename prefix
        empty_parameters_filename+="invert_"
fi
# Finalize the selected empty parameters filename by adding the common suffix
empty_parameters_filename+="empty_parameters_file.ini"
# Construct then the path of the selected empty parameters file to be copied
empty_parameters_file_path="./parameters_files/${empty_parameters_filename}"
# Check if file exists as a safeguard
error_message="Selected empty parameters file: $empty_parameters_file_path "
error_message+="cannot be located."
check_if_file_exists "$empty_parameters_file_path" "$error_message" || exit 1

# Add selected empty parameters file path to setup files list
SETUP_FILES_LIST+=("$empty_parameters_file_path")

# COPY ORIGINAL SETUP FILES TO DESTINATION SETUP DIRECTORY

for original_setup_file in "${SETUP_FILES_LIST[@]}"; do
    original_setup_file_full_path=$(realpath \
                "${MAIN_SCRIPTS_DIRECTORY_FULL_PATH}/${original_setup_file}")
    # Check if file exists and then copy it to destination setup directory
    error_message="Original $original_setup_file file cannot be located."
    check_if_file_exists "$original_setup_file_full_path" "$error_message" \
                                                                    || exit 1
    error_message="Copying original '"$original_setup_file"' file failed."
    copy_file_and_check "$original_setup_file_full_path" \
                "$DESTINATION_SETUP_DIRECTORY_PATH" "$error_message" || exit 1
    log "INFO" "Original '$original_setup_file' file was copied successfully."
    # Set executable permission if the file is a script
    if [[ "$original_setup_file" == *.sh ]]; then
        chmod +x "${DESTINATION_SETUP_DIRECTORY_PATH}/${original_setup_file}"
        log "INFO" "Executable permission set for '$original_setup_file'."
    fi
done

# MODIFY COPIED SETUP FILES

# Insert warning in copied BASH scripts to indicate they are read-only-intended
WARNING_MESSAGE=\
"\n\n#======================================================================
\n# This script is auto-generated and should not be modified manually.
\n# ====================================================================="
target_line="#!/bin/bash"
for copied_setup_file in "${SETUP_FILES_LIST[@]}"; do
    if [[ "$copied_setup_file" == *.sh && "$copied_setup_file" != "run.sh" ]];
    then # Ignore "run.sh" which is supposed to be modified
        copied_setup_file_full_path="${DESTINATION_SETUP_DIRECTORY_PATH}/"
        copied_setup_file_full_path+="${copied_setup_file}"
        insert_message "$copied_setup_file_full_path" "$target_line" \
                                                "$WARNING_MESSAGE" || exit 1 
        log "INFO" "Read-only warning appended to '$copied_setup_file'."
    fi
done

# And some more specific modifications on individual files
# TODO: DRY line replacement in copied files using custom function

# 1. "scan.sh" script
COPIED_SETUP_FILE_NAME="scan.sh"
copied_setup_file_full_path="${DESTINATION_SETUP_DIRECTORY_PATH}/"\
"$COPIED_SETUP_FILE_NAME"
# Line "QPB_PARAMETERS_SCAN_PROJECT_DIRECTORY_FULL_PATH=" is auto-filled
sed -i "s|^\(QPB_PARAMETERS_SCAN_PROJECT_DIRECTORY_FULL_PATH=\).*|\1\"$(dirname\
 $MAIN_SCRIPTS_DIRECTORY_FULL_PATH)\"|" "$copied_setup_file_full_path" || { 
    error_message="Could not modify copied '$COPIED_SETUP_FILE_NAME' file.";
    termination_output "$error_message";
    exit 1;
    }
log "INFO" "Copied '$COPIED_SETUP_FILE_NAME' file has been modified."

# 2. "input.txt" text file
COPIED_SETUP_FILE_NAME="input.txt"
copied_setup_file_full_path="${DESTINATION_SETUP_DIRECTORY_PATH}/"\
"$COPIED_SETUP_FILE_NAME"
# A list of all the modifiable parameters along with their values is inserted in
# the copied "input.txt" file, split into two groups: "non-iterable parameters"
write_list_of_parameters_to_file NON_ITERABLE_PARAMETERS_NAMES_ARRAY \
"List of non-iterable parameters" "$copied_setup_file_full_path"
# And "iterable parameters", the latter chosen based on the overlap operator
# method and on whether the destination main program is an "invert" one
overlap_operator_method_label="${empty_parameters_filename%%\
'_empty_parameters_file.ini'}"
iterable_parameters_names_array="${ITERABLE_PARAMETERS_NAMES_DICTIONARY[\
"$overlap_operator_method_label"]}"
write_list_of_parameters_to_file $iterable_parameters_names_array \
"List of iterable parameters" "$copied_setup_file_full_path" || exit 1
# Remove the line "BINARY_SOLUTION_FILES_DIRECTORY=" if not in an invert program
if [[ ! "$overlap_operator_method_label" == *"invert"* ]]; then
    sed -i '/^BINARY_SOLUTION_FILES_DIRECTORY=/d' \
        "$copied_setup_file_full_path" || { 
    error_message="Could not modify copied '$COPIED_SETUP_FILE_NAME' file.";
    termination_output "$error_message";
    exit 1;
    }
fi
# Auto-populate the "MAIN_PROGRAM_EXECUTABLE=../" line with a guess on the main
# program's executable name, which is based on the destination directory name.
executable_name_guess=$(basename "$DESTINATION_DIRECTORY_PATH")
sed -i "/^MAIN_PROGRAM_EXECUTABLE=..*/ s|$|${executable_name_guess}|" \
                                        "$copied_setup_file_full_path" || { 
    error_message="Could not modify copied '$COPIED_SETUP_FILE_NAME' file.";
    termination_output "$error_message";
    exit 1;
    }
log "INFO" "Copied '$COPIED_SETUP_FILE_NAME' file has been modified."

# 3. Empty parameters file
copied_setup_file_full_path="${DESTINATION_SETUP_DIRECTORY_PATH}/"\
"$empty_parameters_filename"
# Rename copied empty parameters file to "_params.ini_"
mv $copied_setup_file_full_path \
        "${DESTINATION_SETUP_DIRECTORY_PATH}/_params.ini_" || { 
    error_message="Could not rename copied '$empty_parameters_filename' "\
    "file to '_params.ini_'.";
    termination_output "$error_message";
    exit 1;
    }
log "INFO" "Copied '$empty_parameters_filename' file has been renamed "\
"to '_params.ini_'."

# 4. "update.sh" script
COPIED_SETUP_FILE_NAME="update.sh"
copied_setup_file_full_path="${DESTINATION_SETUP_DIRECTORY_PATH}/"\
"$COPIED_SETUP_FILE_NAME"
# Line MAIN_SCRIPTS_DIRECTORY=... is auto-filled
sed -i \
    "s|^\(MAIN_SCRIPTS_DIRECTORY=\).*|\1\"$MAIN_SCRIPTS_DIRECTORY_FULL_PATH\"|"\
        "$copied_setup_file_full_path" || { 
    error_message="Could not modify copied '$COPIED_SETUP_FILE_NAME' "\
    "file.";
    termination_output "$error_message";
    exit 1;
    }
log "INFO" "Copied '$COPIED_SETUP_FILE_NAME' file has been modified."

# 5. "usage.sh" script
COPIED_SETUP_FILE_NAME="usage.sh"
copied_setup_file_full_path="${DESTINATION_SETUP_DIRECTORY_PATH}/"\
"$COPIED_SETUP_FILE_NAME"
# Line "QPB_PARAMETERS_SCAN_PROJECT_DIRECTORY_FULL_PATH=" is auto-filled
sed -i "s|^\(QPB_PARAMETERS_SCAN_PROJECT_DIRECTORY_FULL_PATH=\).*|\1\"$(dirname\
 $MAIN_SCRIPTS_DIRECTORY_FULL_PATH)\"|" "$copied_setup_file_full_path" || { 
    error_message="Could not modify copied '$COPIED_SETUP_FILE_NAME' file.";
    termination_output "$error_message";
    exit 1;
    }
log "INFO" "Copied '$COPIED_SETUP_FILE_NAME' file has been modified."

# SUCCESSFUL COMPLETION OUTPUT

log "INFO" "All setup files were copied and modified successfully!"

# Remove ".sh" extension and capitalize the first letter of the script name
script_name=$(echo "${CURRENT_SCRIPT_NAME%.sh}" \
| awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
# Construct the final message
final_message="${script_name} process complete!"
# Print the final message
echo "$final_message"

log "INFO" "${final_message}"

echo -e $SCRIPT_TERMINATION_MESSAGE >> "$LOG_FILE_PATH"

unset SCRIPT_TERMINATION_MESSAGE
unset LOG_FILE_PATH