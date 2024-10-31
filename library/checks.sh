#!/bin/bash


######################################################################
# library/checks.sh - ?
#
# This script contains a collection of custom Bash functions ?
#
# Author: Stylianos Gregoriou
# Date last modified: 22nd May 2024
#
# Usage: Source this script in other Bash scripts to access the
#        custom functions defined herein.
#
######################################################################


# Prevent multiple sourcing of this script by exiting if CHECKS_SH is already
# set. Otherwise, set CHECKS_SH to mark it as sourced.
[[ -n "${CHECKS_SH}" ]] && return
CHECKS_SH=1

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


check_parameter_name()
{
:   '
    Function to check if a parameter name is in the MODIFIABLE_PARAMETERS_LIST
    array
    Usage:      check_parameter_name <parameter_name>
    Arguments:      parameter_name: The name of the parameter to check.
    Output:
        - Echoes 0 if the parameter name is in the MODIFIABLE_PARAMETERS_LIST 
        array.
        - Echoes 1 if the parameter name is not in the 
        MODIFIABLE_PARAMETERS_LIST array.
    Example:      check_parameter_name "LATTICE_DIMENSIONS"
    Output:
        - If the parameter name is found, it will echo 0.
        - If the parameter name is not found, it will echo 1.
    '
    
    local parameter_name="$1"

    for param in "${MODIFIABLE_PARAMETERS_LIST[@]}"; do
        if [ "$param" == "$parameter_name" ]; then
            echo 0
            return 0
        fi
    done

    echo 1
    return 1
}


check_operator_type()
{
:   '
    Function to check if a given operator type is valid.
    Usage: check_operator_type $operator_type
    Arguments:
        * operator_type: The operator type to be checked against the valid 
        operator types.
    Output:
        Prints 0 if the operator type is valid (i.e., it is one of the elements 
        in OPERATOR_TYPES_ARRAY), otherwise 
        prints 1 if it is not valid.
    Example:
        is_valid=$(check_operator_type "Brillouin")
        if [ "$is_valid" -eq 0 ]; then
            echo "Operator type is valid."
        else
            echo "Operator type is invalid."
        fi
    Notes:
        - The function iterates over the OPERATOR_TYPES_ARRAY constant array to 
        check for a match.
        - The function prints 0 (true) if the operator type is found in the 
        array.
        - The function prints 1 (false) if the operator type is not found in the
         array.
    '

    local operator_type="$1"

    for valid_operator in "${OPERATOR_TYPES_ARRAY[@]}"; do
        if [ "$operator_type" == "$valid_operator" ]; then
            echo 0  # True
            return
        fi
    done

    echo 1  # False
}


check_rho_value()
{
:   '
    Function to check if the 'rho' parameter is a valid numerical value greater
     than 0 and smaller than 2
    Usage:    check_rho_value <rho>
    Arguments:    rho: The value of the rho parameter to check.
    Output:
        - Echoes 0 if the value is a valid numerical value greater than 0 and
         smaller than 2.
        - Echoes 1 if the value is not valid.
    Example:
        check_rho_value 1.5
    Output:
        - If the value is valid, it will echo 0.
        - If the value is not valid, it will echo 1.
    Notes:
        - The function uses regex to check if the value is a number.
        - The function checks if the value is within the valid range (0, 2).
    '

    local rho="$1"

    # Check if the value is a number
    if ! [[ "$rho" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        echo 1
        return 1
    fi

    # Check if the value is greater than 0 and smaller than 2
    if (( $(echo "$rho <= 0" | bc -l) )) || (( $(echo "$rho >= 2" | bc -l) ));
    then
        echo 1
        return 1
    fi

    # If all checks pass, return success
    echo 0
    return 0
}




# }
# # Loop through the associative array to perform checks
# for parameter in "${!MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY[@]}"; do
#     check_function="${MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY[$parameter]}"
#     value="${!parameter}" # Indirect reference to get the value of the constant parameter
    
#     result=$($check_function "$value")
#     if [ "$result" -ne 0 ]; then
#         echo "Validation failed for parameter $parameter with value $value"
#         exit 1
#     else
#         echo "Validation succeeded for parameter $parameter with value $value"
#     fi
# done
# }