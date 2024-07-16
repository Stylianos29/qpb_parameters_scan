#!/bin/bash


######################################################################
# update.sh
#
# This script is designed to facilitate the update process for the
# multiple_runs_project. It sets the necessary environment variables
# and runs the setup script from the main scripts directory.
#
# Author: Stylianos Gregoriou
# Date last modified: 16th June 2024
#
# Usage: This script should be placed in the destination directory
# as defined inside the setup.sh script. It should be run whenever
# updates to the setup process are required.
#
######################################################################


# Get the current script's directory path
CURRENT_SCRIPT_FULL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Navigate up one level to remove the "multiple_runs_scripts" directory
DESTINATION_PATH="$(dirname "$CURRENT_SCRIPT_FULL_PATH")"

# Change directory to the main scripts directory
# NOTE: This line is set automatically from the setup.sh script
MAIN_SCRIPTS_DIRECTORY="/nvme/h/cy22sg1/qpb_branches/multiple_runs_project/main_scripts"
cd "$MAIN_SCRIPTS_DIRECTORY" || exit

# Run the setup script with updated environment variables
./setup.sh -p $DESTINATION_PATH

# Change directory back to the original destination directory
cd "$DESTINATION_PATH" || exit

echo "Update process complete."
