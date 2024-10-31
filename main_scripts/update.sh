#!/bin/bash


######################################################################
# update.sh - Script for updating a qpb_parameters_scan installation
#
# This script facilitates the update process for the qpb_parameters_scan
# by executing the setup script located in the main scripts directory. 
# It sets the necessary environment variables and prepares the environment 
# for further processing.
#
# Usage:
#   This script is placed in the "multiple_runs_scripts" directory of the
#   destination directory defined by the setup.sh script and should be executed
#   whenever updates to the project setup are required.
#
# Key Functions:
#   - Sets the full path of the current script for use in other scripts.
#   - Extracts the destination directory path by navigating two levels up from
#     the "multiple_runs_scripts" directory.
#   - Changes the working directory to the "main_scripts" directory of the
#     qpb_parameters_scan.
#   - Executes the setup script with the updated destination path, ensuring all
#     necessary configurations are applied.
#
# Notes:
#   - The script assumes that it is run from the correct context and that the
#     required directories exist.
#   - It will exit if it cannot change to the "main_scripts" directory or if any
#     commands fail.
#
######################################################################


# NOTE: This variable storing the current script's path is used by "setup.sh"
export CURRENT_SCRIPT_FULL_PATH=$(realpath "$0")

# Extract directory two levels above the "qpb_parameters_scan_files" directory
DESTINATION_DIRECTORY_PATH=$(dirname "$(dirname "$CURRENT_SCRIPT_FULL_PATH")")

# Change to the "main_scripts" directory of the "qpb_parameters_scan"
# NOTE: This path is set automatically by "setup.sh"
MAIN_SCRIPTS_DIRECTORY=

# Change to the "main_scripts" directory
cd "$MAIN_SCRIPTS_DIRECTORY" || {
    echo "Error: Unable to access 'qpb_parameters_scan/main_scripts' directory";
    echo "Exiting...";
    exit 1;
}

# Run the setup script with the updated destination path
./setup.sh --path "$DESTINATION_DIRECTORY_PATH"
