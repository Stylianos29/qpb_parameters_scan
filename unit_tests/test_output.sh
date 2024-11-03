#!/bin/bash


# TODO: Write description
######################################################################
# unit_tests/test_output.sh - Script for 
#
#
######################################################################


# SOURCE DEPENDENCIES

LIBRARY_SCRIPTS_DIRECTORY_FULL_PATH="$(realpath ../library)"
# Source all custom functions scripts from "qpb_parameters_scan/library" using a
# loop avoiding this way name-specific sourcing and thus potential typos
for library_script in "$LIBRARY_SCRIPTS_DIRECTORY_FULL_PATH";
do
    # Check if the current file in the loop is a regular file
    if [ -f "$library_script" ]; then
        source "$library_script"
    fi
done
unset LIBRARY_SCRIPTS_DIRECTORY_FULL_PATH

# COMMAND-LINE ARGUMENTS CHECKS

unittest_option_default_value="-v"
# Check if an argument is provided; if not, use the default value
unittest_option=${1:-$unittest_option_default_value}

# CUSTOM FUNCTIONS UNIT TESTS

test_convert_mpi_geometry_to_number_of_tasks()
{
    test_mpi_geometry_string="2,2,2"
    expected_number_of_tasks="8"

    number_of_tasks=($(convert_mpi_geometry_to_number_of_tasks \
                                                    $test_mpi_geometry_string))

    assert ${number_of_tasks} ${expected_number_of_tasks}
}
