#!/bin/bash


# Prevent multiple sourcing of this script by exiting if JOB_SUBMISSION_SH is
# already set. Otherwise, set JOB_SUBMISSION_SH to mark it as sourced.
[[ -n "${JOB_SUBMISSION_SH}" ]] && return
JOB_SUBMISSION_SH=1

CURRENT_LIBRARY_SCRIPT_FULL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source all custom functions scripts from "qpb_parameters_scan/library" using a
# loop avoiding this way name-specific sourcing and thus potential typos
for library_script in "$CURRENT_LIBRARY_SCRIPT_FULL_PATH";
do
    # Check if the current file in the loop is a regular file
    if [ -f "$library_script" ]; then
        source "$library_script"
    fi
done
unset CURRENT_LIBRARY_SCRIPT_FULL_PATH


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


fill_in_parameter_file()
{

  for constant_parameter in "${constant_parameters_list[@]}"; do
    # Get the value of the replacement variable
    value="${!constant_parameter}"

    # Use sed to perform the replacement
    sed -i "s@_${constant_parameter}_@${value}@g" "$EMPTY_PARAMETERS_TEMPLATE_FILE"
  done

}


check_mpi_geometry() {
    local input="$1"

    # Use regex to check if input matches the form "even,even,even"
    if [[ "$input" =~ ^([0-9]+),([0-9]+),([0-9]+)$ ]]; then
        # Check each number to see if it's an even integer
        if (( ${BASH_REMATCH[1]} % 2 == 0 && ${BASH_REMATCH[2]} % 2 == 0 && ${BASH_REMATCH[3]} % 2 == 0 )); then
            return 0  # Valid input
        fi
    fi
  
    error_message="Invalid 'MPI_GEOMETRY' input value."
    termination_output "${error_message}" "${SCRIPT_TERMINATION_MESSAGE}"
    return 1  # Not valid input
}



check_walltime() {
    local input="$1"

    # Use regex to match "HOURS:MINUTES:SECONDS" format
    if [[ "$input" =~ ^([0-9]{1,2}):([0-9]{1,2}):([0-9]{1,2})$ ]]; then
        local hours="${BASH_REMATCH[1]}"
        local minutes="${BASH_REMATCH[2]}"
        local seconds="${BASH_REMATCH[3]}"

        # Validate the ranges for hours, minutes, and seconds
        if (( hours >= 0 && hours <= 24 && minutes >= 0 && minutes < 60 && seconds >= 0 && seconds < 60 )); then
            # Ensure the input is not "00:00:00"
            if ! [[ "$hours" == "0" && "$minutes" == "0" && "$seconds" == "0" ]]; then
                return 0  # Valid input
            fi
        fi
    fi

    error_message="Invalid 'WALLTIME' input value."
    termination_output "${error_message}" "${SCRIPT_TERMINATION_MESSAGE}"
    return 1  # Not valid input
}

