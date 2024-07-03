#!/bin/bash

# Check that the "MODIFIABLE_PARAMETERS_LIST" contains names of constants which have been already set and are not empty, namely with a predefined value
for modifiable_parameter in "${MODIFIABLE_PARAMETERS_LIST[@]}"; do
    # Check if parameter is set
    if [[ ! ${!modifiable_parameter+x} ]]; then
        echo "Warning: Variable '$modifiable_parameter' is not defined."
    # Check if parameter is not empty
    elif [[ -z ${!modifiable_parameter} ]]; then
        echo "Warning: Variable '$modifiable_parameter' is defined but empty."
    fi
done

# TODO:  all the modifiable parameters
    # Check if parameter is set and not empty
