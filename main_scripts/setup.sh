#!/bin/bash


######################################################################
# main_scripts/setup.sh - Script for setting up the multiple runs project
#
# This script automates the setup process for the multiple runs project by 
# copying necessary scripts and configuration files to a specified destination 
# directory. The destination path is set inside the script. The script verifies 
# the existence of the destination directory and ensures that all required files
# are present and correctly configured.
#
# Author: Stylianos Gregoriou
# Date last modified: 16th June 2024
#
# Usage: 
#   ./setup.sh
#
# Input:
#   The script takes the destination directory path as an input defined
#   inside the script.
#
# Output:
#   The script copies the following files to the destination directory:
#   1. multiple_runs.sh - Main script for running multiple jobs.
#   2. input.txt - Configuration file for the multiple runs.
#   3. _params.ini_ - Empty parameters file, chosen based on the destination 
#      path.
#   4. update.sh - Script for updating the copied files to their latest version.
#
# Notes:
#   - The script appends a warning message to the copied 'multiple_runs.sh' and
#     'update.sh' scripts, indicating they are auto-generated and should not be 
#     modified manually.
#   - The 'input.txt' file's 'MULTIPLE_RUNS_PROJECT_FULL_PATH' line is updated 
#     with the correct path.
#   - The appropriate '_params.ini_' file is selected based on the destination 
#     path.
#   - Ensure all required files are present in the current directory before 
#     running the script.
#
######################################################################

# TODO: Perform parameter and unit checks

# ENVIRONMENT VARIABLES

MAIN_SCRIPTS_DIRECTORY_FULL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# echo $MAIN_SCRIPTS_DIRECTORY_FULL_PATH
# source "$MAIN_SCRIPTS_DIRECTORY_FULL_PATH/../library/auxiliary.sh"
# source "$MAIN_SCRIPTS_DIRECTORY_FULL_PATH/../library/interface.sh"

