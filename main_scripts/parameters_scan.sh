#!/bin/bash


# TODO: kappa and bare mass are related
# TODO: varying parameters and modified constant parameters mustn't have a any
# common elements


############################ ENVIRONMENT VARIABLES #############################

# This section initializes essential environment variables, sets up logging, and
# verifies the validity of key directories and files required for execution of
# the main program's executable. It ensures that custom functions are sourced,
# the input file is loaded, and necessary directories (such as for parameter
# and log files) are created if they don't exist.

# LOG FILE
CURRENT_SCRIPT_NAME="$(basename "$0")"

# Current script's log file must be in script directory. Replace ".sh" with
# "_log.txt" to create the log file name and path
LOG_FILE_PATH=$(realpath \
                "./"$(echo "$CURRENT_SCRIPT_NAME" | sed 's/\.sh$/_log.txt/'))

# Create or override log file. Initiate logging
echo -e "\t\t"$(echo "$CURRENT_SCRIPT_NAME" | tr '[:lower:]' '[:upper:]') \
                "SCRIPT EXECUTION INITIATED\n" > "$LOG_FILE_PATH"

# Split logging into parts for readability
echo -e "\t\t** ENVIRONMENT VARIABLES **\n" >> "$LOG_FILE_PATH"

# Script termination message to be used for finalizing logging
export SCRIPT_TERMINATION_MESSAGE="\n\t\t"$(echo "$CURRENT_SCRIPT_NAME" \
                    | tr '[:lower:]' '[:upper:]')" SCRIPT EXECUTION TERMINATED"

# NOTE: "parameters_scan_project" directory path is set by "setup.sh" here and not
# in the input file to prevent accidental modification.
PARAMETERS_SCAN_PROJECT_DIRECTORY_FULL_PATH="/nvme/h/cy22sg1/qpb_branches/qpb_parameters_scan"
if [ ! -d "$PARAMETERS_SCAN_PROJECT_DIRECTORY_FULL_PATH" ]; then
    ERROR_MESSAGE="Invalid 'parameters_scan_project' directory path."
    echo "ERROR: "$ERROR_MESSAGE
    echo "Exiting..."
    # Log error explicitly since "log()" function hasn't been sourced yet
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] : $ERROR_MESSAGE" \
                                                            >> "$LOG_FILE_PATH"
    echo -e $SCRIPT_TERMINATION_MESSAGE >> "$LOG_FILE_PATH"
    exit 1
fi

