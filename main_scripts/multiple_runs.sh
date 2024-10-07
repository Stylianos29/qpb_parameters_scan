#!/bin/bash


######################################################################
# main_scripts/multiple_runs.sh
#
# This is the main script of the project; 
# * It begins with comprehensive check of all the passed paths from input.txt
# * It will create a log file
# * Convention: capital letters indicate 
#
# Author: Stylianos Gregoriou Date last modified: 7th Oct 2024
#
# Usage: 
#
######################################################################


# ENVIRONMENT VARIABLES

# NOTE: input.txt is placed in the script's directory by setup.sh
INPUT_FILE_PATH="./input.txt" 

# Check if the input file exists
if [[ -f "$INPUT_FILE_PATH" ]]; then
    # If it exists, then source the input file to load its contents
    source "$INPUT_FILE_PATH"
else
    # Exit with error if the input file is not found
    echo "Input file $INPUT_FILE_PATH not found."
    echo "Exiting..."
    exit 1
fi

# Check validity of the "multiple_runs_project" directory path from input file
if [ ! -d "$MULTIPLE_RUNS_PROJECT_FULL_PATH" ]; then
    echo "Invalid 'multiple_runs_project' directory path."
    echo "Exiting..."
    exit 1
fi

# Source all custom functions scripts from "multiple_runs_project/library" using
# a loop avoiding this way name-specific sourcing and thus potential typos
for custom_functions_script in "$MULTIPLE_RUNS_PROJECT_FULL_PATH/library"/*.sh;
do
    if [ -f "$custom_functions_script" ]; then
        source "$custom_functions_script"
    fi
done
# And now all the custom functions can be used...

# Check validity of current script's log file directory path; exit if not valid
check_if_directory_exists $MULTIPLE_RUNS_SCRIPT_LOG_FILE_DIRECTORY \
                            "Invalid current script's log file directory path."
# Construct then path of log file. By default its name matches script's name
multiple_runs_script_log_file_path="${MULTIPLE_RUNS_SCRIPT_LOG_FILE_DIRECTORY}"
multiple_runs_script_log_file_path+=$(basename "$0" .sh)"_log.txt"

check_if_file_exists $BINARY "Invalid binary executable path."
check_if_file_exists $EMPTY_PARAMETERS_FILE_PATH \
                                        "Invalid empty parameters file path."

# Check if the parent directory of the log files directory exists
check_if_directory_exists $(dirname $LOG_FILES_DIRECTORY) \
                    "Parent directory of log files directory does not exist."
# Create log files directory if it doesn't already exist
if [ ! -d "$LOG_FILES_DIRECTORY" ]; then
    echo "Log files directory created."
    mkdir -p "$LOG_FILES_DIRECTORY"
fi

# Check if the parent directory of the parameters files directory exists
check_if_directory_exists $(dirname $PARAMETERS_FILES_DIRECTORY) \
                "Parent directory of parameters files directory does not exist."
# Create parameters files directory if it doesn't already exist
if [ ! -d "$PARAMETERS_FILES_DIRECTORY" ]; then
    echo "Parameters files directory created."
    mkdir -p "$PARAMETERS_FILES_DIRECTORY"
fi

check_if_directory_exists $GAUGE_LINKS_CONFIGURATIONS_DIRECTORY \
                                "Invalid gauge links configurations directory."

# Extract full path of current script's directory for later use
multiple_runs_script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if current script's directory path contains the substring "invert"
if [[ "${multiple_runs_script_directory}" == *"invert"* ]]; then
    # If it does then there's also a "BINARY_SOLUTION_FILES_DIRECTORY" variable
    check_if_directory_exists $BINARY_SOLUTION_FILES_DIRECTORY \
                                "Invalid binary solution files directory."
fi


# PARAMETERS SPECIFICATION

# Category A:

# The operator method is extracted automatically from current directory path
OPERATOR_METHOD=($(extract_operator_method $multiple_runs_script_directory))

OPERATOR_TYPE=($(extract_operator_type "$OPERATOR_TYPE_FLAG"))

QCD_BETA_VALUE=($(extract_QCD_beta_value "$GAUGE_LINKS_CONFIGURATIONS_DIRECTORY"))

# Category B:

# TODO: Maybe the printed value of the APE iters parameter must depend on 
# whether already smeared configurations were used.

validate_indices_array "LIST_OF_PARAMETERS_INDICES_TO_BE_PRINTED" \
                                            || { echo "Exiting..."; exit 1; }

# Category C:

validate_updated_constant_parameters_array \
    "${LIST_OF_UPDATED_CONSTANT_VALUES[@]}" || { echo "Exiting..."; exit 1; }

constant_parameters_update "${LIST_OF_UPDATED_CONSTANT_VALUES[@]}"

# Check if "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH" parameter is null
if [ "$GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH" == "0000000" ]; then
    # If null then set "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH" to full path
    # of the very first file inside the "GAUGE_LINKS_CONFIGURATIONS_DIRECTORY"
    GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH=$(\
            find "$GAUGE_LINKS_CONFIGURATIONS_DIRECTORY" -type f | head -n 1)
fi

# Check all parameter values thus far, apart from the 
# "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH" one since it's been already tested
for parameter_name in "${!MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY[@]}";
 do
    if [ "$parameter_name" != "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH" ]; then
        check_function="\
            ${MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY[$parameter_name]}"
        # Indirect reference to get the value of the constant parameter_name
        parameter_value="${!parameter_name}"
        # Parameter value check
        result=$($check_function "$parameter_value")
        if [ "$result" -ne 0 ]; then
            echo "Validation failed for parameter $parameter_name with"\
            "value $parameter_value"
            exit 1
        fi
    fi
done

# Category D:

validate_indices_array "VARYING_PARAMETERS_INDICES_LIST" \
                                            || { echo "Exiting..."; exit 1; }

# Additionally check the length of the VARYING_PARAMETERS_INDICES_LIST array
# Check if VARYING_PARAMETERS_INDICES_LIST is empty
if [ -z "${VARYING_PARAMETERS_INDICES_LIST}" ]; then
    echo "'VARYING_PARAMETERS_INDICES_LIST' must not be empty."
    echo "Exiting..."
    exit 1
fi
# Check if VARYING_PARAMETERS_INDICES_LIST contains more than 3 indices
if [ "${#VARYING_PARAMETERS_INDICES_LIST[@]}" -gt 3 ]; then
    echo "'VARYING_PARAMETERS_INDICES_LIST' must contain at most 3 indices."
    echo "Exiting..."
    exit 1
fi

# Check validity of the past set or range of values of the varying parameters
# If arrays are empty, then append a single dummy element: "DUMMY_VALUE"

# INNER_LOOP
validate_varying_parameter_values_array 0 \
            INNER_LOOP_VARYING_PARAMETER_SET_OF_VALUES

# OUTER_LOOP
if [ "${#VARYING_PARAMETERS_INDICES_LIST[@]}" -ge 2 ]; then
    validate_varying_parameter_values_array 1 \
                OUTER_LOOP_VARYING_PARAMETER_SET_OF_VALUES
else
    OUTER_LOOP_VARYING_PARAMETER_SET_OF_VALUES=("DUMMY_VALUE")
fi

# OVERALL_OUTER_LOOP
if [ "${#VARYING_PARAMETERS_INDICES_LIST[@]}" -eq 3 ]; then
    validate_varying_parameter_values_array 2 \
                OVERALL_OUTER_LOOP_VARYING_PARAMETER_SET_OF_VALUES
else
    OVERALL_OUTER_LOOP_VARYING_PARAMETER_SET_OF_VALUES=("DUMMY_VALUE")
fi


# TEMPLATE CONSTRUCTION

# TODO: Add a beta value option
# Construct template's filename
printed_constant_parameters=${OPERATOR_METHOD}_${OPERATOR_TYPE}
for index in "${LIST_OF_PARAMETERS_INDICES_TO_BE_PRINTED[@]}"; do

    printed_constant_parameter_label=${MODIFIABLE_PARAMETERS_LABELS_LIST[index]}
    printed_constant_parameter_value=${!MODIFIABLE_PARAMETERS_LIST[index]}

    # For the case of the "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH" parameter,
    # only the the configuration labels needs to be printed
    if [ "$printed_constant_parameter_label" == "config" ]; then
        printed_constant_parameter_value=$(\
      extract_configuration_label_from_file "$printed_constant_parameter_value")
    else
        # If value is of decimal number format, replace "." with "p"
        printed_constant_parameter_value=$(\
                    modify_decimal_format "$printed_constant_parameter_value")
    fi

    printed_constant_parameters+="_${printed_constant_parameter_label}"
    printed_constant_parameters+="${printed_constant_parameter_value}"
done

# Construct template's full file path
TEMPLATE_PARAMETERS_FILE_FULL_PATH="${PARAMETERS_FILES_DIRECTORY}"
TEMPLATE_PARAMETERS_FILE_FULL_PATH+="/params_${printed_constant_parameters}.ini"

# Copy empty parameters file to parameters files directory
cp ${EMPTY_PARAMETERS_FILE_FULL_PATH} ${TEMPLATE_PARAMETERS_FILE_FULL_PATH}

# Construct a list of constant parameters by excluding the varying ones
constant_parameters_list=()
read -r -a constant_parameters_list <<<\
    "$(exclude_elements_from_modifiable_parameters_list_by_index\
         ${VARYING_PARAMETERS_INDICES_LIST[@]})"

# TODO: Check which if parameters are appropriate for selected operator method

# Fill up the copied empty template with the values of the constant parameters
for parameter in "${constant_parameters_list[@]}"; do

    # For invert main progs parameter KAPPA is used instead of BARE_MASS
    if [[ ($parameter == "BARE_MASS")\
                    && ("$multiple_runs_script_directory" == *"invert"*) ]]; then
        parameter="KAPPA"
        KAPPA=$(calculate_kappa_value "$BARE_MASS")
    fi

    # Get the value of the value of the parameter
    parameter_value="${!parameter}"
    # Use sed to perform the replacement
    sed -i "s@_${parameter}_@${parameter_value}@g" \
                    "$TEMPLATE_PARAMETERS_FILE_FULL_PATH"
done


# JOBS SUBMISSION

# Path to generic job submissions script
GENERIC_RUN_FULL_PATH="${MULTIPLE_RUNS_PROJECT_FULL_PATH}"
GENERIC_RUN_FULL_PATH+="/main_scripts/generic_run.sh"
if [ ! -f "$GENERIC_RUN_FULL_PATH" ]; then
    echo "Invalid path to generic job submissions script."
    exit 1
fi

# The number of tasks is calculated automatically from the given MPI geometry
NUMBER_OF_TASKS=($(convert_mpi_geometry_to_number_of_tasks $MPI_GEOMETRY))

# Extract varying parameters labels:
# Inner loop varying parameter label
inner_loop_varying_parameter_index=${VARYING_PARAMETERS_INDICES_LIST[0]}
inner_loop_varying_parameter_name=${MODIFIABLE_PARAMETERS_LIST[\
                                           $inner_loop_varying_parameter_index]}
inner_loop_varying_parameter_label="${MODIFIABLE_PARAMETERS_LABELS_DICTIONARY[$inner_loop_varying_parameter_name]}"

# Outer loop varying parameter label, if parameter was declared
if [ "${#VARYING_PARAMETERS_INDICES_LIST[@]}" -ge 2 ]; then
    outer_loop_varying_parameter_index=${VARYING_PARAMETERS_INDICES_LIST[1]}
    outer_loop_varying_parameter_name=${MODIFIABLE_PARAMETERS_LIST[\
                                           $outer_loop_varying_parameter_index]}
    outer_loop_varying_parameter_label="${MODIFIABLE_PARAMETERS_LABELS_DICTIONARY[$outer_loop_varying_parameter_name]}"
fi

# Overall outer loop varying parameter label, if it was declared
if [ "${#VARYING_PARAMETERS_INDICES_LIST[@]}" -eq 3 ]; then
overall_outer_loop_varying_parameter_index=${VARYING_PARAMETERS_INDICES_LIST[2]}
    overall_outer_loop_varying_parameter_name=${MODIFIABLE_PARAMETERS_LIST[\
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
            printed_overall_outer_loop_varying_parameter_value=$(\
            extract_configuration_label_from_file "$overall_outer_loop_varying_parameter_value")
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
                printed_outer_loop_varying_parameter_value=$(\
                extract_configuration_label_from_file "$outer_loop_varying_parameter_value")
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
                printed_inner_loop_varying_parameter_value=$(\
                extract_configuration_label_from_file "$inner_loop_varying_parameter_value")
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
            if [[ "$multiple_runs_script_directory" == *"invert"* ]]; then
                binary_solution_file_full_path=$BINARY_SOLUTION_FILES_DIRECTORY
                binary_solution_file_full_path+="/solx12_"
                binary_solution_file_full_path+="${printed_constant_parameters}"
                binary_solution_file_full_path+="${appended_suffix}.dat"
                parameter_name="BINARY_SOLUTION_FILES_DIRECTORY"
                parameter_value=$binary_solution_file_full_path
                sed -i "s@_${parameter_name}_@${parameter_value}@g" \
                                             "$filled_parameters_file_full_path"
            fi

            # USER INPUT: Set SLURM sbatch options
            JOB_NAME="${appended_suffix}_${printed_constant_parameters}"
            JOB_NAME=$(echo "$JOB_NAME" | sed 's/_//g')
            OUTPUT_FILE="${LOG_FILES_DIRECTORY}/${printed_constant_parameters}"
            OUTPUT_FILE+="${appended_suffix}.txt"
            ERROR_FILE="${LOG_FILES_DIRECTORY}/${printed_constant_parameters}"
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

# echo "All good!"
