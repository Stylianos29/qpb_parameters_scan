#!/bin/bash -l

################################################################################
# batch_process_invert_solutions.sh.sh
#
# Description: This script generates parameters and data files for mesons main
# program the "qpb" project. It takes care of validating directories,
# constructing parameter files from templates, and submits jobs to the cluster
# using mpirun for execution.
#
# Purpose:
# - This script processes binary invert solution files from specified directory.
# - It generates parameters files and output data files by replacing
#   placeholders in a template and executing a job with them.
# - The script supports user customization through positional arguments,
#   allowing users to specify the invert solution directory, remove previously
#   past generated files, and display a usage guide.
#
# Usage:
# - To run the script normally: ./data_files_generation.sh
#
# - To specify a custom invert solution directory: ./data_files_generation.sh -p
#   /path/to/invert_solutions
#
# - To remove generated files inside the PARAMETERS_FILES_DIRECTORY and
#   MESONS_DATA_FILES_DIRECTORY: ./data_files_generation.sh -r
#
# - To display usage information: ./data_files_generation.sh -u
#
# Note:
# - Ensure the directories and files involved are correctly set up before
#   running the script.
################################################################################

#SBATCH --job-name=data_files_generation
#SBATCH --nodes=1
#SBATCH --time=01:00:00
#SBATCH --error=data_files_generation.err
#SBATCH --output=data_files_generation.txt
#SBATCH --ntasks-per-node=16
#SBATCH --partition=p100


module purge
module load Anaconda3
module load GSL
module load gompi


check_if_directory_exists() {
    local directory="$1"
    local create_if_missing="$2"
    
    if [ ! -d "$directory" ]; then
        echo "Directory '$directory' does not exist."
        
        if [ "$create_if_missing" = true ]; then
            mkdir -p "$directory"
            echo "Directory '$directory' was created."
        else
            echo "Directory '$directory' was not created."
            exit 1
        fi
    fi
}

# Display usage information
show_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -p, --path      Specify the path to the INVERT_SOLUTIONS_DIRECTORY"
    echo "  -r, --remove    Remove all files inside PARAMETERS_FILES_DIRECTORY"\
" and MESONS_DATA_FILES_DIRECTORY"
    echo "  -u, --usage     Show this usage information"
    exit 0
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--path)
            INVERT_SOLUTIONS_DIRECTORY="$2"
            shift 2
            ;;
        -r|--remove)
            REMOVE_FILES=true
            shift
            ;;
        -u|--usage)
            show_usage
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            ;;
    esac
done

# Set default value for INVERT_SOLUTIONS_DIRECTORY if not set by user
if [ -z "$INVERT_SOLUTIONS_DIRECTORY" ]; then
    INVERT_SOLUTIONS_DIRECTORY="${HOME}/scratch/invert_solutions_files/Chebyshev"
fi
check_if_directory_exists "$INVERT_SOLUTIONS_DIRECTORY" false

PARAMETERS_FILES_DIRECTORY="./parameters_files"
check_if_directory_exists "$PARAMETERS_FILES_DIRECTORY" true

MESONS_DATA_FILES_DIRECTORY="./mesons_data_files"
check_if_directory_exists "$MESONS_DATA_FILES_DIRECTORY" true

# Remove all files inside PARAMETERS_FILES_DIRECTORY and
# MESONS_DATA_FILES_DIRECTORY if requested
if [ "$REMOVE_FILES" = true ]; then
    rm -rf "$PARAMETERS_FILES_DIRECTORY"/*
    rm -rf "$MESONS_DATA_FILES_DIRECTORY"/*
    echo "All files inside '$PARAMETERS_FILES_DIRECTORY' " \
"and '$MESONS_DATA_FILES_DIRECTORY' have been removed."
    echo # new line
fi

# Loop over all files inside subdirectory
for invert_solution_file_path in "$INVERT_SOLUTIONS_DIRECTORY/"*; do

    if [ ! -f "$invert_solution_file_path" ]; then
        continue
    fi

    invert_solution_filename=$(basename "$invert_solution_file_path")

    parameters_file_path="$PARAMETERS_FILES_DIRECTORY"
    parameters_file_path+="/params_${invert_solution_filename}.ini"

    output_data_file_path="$MESONS_DATA_FILES_DIRECTORY"
    output_data_file_path+="/${invert_solution_filename}.dat"
    
    # Construct specific parameters files by passing the invert binary solution
    # file path and the output data file path
    cat ./_params.ini_ | sed \
        -e "s@_INVERT_BINARY_SOLUTION_FILE_PATH_@${invert_solution_file_path}@"\
        -e "s@_OUTPUT_DATA_FILE_@${output_data_file_path}@" \
        > "$parameters_file_path"

    mpirun -n 8 --bind-to core --report-bindings ../mesons geom=2,2,2 \
                                                        "$parameters_file_path"

    echo # new line
done

echo "Mesons data files generation completed!"