for custom_functions_script in $(realpath "$MAIN_SCRIPTS_DIRECTORY_FULL_PATH/../library"/*.sh);
do
    if [ -f "$custom_functions_script" ]; then
        source "$custom_functions_script"
    fi
done

# USER INPUT: Set (full or relative) path of the destination directory
DESTINATION_PATH="/nvme/h/cy22sg1/qpb_branches/Chebyshev_modified_eigenvalues/qpb/mainprogs/overlap-Chebyshev/normality"
# Check if destination directory exists. If not, exit with warning
ERROR_MESSAGE="Destination directory does not exist. Please check again."
check_if_directory_exists $DESTINATION_PATH $ERROR_MESSAGE
# Append "multiple_runs" directory to destination. Create it if not existent
DESTINATION_PATH+="/multiple_runs_scripts"
if [ ! -d "$DESTINATION_PATH" ]; then
    mkdir -p "$DESTINATION_PATH"
    echo "'multiple_runs' directory created in destination."
fi

MULTIPLE_RUNS_PROJECT_FULL_PATH="$(dirname $MAIN_SCRIPTS_DIRECTORY_FULL_PATH)"

# COPY ALL NECESSARY FILES TO DESTINATION MODIFIED APPROPRIATELY IF NECESSARY

# 1. "multiple_runs.sh" script
cp multiple_runs.sh $DESTINATION_PATH
# NOTE: A warning is appended to the copied "multiple_runs.sh" read-only script
WARNING_MESSAGE=\
"\n\n#======================================================================
\n# This script is auto-generated and should not be modified manually.
\n# ====================================================================="
copied_multiple_runs_script_full_path="${DESTINATION_PATH}/multiple_runs.sh"
target_line="#!/bin/bash"
insert_message $copied_multiple_runs_script_full_path $target_line\
 $WARNING_MESSAGE
# Make copied "multiple_runs.sh" script an executable
chmod +x $copied_multiple_runs_script_full_path

# 2. "input.txt" text file
# NOTE: Line "MULTIPLE_RUNS_PROJECT_FULL_PATH=" of original "input.txt" is 
# auto-filled
sed -i \
"s|^\(MULTIPLE_RUNS_PROJECT_FULL_PATH=\).*|\1\"$MULTIPLE_RUNS_PROJECT_FULL_PATH\"|"\
        "input.txt"
cp input.txt $DESTINATION_PATH
# NOTE: 
# Capture the output of the function into a variable
modifiable_parameters=$(print_list_of_modifiable_parameters)
# Initialize an empty variable to hold the formatted output
formatted_parameters=""
# Process each line of the captured output
while IFS= read -r line; do
    formatted_parameters+="#$line\n"
done <<< "$modifiable_parameters"
# Pass
insert_message "${DESTINATION_PATH}/input.txt" \
                    "# List of all modifiable parameters" \
                        $formatted_parameters

# 3. Empty parameters file renamed "_params.ini_"
# Initialize empty_parameters_file_path variable
empty_parameters_file_path="./parameters_files/"
ERROR_MESSAGE="Corresponding empty parameters file cannot be located."
# The appropriate file to be copied needs to be selected 
# Check if destination path contains "invert"
if [[ "$DESTINATION_PATH" == *"invert"* ]]; then
    # Destination path contains "invert"
    if [[ "$DESTINATION_PATH" == *"overlap-kl"* ]]; then
        # Destination path contains "overlap-kl"
        empty_parameters_file_path+="KL_invert_empty_parameters_file.ini"
        check_if_file_exists $empty_parameters_file_path $ERROR_MESSAGE
        cp ${empty_parameters_file_path} "${DESTINATION_PATH}/_params.ini_"
    elif [[ "$DESTINATION_PATH" == *"overlap-Chebyshev"* ]]; then
        # Destination path contains "overlap-Chebyshev"
        empty_parameters_file_path+="Chebyshev_invert_empty_parameters_file.ini"
        check_if_file_exists $empty_parameters_file_path $ERROR_MESSAGE
        cp ${empty_parameters_file_path} "${DESTINATION_PATH}/_params.ini_"
    else
        # Destination path does not contain neither "overlap-kl" 
        # or "overlap-Chebyshev"
        empty_parameters_file_path+="Bare_invert_empty_parameters_file.ini"
        check_if_file_exists $empty_parameters_file_path $ERROR_MESSAGE
        cp ${empty_parameters_file_path} "${DESTINATION_PATH}/_params.ini_"
    fi
else
    # Destination path does not contain "invert"
    if [[ "$DESTINATION_PATH" == *"overlap-kl"* ]]; then
        # Destination path contains "overlap-kl"
        empty_parameters_file_path+="KL_empty_parameters_file.ini"
        check_if_file_exists $empty_parameters_file_path $ERROR_MESSAGE
        cp ${empty_parameters_file_path} "${DESTINATION_PATH}/_params.ini_"
    elif [[ "$DESTINATION_PATH" == *"overlap-Chebyshev"* ]]; then
        # Destination path contains "overlap-Chebyshev"
        empty_parameters_file_path+="Chebyshev_empty_parameters_file.ini"
        check_if_file_exists $empty_parameters_file_path $ERROR_MESSAGE
        cp ${empty_parameters_file_path} "${DESTINATION_PATH}/_params.ini_"
    else
        # Destination path does not contain neither "overlap-kl" 
        # or "overlap-Chebyshev"
        empty_parameters_file_path+="Bare_empty_parameters_file.ini"
        check_if_file_exists $empty_parameters_file_path $ERROR_MESSAGE
        cp ${empty_parameters_file_path} "${DESTINATION_PATH}/_params.ini_"
    fi
fi
# NOTE: Line "EMPTY_PARAMETERS_FILE_FULL_PATH=" of original "input.txt" is set 
# by default to "./_params.ini_". Change accordingly if "_params.ini_" is 
# relocated

# 4. "update.sh" script
# NOTE: Line MAIN_SCRIPTS_DIRECTORY=... of the original file is auto-filled
sed -i \
    "s|^\(MAIN_SCRIPTS_DIRECTORY=\).*|\1\"$MAIN_SCRIPTS_DIRECTORY_FULL_PATH\"|"\
        "update.sh"
cp update.sh $DESTINATION_PATH
copied_update_script_full_path="${DESTINATION_PATH}/update.sh"
# NOTE: A warning is appended to the copied "update.sh" read-only script
insert_message $copied_update_script_full_path $target_line $WARNING_MESSAGE
# Make copied "update.sh" script an executable
chmod +x $copied_update_script_full_path

echo "All 4 files copied successfully!"
