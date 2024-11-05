#!/bin/bash

# TODO: Write description
######################################################################
# usage.sh - Script for 
#
#
######################################################################


############################ ENVIRONMENT VARIABLES #############################

# This section initializes essential environment variables, sets up logging, and
# verifies the validity of key directories and files required for execution of
# the main program's executable. It ensures that custom functions are sourced,
# the input file is loaded, and necessary directories (such as for parameter
# and log files) are created if they don't exist.

# COMMAND-LINE ARGUMENTS CHECKS

# TODO: Add a --usage flag
delete_existing_files="False" # Initialize
# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -d|--delete)
            delete_existing_files="True"
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# CONSTRUCT LOG FILE

CURRENT_SCRIPT_NAME="$(basename "$0")"

# Current script's log file must be in script directory. Replace ".sh" with
# "_log.txt" to create the log file name and path
export LOG_FILE_PATH=$(realpath \
                "./"$(echo "$CURRENT_SCRIPT_NAME" | sed 's/\.sh$/_log.txt/'))

# Create or override log file. Initiate logging
echo -e "\t\t"$(echo "$CURRENT_SCRIPT_NAME" | tr '[:lower:]' '[:upper:]') \
                            "SCRIPT EXECUTION INITIATED\n" > "$LOG_FILE_PATH"

# Split logging into parts for readability
echo -e "\t\t** ENVIRONMENT VARIABLES **\n" >> "$LOG_FILE_PATH"

# Script termination message to be used for finalizing logging
export SCRIPT_TERMINATION_MESSAGE="\n\t\t"$(echo "$CURRENT_SCRIPT_NAME" \
                    | tr '[:lower:]' '[:upper:]')" SCRIPT EXECUTION TERMINATED"

# SOURCE LIBRARY SCRIPTS

# NOTE: "qpb_parameters_scan" project directory path is set by "setup.sh" here
# and not in the input file to prevent accidental modification.
QPB_PARAMETERS_SCAN_PROJECT_DIRECTORY_FULL_PATH=
if [ ! -d "$QPB_PARAMETERS_SCAN_PROJECT_DIRECTORY_FULL_PATH" ]; then
    ERROR_MESSAGE="Invalid 'qpb_parameters_scan' project directory path."
    echo "ERROR: "$ERROR_MESSAGE
    echo "Exiting..."
    # Log error explicitly since "log()" function hasn't been sourced yet
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] : $ERROR_MESSAGE" \
                                                            >> "$LOG_FILE_PATH"
    echo -e $SCRIPT_TERMINATION_MESSAGE >> "$LOG_FILE_PATH"
    exit 1
fi

