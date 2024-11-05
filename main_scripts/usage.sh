#!/bin/bash

# TODO: Write description
######################################################################
# usage.sh - Script for displaying parameters information
#
#
######################################################################


# SOURCE LIBRARY SCRIPTS

# NOTE: "qpb_parameters_scan" project directory path is set by "setup.sh" here
# and not in the input file to prevent accidental modification.
QPB_PARAMETERS_SCAN_PROJECT_DIRECTORY_FULL_PATH=
if [ ! -d "$QPB_PARAMETERS_SCAN_PROJECT_DIRECTORY_FULL_PATH" ]; then
    ERROR_MESSAGE="Invalid 'qpb_parameters_scan' project directory path."
    echo "ERROR: "$ERROR_MESSAGE
    echo "Exiting..."
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
if [ $sourced_scripts_count -eq 0 ]; then
    ERROR_MESSAGE="No custom functions scripts were sourced at all."
    echo "ERROR: "$ERROR_MESSAGE
    echo "Exiting..."
    exit 1
fi

# TODO: Move these custom functions to dedicated library script
# Define info functions for each variable
bare_mass_info() {
    echo "BARE_MASS: This parameter represents the bare mass used in the calculations."
}

gauge_links_configuration_label_info() {
    echo "GAUGE_LINKS_CONFIGURATION_LABEL: This parameter specifies the configuration label for gauge links."
}

number_of_vectors_info() {
    echo "NUMBER_OF_VECTORS: This parameter indicates the number of vectors in the setup."
}

ape_iterations_info() {
    echo "APE_ITERATIONS: This parameter sets the number of APE iterations to perform."
}

ape_alpha_info() {
    echo "APE_ALPHA: This parameter determines the alpha value for the APE smearing."
}

rho_value_info() {
    echo "RHO_VALUE: This parameter sets the Rho value in the simulations."
}

kappa_value_info() {
    echo "KAPPA_VALUE: This parameter represents the Kappa value for the simulations."
}

clover_term_coefficient_info() {
    echo "CLOVER_TERM_COEFFICIENT: This parameter is the coefficient used in the Clover term."
}

# Main logic to display information based on user input
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <parameter_name>"
    echo "Available parameters:"
    for param in "${COMMON_ITERABLE_PARAMETERS_NAMES_ARRAY[@]}"; do
        echo "- $param"
    done
    exit 1
fi

param_name="$1"

# Lookup and call the corresponding info function
case "$param_name" in
    "BARE_MASS") bare_mass_info ;;
    "GAUGE_LINKS_CONFIGURATION_LABEL") gauge_links_configuration_label_info ;;
    "NUMBER_OF_VECTORS") number_of_vectors_info ;;
    "APE_ITERATIONS") ape_iterations_info ;;
    "APE_ALPHA") ape_alpha_info ;;
    "RHO_VALUE") rho_value_info ;;
    "KAPPA_VALUE") kappa_value_info ;;
    "CLOVER_TERM_COEFFICIENT") clover_term_coefficient_info ;;
    *) 
        echo "Error: Unknown parameter name '$param_name'."
        exit 1
        ;;
esac