# SOURCE LIBRARY SCRIPTS
# Source all custom functions scripts from "parameters_scan_project/library" using
# a loop avoiding this way name-specific sourcing and thus potential typos
sourced_scripts_count=0 # Initialize a counter for sourced files
for custom_functions_script in $(realpath \
                    "$PARAMETERS_SCAN_PROJECT_DIRECTORY_FULL_PATH/library"/*.sh);
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
"from parameters_scan_project/library were successfully sourced."
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
# And now all the custom functions can be used...
# NOTE: All "check_if" functions exit with error if they fail

# INPUT FILE
# NOTE: input.txt is placed in the script's directory by setup.sh
INPUT_FILE_PATH="./input.txt"
check_if_file_exists $INPUT_FILE_PATH "Input file $INPUT_FILE_PATH not found."
source "$INPUT_FILE_PATH" # Load all input file's contents
log "INFO" "File '"${INPUT_FILE_PATH}"' has been sourced properly."

check_if_file_exists $BINARY "Invalid main program's executable path."
log "INFO" "Main program's executable path is valid."

# NOTE: _params.ini_ is placed in the script's directory by setup.sh
check_if_file_exists $EMPTY_PARAMETERS_FILE_PATH \
                                        "Invalid empty parameters file path."
log "INFO" "Empty parameters file path is valid."
EMPTY_PARAMETERS_FILE_FULL_PATH=$(realpath $EMPTY_PARAMETERS_FILE_PATH)

# Check if parent directory of parameters files directory exists
# to validate the latter's directory path, as it may not exist yet.
check_if_directory_exists $(dirname $PARAMETERS_FILES_DIRECTORY) \
                "Parent directory of parameters files directory does not exist."
# Create parameters files directory if it doesn't already exist
if [ ! -d "$PARAMETERS_FILES_DIRECTORY" ]; then
    log "INFO" "Parameters files directory created."
    mkdir -p "$PARAMETERS_FILES_DIRECTORY"
else
    # Check if the existing directory is not empty
    if [ "$(ls -A "$PARAMETERS_FILES_DIRECTORY")" ]; then
        rm -rf "$PARAMETERS_FILES_DIRECTORY"/*
    fi
fi
log "INFO" "Parameters files directory path is valid."

check_if_directory_exists $GAUGE_LINKS_CONFIGURATIONS_DIRECTORY \
                                "Invalid gauge links configurations directory."
log "INFO" "Gauge links configurations directory path is valid."

# Check if parent directory of main program's log files directory exists
# to validate the latter's directory path, as it may not exist yet.
check_if_directory_exists $(dirname $LOG_FILES_DIRECTORY) \
                    "Parent directory of log files directory does not exist."
# Create executable's log files directory if it doesn't already exist
if [ ! -d "$LOG_FILES_DIRECTORY" ]; then
    log "INFO" "Main program's executable log files directory created."
    mkdir -p "$LOG_FILES_DIRECTORY"
else
    # Check if the existing directory is not empty
    if [ "$(ls -A "$LOG_FILES_DIRECTORY")" ]; then
        rm -rf "$LOG_FILES_DIRECTORY"/*
    fi
fi
log "INFO" "Main program's executable log files directory path is valid."

# Extract full path of current script's directory for later use
parameters_scan_script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if current script's directory path contains the substring "invert"
if [[ "${parameters_scan_script_directory}" == *"invert"* ]]; then
    # If it does then check "BINARY_SOLUTION_FILES_DIRECTORY" variable also
    check_if_directory_exists $BINARY_SOLUTION_FILES_DIRECTORY \
                                    "Invalid invert solution files directory."
    log "INFO" "Invert solution files directory path is valid."
fi

########################### PARAMETERS SPECIFICATION ###########################

echo -e "\n\t\t** PARAMETERS SPECIFICATION **\n" >> "$LOG_FILE_PATH"

# NON-ITERABLE PARAMETERS VALUES

# Extract non-iterable parameters values
OVERLAP_OPERATOR_METHOD=$(\
                extract_overlap_operator_method $parameters_scan_script_directory)
# TODO: Terminate if incorrect KERNEL_OPERATOR_TYPE_FLAG
KERNEL_OPERATOR_TYPE=$(extract_kernel_operator_type $KERNEL_OPERATOR_TYPE_FLAG)
QCD_BETA_VALUE=$(extract_QCD_beta_value "$GAUGE_LINKS_CONFIGURATIONS_DIRECTORY")
LATTICE_DIMENSIONS=$(\
            extract_lattice_dimensions "$GAUGE_LINKS_CONFIGURATIONS_DIRECTORY")

# Log non-iterable parameters values
non_iterable_parameters_values=$(\
        print_list_of_parameters NON_ITERABLE_PARAMETERS_NAMES_ARRAY -noindices)
log "INFO" \
"Non-iterable parameters values for execution:\n$non_iterable_parameters_values"

# NON-ITERABLE PARAMETERS TO BE PRINTED

# Check validity of LIST_OF_NON_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED array
validate_indices_array \
LIST_OF_NON_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED \
NON_ITERABLE_PARAMETERS_NAMES_ARRAY || { echo "Exiting..."; exit 1; }
log "INFO" "Valid elements passed to "\
"'LIST_OF_NON_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED' array."

# ITERABLE PARAMETERS VALUES

# Use current script's directory to choose among 6 iterable parameters arrays 
overlap_operator_method_label=${OVERLAP_OPERATOR_METHOD}
if [[ "${parameters_scan_script_directory}" == *"invert"* ]]; then
    overlap_operator_method_label+="_invert"
fi
iterable_parameters_names_array_name="${ITERABLE_PARAMETERS_NAMES_DICTIONARY[\
"$overlap_operator_method_label"]}"
log "INFO" "The iterable parameters names array that will be used is "\
"$iterable_parameters_names_array_name."

declare -n iterable_parameters_names_array="$iterable_parameters_names_array_name"

# VARYING ITERABLE PARAMETERS VALUES

# Before checking the validity of the VARYING_PARAMETERS_INDICES_LIST array,
# check its length. Check first if it's empty
if [ -z "${VARYING_PARAMETERS_INDICES_LIST}" ]; then
    ERROR_MESSAGE="'VARYING_PARAMETERS_INDICES_LIST' must not be empty."
    termination_output "${ERROR_MESSAGE}" "${SCRIPT_TERMINATION_MESSAGE}"
    echo "Exiting..."
    exit 1
fi
# Check then if VARYING_PARAMETERS_INDICES_LIST contains more than 3 indices
if [ "${#VARYING_PARAMETERS_INDICES_LIST[@]}" -gt 3 ]; then
    ERROR_MESSAGE="'VARYING_PARAMETERS_INDICES_LIST' must contain at most 3 "\
    "indices."
    termination_output "${ERROR_MESSAGE}" "${SCRIPT_TERMINATION_MESSAGE}"
    echo "Exiting..."
    exit 1
fi
# Check finally validity of VARYING_PARAMETERS_INDICES_LIST array
validate_indices_array VARYING_PARAMETERS_INDICES_LIST \
        iterable_parameters_names_array || { echo "Exiting..."; exit 1; }
log "INFO" "Valid elements passed to 'VARYING_PARAMETERS_INDICES_LIST' array."

# Check values passed to varying parameters set of values variables
varying_iterable_parameters_names_array=()
for list_index in "${!VARYING_PARAMETERS_INDICES_LIST[@]}"; do

    # Extract the corresponding parameter name to the varying parameter index
    varying_parameter_index=${VARYING_PARAMETERS_INDICES_LIST[$list_index]}
    varying_parameter_name="${iterable_parameters_names_array[$varying_parameter_index]}"
    varying_iterable_parameters_names_array+=("$varying_parameter_name")

    # Extract the name of the varying parameter values array
    varying_parameter_set_of_values_array_name=${VARYING_PARAMETERS_SET_OF_VALUES_ARRAYS_NAMES[$list_index]}

    if is_range_string $varying_parameter_set_of_values_array_name; then
        # Check if a range of values was requested
        range_of_values_function="${MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY[$varying_parameter_name]}"

        parameter_range_of_values_string=$(parameter_range_of_values_generator "$range_of_values_function" "$varying_parameter_set_of_values_array_name")
        
        declare -n array_to_modify="$varying_parameter_set_of_values_array_name"

        array_to_modify=($parameter_range_of_values_string)

    elif validate_varying_parameter_values_array_new \
                        $varying_parameter_name \
                            $varying_parameter_set_of_values_array_name; then
        # Or if a valid array of values was passed

        log "INFO" "Valid set of values passed to "\
        "'${varying_parameter_set_of_values_array_name}' array."
    else
        # Or in the case 

        log "Error" "Not valid input to ${varying_parameter_set_of_values_array_name} array."
    fi
done

# 
for ((index=${#VARYING_PARAMETERS_INDICES_LIST[@]}; index<3 ; index++)); do

    # Extract the name of the varying parameter values array
    varying_parameter_set_of_values_array_name=${VARYING_PARAMETERS_SET_OF_VALUES_ARRAYS_NAMES[$index]}

    declare -n array_to_modify="$varying_parameter_set_of_values_array_name"

    array_to_modify=("DUMMY_VALUE")
done

# CONSTANT ITERABLE PARAMETERS VALUES

# Check validity of passed elements of LIST_OF_UPDATED_CONSTANT_VALUES array
validate_updated_constant_parameters_array LIST_OF_UPDATED_CONSTANT_VALUES \
                                $iterable_parameters_names_array_name \
                                    varying_iterable_parameters_names_array
log "INFO" "Passed elements to 'LIST_OF_UPDATED_CONSTANT_VALUES' array "\
"are valid."
# Update values of constant iterable parameters
constant_parameters_update LIST_OF_UPDATED_CONSTANT_VALUES

# Check validity of LIST_OF_CONSTANT_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED
# array
validate_indices_array \
LIST_OF_CONSTANT_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED \
$iterable_parameters_names_array_name || { echo "Exiting..."; exit 1; }
# Check that no varying parameter indices were included
compare_no_common_elements VARYING_PARAMETERS_INDICES_LIST LIST_OF_CONSTANT_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED
if [ $? -eq 1 ]; then
    echo "Error: No varying parameters values can be printed as constant."
fi
log "INFO" "Passed elements to "\
"'LIST_OF_CONSTANT_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED' array are valid."

# Check if "GAUGE_LINKS_CONFIGURATION_LABEL" parameter is null
if [ "$GAUGE_LINKS_CONFIGURATION_LABEL" == "0000000" ]; then
    # If null then set "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH" to full path
    # of the very first file inside the "GAUGE_LINKS_CONFIGURATIONS_DIRECTORY"
    GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH=$(\
            find "$GAUGE_LINKS_CONFIGURATIONS_DIRECTORY" -type f | head -n 1)
    GAUGE_LINKS_CONFIGURATION_LABEL=$(extract_configuration_label_from_file \
                                    "$GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH")
fi



############################ TEMPLATE CONSTRUCTION #############################

echo -e "\n\t\t** TEMPLATE CONSTRUCTION **\n" >> "$LOG_FILE_PATH"

# Construct template's filename

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

for index in "${LIST_OF_CONSTANT_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED[@]}"; do

    parameter_name=${iterable_parameters_names_array[index]}
    parameter_value=${!iterable_parameters_names_array[index]}

    # if [ "$parameter_name" == "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH" ]; then
    #     parameter_value=$(\
    #   extract_configuration_label_from_file "$parameter_value")
    # fi

    parameter_label=${MODIFIABLE_PARAMETERS_LABELS_DICTIONARY[$parameter_name]}
    output_filename+="${parameter_label}"
    output_filename+="${parameter_value}_"
done

# If value is of decimal number format, replace "." with "p"
output_filename=$(modify_decimal_format "$output_filename")

output_filename="${output_filename%_}"

# Construct template's full file path
TEMPLATE_PARAMETERS_FILE_FULL_PATH="${PARAMETERS_FILES_DIRECTORY}"
TEMPLATE_PARAMETERS_FILE_FULL_PATH+="/params_${output_filename}.ini"

# Copy empty parameters file to parameters files directory
cp ${EMPTY_PARAMETERS_FILE_FULL_PATH} ${TEMPLATE_PARAMETERS_FILE_FULL_PATH}
if [ $? -ne 0 ]; then
    ERROR_MESSAGE="Copying '$EMPTY_PARAMETERS_FILE_FULL_PATH' file failed."
    termination_output "${ERROR_MESSAGE}" "${SCRIPT_TERMINATION_MESSAGE}"
    echo "Exiting..."
    exit 1
fi

# Concatenate the iterable and non-iterable parameters names arrays into one
constant_iterable_parameters_names_array=("${NON_ITERABLE_PARAMETERS_NAMES_ARRAY[@]}" "${iterable_parameters_names_array[@]}")

varying_parameters_names_array=()
for index in "${VARYING_PARAMETERS_INDICES_LIST[@]}"; do
    varying_parameters_names_array+=("${iterable_parameters_names_array[$index]}")
done

temp_array=()
for element in "${constant_iterable_parameters_names_array[@]}"; do
    # Check if the current element is not in the elements_to_remove array
    if [[ ! " ${varying_parameters_names_array[@]} " =~ " $element " ]]; then
        temp_array+=("$element")
    fi
done
constant_iterable_parameters_names_array=("${temp_array[@]}")

# Fill up the copied empty template with the values of the constant parameters
for parameter in "${constant_iterable_parameters_names_array[@]}"; do
    # Get the value of the value of the parameter
    parameter_value="${!parameter}"

    if [ $parameter == "GAUGE_LINKS_CONFIGURATION_LABEL" ]; then

        echo $parameter_value

        parameter="GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH"
        parameter_value=$(match_configuration_label_to_file $parameter_value)
    fi

    # Use sed to perform the replacement
    sed -i "s@_${parameter}_@${parameter_value}@g" \
                                        "$TEMPLATE_PARAMETERS_FILE_FULL_PATH"
done

############################### JOBS SUBMISSION ################################

echo -e "\n\t\t** JOBS SUBMISSION **\n\n" >> "$LOG_FILE_PATH"

# Path to generic job submissions script
GENERIC_RUN_FULL_PATH="${PARAMETERS_SCAN_PROJECT_DIRECTORY_FULL_PATH}"
GENERIC_RUN_FULL_PATH+="/main_scripts/generic_run.sh"
if [ ! -f "$GENERIC_RUN_FULL_PATH" ]; then
    echo "Invalid path to generic job submissions script."
    exit 1
fi

# TODO: Check input
# The number of tasks is calculated automatically from the given MPI geometry
NUMBER_OF_TASKS=($(convert_mpi_geometry_to_number_of_tasks $MPI_GEOMETRY))

# Extract varying parameters labels:
# Inner loop varying parameter label
inner_loop_varying_parameter_index=${VARYING_PARAMETERS_INDICES_LIST[0]}
inner_loop_varying_parameter_name=${iterable_parameters_names_array[\
                                           $inner_loop_varying_parameter_index]}
inner_loop_varying_parameter_label="${MODIFIABLE_PARAMETERS_LABELS_DICTIONARY[$inner_loop_varying_parameter_name]}"

# Outer loop varying parameter label, if parameter was declared
if [ "${#VARYING_PARAMETERS_INDICES_LIST[@]}" -ge 2 ]; then
    outer_loop_varying_parameter_index=${VARYING_PARAMETERS_INDICES_LIST[1]}
    outer_loop_varying_parameter_name=${iterable_parameters_names_array[\
                                           $outer_loop_varying_parameter_index]}
    outer_loop_varying_parameter_label="${MODIFIABLE_PARAMETERS_LABELS_DICTIONARY[$outer_loop_varying_parameter_name]}"
fi

# Overall outer loop varying parameter label, if it was declared
if [ "${#VARYING_PARAMETERS_INDICES_LIST[@]}" -eq 3 ]; then
overall_outer_loop_varying_parameter_index=${VARYING_PARAMETERS_INDICES_LIST[2]}
    overall_outer_loop_varying_parameter_name=${iterable_parameters_names_array[\
                                $overall_outer_loop_varying_parameter_index]}
    overall_outer_loop_varying_parameter_label="${MODIFIABLE_PARAMETERS_LABELS_DICTIONARY[$overall_outer_loop_varying_parameter_name]}"
fi



# Construct parameters file and submit job for each combination of values
for overall_outer_loop_varying_parameter_value in \
                  "${OVERALL_OUTER_LOOP_VARYING_PARAMETER_SET_OF_VALUES[@]}"; do
    # Configure printed substring of the overall outer loop varying parameter
    if [ $overall_outer_loop_varying_parameter_value != "DUMMY_VALUE" ]; then
        # if value if the configuration file path, extract label
        if [ $overall_outer_loop_varying_parameter_label == "config" ]; then
            printed_overall_outer_loop_varying_parameter_value="$overall_outer_loop_varying_parameter_value"
            # $(\
            # extract_configuration_label_from_file "$overall_outer_loop_varying_parameter_value")
            overall_outer_loop_varying_parameter_name="GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH"
            overall_outer_loop_varying_parameter_value=$(match_configuration_label_to_file "$overall_outer_loop_varying_parameter_value")
        else
            # If value is of decimal number format, replace "." with "p"
            printed_overall_outer_loop_varying_parameter_value=$(\
            modify_decimal_format "$overall_outer_loop_varying_parameter_value")
        fi
        # Construct substring to be printed
        label=${overall_outer_loop_varying_parameter_label}
        value=${printed_overall_outer_loop_varying_parameter_value}
       overall_outer_loop_varying_parameter_label_with_value="_${label}${value}"
    else
        # Print nothing if overall outer loop varying parameter not declared
        overall_outer_loop_varying_parameter_label_with_value=""
    fi

    for outer_loop_varying_parameter_value in \
                          "${OUTER_LOOP_VARYING_PARAMETER_SET_OF_VALUES[@]}"; do
        # Configure printed substring of the outer loop varying parameter
        if [ $outer_loop_varying_parameter_value != "DUMMY_VALUE" ]; then
            # if value if the configuration file path, extract label
            if [ $outer_loop_varying_parameter_label == "config" ]; then
                printed_outer_loop_varying_parameter_value="$outer_loop_varying_parameter_value"
                # $(\
                # extract_configuration_label_from_file "$outer_loop_varying_parameter_value")
                outer_loop_varying_parameter_name="GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH"
                outer_loop_varying_parameter_value=$(match_configuration_label_to_file "$outer_loop_varying_parameter_value")
            else
                # If value is of decimal number format, replace "." with "p"
                printed_outer_loop_varying_parameter_value=$(\
                modify_decimal_format "$outer_loop_varying_parameter_value")
            fi
            # Construct substring to be printed
            label=${outer_loop_varying_parameter_label}
            value=${printed_outer_loop_varying_parameter_value}
            outer_loop_varying_parameter_label_with_value="_${label}${value}"
        else
            # Print nothing if outer loop varying parameter not declared
            outer_loop_varying_parameter_label_with_value=""
        fi
        
        for inner_loop_varying_parameter_value in \
                          "${INNER_LOOP_VARYING_PARAMETER_SET_OF_VALUES[@]}"; do
            # Configure printed substring of the inner loop varying parameter
            # if value if the configuration file path, extract label
            if [ $inner_loop_varying_parameter_label == "config" ]; then
                printed_inner_loop_varying_parameter_value="$inner_loop_varying_parameter_value"
                # $(\
                # extract_configuration_label_from_file "$inner_loop_varying_parameter_value")
                inner_loop_varying_parameter_name="GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH"
                inner_loop_varying_parameter_value=$(match_configuration_label_to_file "$inner_loop_varying_parameter_value")
            else
                # If value is of decimal number format, replace "." with "p"
                printed_inner_loop_varying_parameter_value=$(\
                    modify_decimal_format "$inner_loop_varying_parameter_value")
            fi
            # Construct substring to be printed
            label=${inner_loop_varying_parameter_label}
            value=${printed_inner_loop_varying_parameter_value}
            inner_loop_varying_parameter_label_with_value="_${label}${value}"

            # Construct the parameters file filename and full path. Use the name
            # of the template file and append another substring at the end for 
            # the values of the varying parameters
        overall_suffix=${overall_outer_loop_varying_parameter_label_with_value}
            outer_suffix=${outer_loop_varying_parameter_label_with_value}
            inner_suffix=${inner_loop_varying_parameter_label_with_value}
            appended_suffix="${overall_suffix}${outer_suffix}${inner_suffix}"

            file_path=$TEMPLATE_PARAMETERS_FILE_FULL_PATH
     filled_parameters_file_full_path="${file_path/.ini/${appended_suffix}.ini}"

            # Create parameters file from template with varying parameters lines
            # still unfilled
            cp ${TEMPLATE_PARAMETERS_FILE_FULL_PATH} \
                                             ${filled_parameters_file_full_path}

            # Fill in the varying parameters lines
            # Inner loop 
            parameter_name=$inner_loop_varying_parameter_name
            parameter_value=$inner_loop_varying_parameter_value
            sed -i "s@_${parameter_name}_@${parameter_value}@g" \
                                             "$filled_parameters_file_full_path"

            # Outer loop
            if [ "$outer_loop_varying_parameter_value" != "DUMMY_VALUE" ]; then
                parameter_name=$outer_loop_varying_parameter_name
                parameter_value=$outer_loop_varying_parameter_value
                sed -i "s@_${parameter_name}_@${parameter_value}@g" \
                                             "$filled_parameters_file_full_path"
            fi

            # Overall outer loop
          if [ "$overall_outer_loop_varying_parameter_value" != "DUMMY_VALUE" ];
             then
                parameter_name=$overall_outer_loop_varying_parameter_name
                parameter_value=$overall_outer_loop_varying_parameter_value
                sed -i "s@_${parameter_name}_@${parameter_value}@g" \
                                             "$filled_parameters_file_full_path"
            fi

            # For invert main progs, the binary solutions file full path needs
            # to be specified as well inside the parameters file
            if [[ "$parameters_scan_script_directory" == *"invert"* ]]; then
                binary_solution_file_full_path=$BINARY_SOLUTION_FILES_DIRECTORY
                binary_solution_file_full_path+="/solx12_"
                binary_solution_file_full_path+="${output_filename}"
                binary_solution_file_full_path+="${appended_suffix}.dat"
                parameter_name="BINARY_SOLUTION_FILES_DIRECTORY"
                parameter_value=$binary_solution_file_full_path
                sed -i "s@_${parameter_name}_@${parameter_value}@g" \
                                             "$filled_parameters_file_full_path"
            fi

            # USER INPUT: Set SLURM sbatch options
            JOB_NAME="${appended_suffix}_${output_filename}"
            JOB_NAME=$(echo "$JOB_NAME" | sed 's/_//g')
            OUTPUT_FILE="${LOG_FILES_DIRECTORY}/${output_filename}"
            OUTPUT_FILE+="${appended_suffix}.txt"
            ERROR_FILE="${LOG_FILES_DIRECTORY}/${output_filename}"
            ERROR_FILE+="${appended_suffix}.err"

            # Submit job
            SBATCH_OPTIONS="--job-name=${JOB_NAME} \
                            --error=${ERROR_FILE} \
                            --output=${OUTPUT_FILE} \
                            --nodes=${NUMBER_OF_NODES} \
                            --ntasks-per-node=${NTASKS_PER_NODE} \
                            --time=${WALLTIME} \
                            --partition=${PARTITION_NAME}"
                            # --reservation=short \

            sbatch ${SBATCH_OPTIONS} ${GENERIC_RUN_FULL_PATH} \
                                ${BINARY} ${MPI_GEOMETRY} \
                                    ${filled_parameters_file_full_path} \
                                        ${NUMBER_OF_TASKS}

        done
    done
done

# Construct the final message
final_message="${CURRENT_SCRIPT_NAME} processes complete!"
# Print the final message
echo "$final_message"

echo -e "\n" >> "$LOG_FILE_PATH"
log "INFO" "${final_message}"

echo -e $SCRIPT_TERMINATION_MESSAGE >> "$LOG_FILE_PATH"
exit 1