# Source all custom functions scripts from "qpb_parameters_scan/library" using a
# loop avoiding this way name-specific sourcing and thus potential typos
sourced_scripts_count=0 # Initialize a counter for sourced files
for custom_functions_script in $(realpath \
            "$QPB_PARAMETERS_SCAN_PROJECT_DIRECTORY_FULL_PATH/library"/*.sh);
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

# SOURCE INPUT FILE

# NOTE: input.txt is placed in the script's directory by setup.sh
INPUT_FILE_PATH="./input.txt"
error_message="Input file '$INPUT_FILE_PATH' could not be found."
check_if_file_exists "$INPUT_FILE_PATH" "$error_message" || exit 1
source "$INPUT_FILE_PATH" # Load all input file's contents
log "INFO" "File '"${INPUT_FILE_PATH}"' has been sourced properly."

# CHECK MAIN PROGRAM'S EXECUTABLE PATH

error_message="Invalid main program's executable path."
check_if_file_exists "$MAIN_PROGRAM_EXECUTABLE" "$error_message" || exit 1
log "INFO" "Main program's executable path is valid."

# CHECK EMPTY PARAMETERS FILE PATH

# NOTE: _params.ini_ is placed by default in this script's directory by setup.sh
error_message="Invalid empty parameters file path."
check_if_file_exists "$EMPTY_PARAMETERS_FILE_PATH" $error_message || exit 1
EMPTY_PARAMETERS_FILE_FULL_PATH=$(realpath $EMPTY_PARAMETERS_FILE_PATH)
log "INFO" "Empty parameters file path is valid."

# CHECK PARAMETERS FILES DIRECTORY PATH

# Check if the parent directory of the parameters files exists, since the 
# parameters files directory itself may not yet be created.
error_message="Parent directory of parameters files directory does not exist."
check_if_directory_exists "$(dirname $PARAMETERS_FILES_DIRECTORY)" \
                                                    "$error_message" || exit 1
log "INFO" "Parameters files directory path is valid."
# Create parameters files directory if it doesn't already exist
if [ ! -d "$PARAMETERS_FILES_DIRECTORY" ]; then
    mkdir -p "$PARAMETERS_FILES_DIRECTORY"
    log_message="Parameters files directory "
    log_message+="'${PARAMETERS_FILES_DIRECTORY}' was created."
    log "INFO" "$log_message"
# Also, if requested, delete all files if the directory exists and is not empty.
elif [[ "$delete_existing_files" == "True" ]]; then
    # Check if the existing directory is not empty
    if [ "$(ls -A "$PARAMETERS_FILES_DIRECTORY")" ]; then
        rm -rf "$PARAMETERS_FILES_DIRECTORY"/*
        log "INFO" "All files in parameters files directory were deleted."
    fi
fi

# CHECK GAUGE LINKS CONFIGURATIONS DIRECTORY PATH

error_message="Invalid gauge links configurations directory."
check_if_directory_exists "$GAUGE_LINKS_CONFIGURATIONS_DIRECTORY" \
                                                    "$error_message" || exit 1
log "INFO" "Gauge links configurations directory path is valid."

# CHECK LOG FILES DIRECTORY PATH

# Check if the parent directory of the log files exists, since the parameters
# files directory itself may not yet be created.
error_message="Parent directory of log files directory does not exist."
check_if_directory_exists $(dirname $LOG_FILES_DIRECTORY) \
                                                    "$error_message" || exit 1
# Create executable's log files directory if it doesn't already exist
if [ ! -d "$LOG_FILES_DIRECTORY" ]; then
    mkdir -p "$LOG_FILES_DIRECTORY"
    log_message="Main program's executable log files directory "
    log_message+="'${LOG_FILES_DIRECTORY}' was created."
    log "INFO" "$log_message"
# Also, if requested, delete all files if the directory exists and is not empty.
elif [[ "$delete_existing_files" == "True" ]]; then
    # Check if the existing directory is not empty
    if [ "$(ls -A "$LOG_FILES_DIRECTORY")" ]; then
        rm -rf "$LOG_FILES_DIRECTORY"/*
    fi
fi
log "INFO" "Main program's executable log files directory path is valid."

# CHECK BINARY SOLUTION FILES DIRECTORY PATH

# Extract full path of current script's directory for later use
CURRENT_SCRIPT_FULL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if current script's directory path contains the substring "invert"
MAIN_PROGRAM_IS_INVERT="False" # Initial value
if [[ "${CURRENT_SCRIPT_FULL_PATH}" == *"invert"* ]]; then
    # If it does then check "BINARY_INVERT_SOLUTION_FILES_DIRECTORY" variable also
    error_message="Invalid invert solution files directory."
    check_if_directory_exists "$BINARY_INVERT_SOLUTION_FILES_DIRECTORY" \
                                                    "$error_message" || exit 1
    BINARY_INVERT_SOLUTION_FILES_DIRECTORY=$(realpath $BINARY_INVERT_SOLUTION_FILES_DIRECTORY)
    log "INFO" "Invert solution files directory path is valid."
    # Set "MAIN_PROGRAM_IS_INVERT" boolean variable to True for later use
    MAIN_PROGRAM_IS_INVERT="True"
fi

########################### PARAMETERS SPECIFICATION ###########################

# This section sets the values for non-iterable parameters, checks the requested
# varying iterable parameters

echo -e "\n\t\t** PARAMETERS SPECIFICATION **\n" >> "$LOG_FILE_PATH"

# SET NON-ITERABLE PARAMETERS VALUES

# Extract non-iterable parameters values
OVERLAP_OPERATOR_METHOD=$(\
                extract_overlap_operator_method $CURRENT_SCRIPT_FULL_PATH)
KERNEL_OPERATOR_TYPE=$(extract_kernel_operator_type $KERNEL_OPERATOR_TYPE_FLAG)
if [ $? -ne 0 ]; then
    error_message="Invalid KERNEL_OPERATOR_TYPE_FLAG value"
    error_message+="'$KERNEL_OPERATOR_TYPE_FLAG'.\n"
    error_message+="Valid values are:\n"
    error_message+="- 'Standard', 'Stan', '0', or\n"
    error_message+="- 'Brillouin', 'Bri', '1'."
    termination_output "${error_message}"
    exit 1
fi
log "INFO" "Kernel operator type flag is valid."
QCD_BETA_VALUE=$(extract_QCD_beta_value "$GAUGE_LINKS_CONFIGURATIONS_DIRECTORY")
LATTICE_DIMENSIONS=$(\
            extract_lattice_dimensions "$GAUGE_LINKS_CONFIGURATIONS_DIRECTORY")

# Log non-iterable parameters values
non_iterable_parameters_values=$(\
        print_list_of_parameters NON_ITERABLE_PARAMETERS_NAMES_ARRAY -noindices)
log "INFO" \
"Working non-iterable parameters values:\n$non_iterable_parameters_values"

# CHECK NON-ITERABLE PARAMETERS TO BE PRINTED

# Check validity of LIST_OF_NON_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED array
validate_indices_array \
    LIST_OF_NON_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED \
        NON_ITERABLE_PARAMETERS_NAMES_ARRAY || { echo "Exiting..."; exit 1; }
log "INFO" "Valid elements passed to "\
"'LIST_OF_NON_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED' array."

# Log list of parameter names to be printed in output filenames
list_of_non_iterable_parameters_names_to_be_printed=""
for index in "${LIST_OF_NON_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED[@]}"; do
    parameter_name="'${NON_ITERABLE_PARAMETERS_NAMES_ARRAY[$index]}'"
    list_of_non_iterable_parameters_names_to_be_printed+=" ${parameter_name},"
done
list_of_non_iterable_parameters_names_to_be_printed="\
${list_of_non_iterable_parameters_names_to_be_printed%,}."
log "INFO" "List of non-iterable parameters names requested to "\
"be printed with values in output "\
"filenames:${list_of_non_iterable_parameters_names_to_be_printed}"

# CHOOSE ITERABLE PARAMETERS NAMES ARRAY

# Use current script's directory to choose among 6 iterable parameters arrays 
overlap_operator_method_label=${OVERLAP_OPERATOR_METHOD}
if [[ "${MAIN_PROGRAM_IS_INVERT}" == "True" ]]; then
    overlap_operator_method_label+="_invert"
fi
iterable_parameters_names_array_name="${ITERABLE_PARAMETERS_NAMES_DICTIONARY[\
"$overlap_operator_method_label"]}"
log "INFO" "The iterable parameters names array that will be used is "\
"'${iterable_parameters_names_array_name}'."

declare -n \
iterable_parameters_names_array="$iterable_parameters_names_array_name"

# ESTABLISH VARYING ITERABLE PARAMETERS SET OF VALUES

# Before checking the validity of the VARYING_PARAMETERS_INDICES_LIST array,
# check its length. Check first if it's empty
if [ -z "${VARYING_PARAMETERS_INDICES_LIST}" ]; then
    ERROR_MESSAGE="'VARYING_PARAMETERS_INDICES_LIST' must not be empty."
    termination_output "${ERROR_MESSAGE}"
    exit 1
fi
# Check then if VARYING_PARAMETERS_INDICES_LIST contains more than 3 indices
if [ "${#VARYING_PARAMETERS_INDICES_LIST[@]}" -gt 3 ]; then
    ERROR_MESSAGE="'VARYING_PARAMETERS_INDICES_LIST' must contain at most 3 "\
"indices."
    termination_output "${ERROR_MESSAGE}"
    exit 1
fi
# Check finally validity of VARYING_PARAMETERS_INDICES_LIST array
validate_indices_array VARYING_PARAMETERS_INDICES_LIST \
        iterable_parameters_names_array || { echo "Exiting..."; exit 1; }
log "INFO" "Valid elements passed to 'VARYING_PARAMETERS_INDICES_LIST' array."

# Create a shorter reference to the range generator functions dictionary 
# for convenience
declare -n \
generators_dict="MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATORS_DICTIONARY"

# Check values passed to those "<>_VARYING_PARAMETER_SET_OF_VALUES" variables
# among the three that correspond to the VARYING_PARAMETERS_INDICES_LIST values
varying_iterable_parameters_names_array=() # Create array for later use
for list_index in "${!VARYING_PARAMETERS_INDICES_LIST[@]}"; do

    # Extract the corresponding parameter name to the varying parameter index
    varying_parameter_index="${VARYING_PARAMETERS_INDICES_LIST[$list_index]}"
    varying_parameter_name="${iterable_parameters_names_array[\
                                                    $varying_parameter_index]}"
    varying_iterable_parameters_names_array+=("$varying_parameter_name")

    # Extract the name of the varying parameter values array
    temp="${VARYING_PARAMETERS_SET_OF_VALUES_ARRAYS_NAMES[$list_index]}"
    varying_parameter_set_of_values_array_name=$temp

    # Check passed input to the corresponding varying parameter values array
    # Check first if it was left empty
    if [ -z "${!varying_parameter_set_of_values_array_name}" ]; then
        # Indirect expansion to evaluate the value of the variable named in
        # varying_parameter_set_of_values_array_name
        error_message="Input variable "
        error_message+="'${varying_parameter_set_of_values_array_name}' was "
        error_message+="left empty, despite '${varying_parameter_name}' "
        error_message+="declared as a varying iterable parameter."
        termination_output "${error_message}"
        exit 1

    # Check if a range of values was requested via input "[start end step]"
    elif is_range_string "${!varying_parameter_set_of_values_array_name}"; then
        log_message="A range of values was requested to populate the "
        log_message+="'${varying_parameter_set_of_values_array_name}' array."
        log "INFO" "$log_message"
        # If a range was requested, then choose range of values generator
        range_of_values_function="${generators_dict[$varying_parameter_name]}"
        # Generate parameter values for the specified range using this function
        # TODO: Way too convoluted. I should untangle these functions
        parameter_range_of_values_string=$(parameter_range_of_values_generator \
                            "$range_of_values_function"\
                                "$varying_parameter_set_of_values_array_name")
        # Change value of the "<>_VARYING_PARAMETER_SET_OF_VALUES" variable to
        # the generated set of values
        declare -n array_to_modify="$varying_parameter_set_of_values_array_name"
        array_to_modify=($parameter_range_of_values_string)

        printed_array=$(print_array_limited array_to_modify 15)
        log "INFO" "The set of values generated is:\n$printed_array."

    # If no range of values was requested, then a set of values is expected
    elif validate_varying_parameter_values_array \
                        $varying_parameter_name \
                            $varying_parameter_set_of_values_array_name; then
        log_message="A valid set of values was passed to the "
        log_message+="'${varying_parameter_set_of_values_array_name}' array."
        log "INFO" "$log_message"

    # Reject passed input if the varying parameter values array is not empty and
    # both tests fail
    else
        error_message="Not valid input to "
        error_message+="${varying_parameter_set_of_values_array_name} array."
        termination_output "${error_message}"
        exit 1
    fi
done

# If the length of the VARYING_PARAMETERS_INDICES_LIST array is smaller than
# three, then the corresponding "<>_VARYING_PARAMETER_SET_OF_VALUES" variables
# must acquire a ("DUMMY_VALUE") for later use
for ((index=${#VARYING_PARAMETERS_INDICES_LIST[@]}; index<3 ; index++)); do
    # Extract the name of the varying parameter values array
    temp="${VARYING_PARAMETERS_SET_OF_VALUES_ARRAYS_NAMES[$index]}"
    varying_parameter_set_of_values_array_name=$temp
    # Pass a single "DUMMY_VALUE" to "<>_VARYING_PARAMETER_SET_OF_VALUES" variable
    declare -n array_to_modify="$varying_parameter_set_of_values_array_name"
    array_to_modify=("DUMMY_VALUE")
    log "INFO" "Array '${varying_parameter_set_of_values_array_name}' "\
"has been assigned a single 'DUMMY_VALUE' element."
done

# UPDATE CONSTANT ITERABLE PARAMETERS VALUES

# Check validity of passed elements of LIST_OF_UPDATED_CONSTANT_VALUES array
validate_updated_constant_parameters_array LIST_OF_UPDATED_CONSTANT_VALUES \
    $iterable_parameters_names_array_name \
        varying_iterable_parameters_names_array \
            || { echo "Exiting..."; exit 1; }
log "INFO" "Passed elements to 'LIST_OF_UPDATED_CONSTANT_VALUES' array "\
"are valid."
# Update values of constant iterable parameters
constant_parameters_update LIST_OF_UPDATED_CONSTANT_VALUES \
                                            || { echo "Exiting..."; exit 1; }

# CHECK CONSTANT ITERABLE PARAMETERS TO BE PRINTED

# Check LIST_OF_CONSTANT_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED array
validate_indices_array \
    LIST_OF_CONSTANT_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED \
        $iterable_parameters_names_array_name || { echo "Exiting..."; exit 1; }
# Check that no varying parameter indices were included
compare_no_common_elements VARYING_PARAMETERS_INDICES_LIST \
            LIST_OF_CONSTANT_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED \
                                            || { echo "Exiting..."; exit 1; }
log "INFO" "Passed elements to "\
"'LIST_OF_CONSTANT_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED' array are valid."

# Check if "GAUGE_LINKS_CONFIGURATION_LABEL" parameter is null
if [ "$GAUGE_LINKS_CONFIGURATION_LABEL" == "0000000" ]; then
    # If null then set "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH" to full path
    # of the very first file inside the "GAUGE_LINKS_CONFIGURATIONS_DIRECTORY"
    GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH=$(\
            find "$GAUGE_LINKS_CONFIGURATIONS_DIRECTORY" -type f | head -n 1)
    # And extract its label for possible later use
    GAUGE_LINKS_CONFIGURATION_LABEL=$(extract_configuration_label_from_file \
                                    "$GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH")
fi

############################ TEMPLATE CONSTRUCTION #############################

echo -e "\n\t\t** TEMPLATE CONSTRUCTION **\n" >> "$LOG_FILE_PATH"

# CONSTRUCT OUTPUT FILES NAME

# Attach labels and values of non-iterable parameters requested to be printed
output_filename=""
for index in "${LIST_OF_NON_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED[@]}"; do

    parameter_name=${NON_ITERABLE_PARAMETERS_NAMES_ARRAY[index]}
    parameter_value=${!NON_ITERABLE_PARAMETERS_NAMES_ARRAY[index]}

    if [ "$parameter_name" != "LATTICE_DIMENSIONS" ]; then
        parameter_label=${MODIFIABLE_PARAMETERS_LABELS_DICTIONARY[$parameter_name]}
        output_filename+="${parameter_label}"
        output_filename+="${parameter_value}_"

    else
        output_filename+=$(print_lattice_dimensions $parameter_value)
    fi
done

# Then do similarly for constant iterable parameters requested to be printed
for index in "${LIST_OF_CONSTANT_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED[@]}"; do

    parameter_name=${iterable_parameters_names_array[index]}
    parameter_value=${!iterable_parameters_names_array[index]}

    parameter_label=${MODIFIABLE_PARAMETERS_LABELS_DICTIONARY[$parameter_name]}
    output_filename+="${parameter_label}"
    output_filename+="${parameter_value}_"
done

# If value is of decimal number format, replace "." with "p"
output_filename=$(modify_decimal_format "$output_filename")
# Remove trailing "_"
output_filename="${output_filename%_}"

# CONSTRUCT TEMPLATE PARAMETERS FILE

PARAMETERS_FILES_DIRECTORY="$(realpath "${PARAMETERS_FILES_DIRECTORY}")"
TEMPLATE_PARAMETERS_FILE_FULL_PATH="${PARAMETERS_FILES_DIRECTORY}"
TEMPLATE_PARAMETERS_FILE_FULL_PATH+="/params_${output_filename}.ini"

# Copy empty parameters file to parameters files directory
cp ${EMPTY_PARAMETERS_FILE_FULL_PATH} ${TEMPLATE_PARAMETERS_FILE_FULL_PATH}
if [ $? -ne 0 ]; then
    ERROR_MESSAGE="Copying '$EMPTY_PARAMETERS_FILE_FULL_PATH' file failed."
    termination_output "${ERROR_MESSAGE}"
    echo "Exiting..."
    exit 1
fi
log "INFO" "Parameters files template constructed."

# CONSTRUCT LIST OF CONSTANT MODIFIABLE PARAMETERS

# Concatenate iterable and non-iterable parameters names arrays into one
constant_parameters_names_array=("${NON_ITERABLE_PARAMETERS_NAMES_ARRAY[@]}" \
                                        "${iterable_parameters_names_array[@]}")

# Exclude varying iterable parameters names
temp_array=()
for element in "${constant_parameters_names_array[@]}"; do
    # Check if element is not in "varying_iterable_parameters_names_array" array
    if [[ ! " ${varying_iterable_parameters_names_array[@]} " =~ " $element " ]];
    then
        temp_array+=("$element")
    fi
done
constant_parameters_names_array=("${temp_array[@]}")

# PARTIALLY FILLY UP TEMPLATE PARAMETERS FILE

# Fill up the copied empty template with the values of the constant parameters
for parameter in "${constant_parameters_names_array[@]}"; do
    # Get the value of the value of the parameter
    parameter_value="${!parameter}"

    if [ $parameter == "GAUGE_LINKS_CONFIGURATION_LABEL" ]; then
        # NOTE: "_GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH_" is the string to be
        # replaced inside the empty parameters file with the gauge links
        # configuration file full path, and not a string containing
        # "GAUGE_LINKS_CONFIGURATION_LABEL" as might be expected
        parameter="GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH"
        parameter_value=$(match_configuration_label_to_file $parameter_value)
    fi

    # Use sed to perform the replacement
    sed -i "s@_${parameter}_@${parameter_value}@g" \
                                        "$TEMPLATE_PARAMETERS_FILE_FULL_PATH" \
        || { 
            error_message="Could not pass ${parameter} value to template file";
            termination_output "$error_message";
            exit 1;
            }
done

log "INFO" "Parameters files template was partially filled."

############################### JOBS SUBMISSION ################################

echo -e "\n\t\t** JOBS SUBMISSION **\n" >> "$LOG_FILE_PATH"

# CONSTRUCT PATH TO GENERIC JOB SUBMISSIONS SCRIPT

GENERIC_SCRIPT_SCRIPT_FULL_PATH=$QPB_PARAMETERS_SCAN_PROJECT_DIRECTORY_FULL_PATH
GENERIC_SCRIPT_SCRIPT_FULL_PATH+="/main_scripts/generic_run.sh"
if [ ! -f "$GENERIC_SCRIPT_SCRIPT_FULL_PATH" ]; then
    error_message="Invalid path to generic job submissions script.";
    termination_output "$error_message";
    exit 1;
fi
log "INFO" "Parameters files template was partially filled."

# CHECK SBATCH OPTIONS

check_mpi_geometry $MPI_GEOMETRY || { echo "Exiting..."; exit 1; }
# The number of tasks is calculated automatically from the given MPI geometry
NUMBER_OF_TASKS=($(convert_mpi_geometry_to_number_of_tasks $MPI_GEOMETRY))
# is_integer $NUMBER_OF_NODES || {
#         error_message="Invalid 'NUMBER_OF_NODES' input value.";
#         termination_output "${error_message}";
#         exit 1;
#     }

# if [ -n "${NTASKS_PER_NODE}" ]; then
#     is_integer $NTASKS_PER_NODE || {
#             error_message="Invalid 'NTASKS_PER_NODE' input value.";
#             termination_output "${error_message}";
#             exit 1;
#         }
# fi
check_walltime $WALLTIME || { echo "Exiting..."; exit 1; }

log "INFO" "sbatch options passed are valid."

# CONSTRUCT VARYING ITERABLE PARAMETERS LABELS ARRAY

varying_iterable_parameters_labels_array=()
for list_index in "${!VARYING_PARAMETERS_INDICES_LIST[@]}"; do
    # Extract the corresponding parameter name to the varying parameter index
    varying_parameter_name=${varying_iterable_parameters_names_array[$list_index]}
    # Extract the corresponding parameter label to the varying parameter name
    varying_parameter_label=${MODIFIABLE_PARAMETERS_LABELS_DICTIONARY[$varying_parameter_name]}
    varying_iterable_parameters_labels_array+=("$varying_parameter_label")
done

# NESTED LOOPS OF THE VARYING_PARAMETER_SET_OF_VALUES

base_filename="${output_filename}" 
varying_parameters_values=()
for overall_outer_loop_varying_parameter_value in \
                  "${OVERALL_OUTER_LOOP_VARYING_PARAMETER_SET_OF_VALUES[@]}"; do

    if [ $overall_outer_loop_varying_parameter_value != "DUMMY_VALUE" ]; then
        label="${varying_iterable_parameters_labels_array[2]}"
        value="${overall_outer_loop_varying_parameter_value}"
        overall_outer_loop_suffix="_${label}${value}"
    fi

    for outer_loop_varying_parameter_value in \
                          "${OUTER_LOOP_VARYING_PARAMETER_SET_OF_VALUES[@]}"; do

        if [ $outer_loop_varying_parameter_value != "DUMMY_VALUE" ]; then
            label="${varying_iterable_parameters_labels_array[1]}"
            value="${outer_loop_varying_parameter_value}"
            outer_loop_suffix="_${label}${value}"
        fi

        for inner_loop_varying_parameter_value in \
                          "${INNER_LOOP_VARYING_PARAMETER_SET_OF_VALUES[@]}"; do
            label="${varying_iterable_parameters_labels_array[0]}"
            value="${inner_loop_varying_parameter_value}"
            inner_loop_suffix="_${label}${value}"

            # CONSTRUCT OUTPUT FILES NAME

            output_filename="${base_filename}"
            output_filename+="${overall_outer_loop_suffix}"
            output_filename+="${outer_loop_suffix}"
            output_filename+="${inner_loop_suffix}"
            output_filename=$(modify_decimal_format $output_filename)

            # Add "ADDITIONAL_TEXT_TO_BE_PRINTED" as a suffix 
            if [[ -n "$ADDITIONAL_TEXT_TO_BE_PRINTED" ]]; then
                output_filename+="_${ADDITIONAL_TEXT_TO_BE_PRINTED}"
            fi

            # CONSTRUCT FILLED PARAMETERS FILE

            # Create a parameters file from template with varying parameters
            # lines still unfilled
            filled_parameters_file_full_path="${PARAMETERS_FILES_DIRECTORY}"
            filled_parameters_file_full_path+="/params_${output_filename}.ini"
            copy_file_and_check "${TEMPLATE_PARAMETERS_FILE_FULL_PATH}" \
                                    "${filled_parameters_file_full_path}" \
                                            || { echo "Exiting..."; exit 1; }

            # FILL IN PARAMETERS FILES

            varying_parameters_values[0]="$inner_loop_varying_parameter_value"
            varying_parameters_values[1]="$outer_loop_varying_parameter_value"
            temp_value="$overall_outer_loop_varying_parameter_value"
            varying_parameters_values[2]="$temp_value"

            # Loop through indices and handle each parameter if it’s not a
            # "DUMMY_VALUE"
            for index in "${!varying_parameters_values[@]}"; do
                parameter_value="${varying_parameters_values[$index]}"
                if [ "$parameter_value" != "DUMMY_VALUE" ]; then
                    parameter_name="${varying_iterable_parameters_names_array[\
                    $index]}"
                  if [ "$parameter_name" == "GAUGE_LINKS_CONFIGURATION_LABEL" ];
                  then
                       parameter_name="GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH"
                        parameter_value=$(match_configuration_label_to_file \
                                                            "$parameter_value")
                    fi
                    replace_string_in_file "$filled_parameters_file_full_path" \
                                "_${parameter_name}_" "$parameter_value" \
                                            || { echo "Exiting..."; exit 1; }
                fi
            done

            # For invert main progs, the binary solutions file full path needs
            # to be specified as well inside the parameters file
            if [[ "${MAIN_PROGRAM_IS_INVERT}" == "True" ]]; then
                binary_solution_file_full_path=$BINARY_INVERT_SOLUTION_FILES_DIRECTORY
                binary_solution_file_full_path+="/${output_filename}.dat"
                parameter_name="BINARY_INVERT_SOLUTION_FILE_PATH"
                parameter_value=$binary_solution_file_full_path
                replace_string_in_file "$filled_parameters_file_full_path" \
                                    "_${parameter_name}_" "${parameter_value}" \
                                            || { echo "Exiting..."; exit 1; }
            fi

            # SET SLURM SBATCH OPTIONS

            JOB_NAME="${output_filename}"
            # Remove all underscores from the JOB_NAME variable
            JOB_NAME=$(echo "$JOB_NAME" | sed 's/_//g')
            OUTPUT_FILE="${LOG_FILES_DIRECTORY}/${output_filename}.txt"
            ERROR_FILE="${LOG_FILES_DIRECTORY}/${output_filename}.err"

            SBATCH_OPTIONS="--job-name=${JOB_NAME}"
            SBATCH_OPTIONS+="--error=${ERROR_FILE}"
            SBATCH_OPTIONS+="--output=${OUTPUT_FILE}"
            SBATCH_OPTIONS+="--nodes=${NUMBER_OF_NODES}"
            SBATCH_OPTIONS+="--time=${WALLTIME}"
            if [ -n "${NTASKS_PER_NODE}" ]; then
                SBATCH_OPTIONS+="--ntasks-per-node=${NTASKS_PER_NODE}"
            fi
            if [ -n "${PARTITION_NAME}" ]; then
                SBATCH_OPTIONS+="--partition=${PARTITION_NAME}"
            fi
            if [ -n "${ADDITIONAL_OPTIONS}" ]; then
                SBATCH_OPTIONS+="${ADDITIONAL_OPTIONS}"
            fi

            # Submit job
            sbatch ${SBATCH_OPTIONS} ${GENERIC_SCRIPT_SCRIPT_FULL_PATH} \
                                ${MAIN_PROGRAM_EXECUTABLE} ${MPI_GEOMETRY} \
                                    ${filled_parameters_file_full_path} \
                                        ${NUMBER_OF_TASKS}

        done
    done
done

# SUCCESSFUL COMPLETION OUTPUT

# Construct the final message
final_message="${CURRENT_SCRIPT_NAME} processes complete!"
# Print the final message
echo "$final_message"

# echo -e "\n" >> "$LOG_FILE_PATH"
log "INFO" "${final_message}"

echo -e $SCRIPT_TERMINATION_MESSAGE >> "$LOG_FILE_PATH"

unset SCRIPT_TERMINATION_MESSAGE
unset LOG_FILE_PATH