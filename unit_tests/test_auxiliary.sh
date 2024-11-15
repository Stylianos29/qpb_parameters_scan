#!/bin/bash


# TODO: Write description
######################################################################
# unit_tests/test_auxiliary.sh - Script for 
#
#
######################################################################


# SOURCE DEPENDENCIES

LIBRARY_SCRIPTS_DIRECTORY_FULL_PATH="$(realpath ../library)"
# Source all custom functions scripts from "qpb_parameters_scan/library" using a
# loop avoiding this way name-specific sourcing and thus potential typos
for library_script in "$LIBRARY_SCRIPTS_DIRECTORY_FULL_PATH"/*;
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

test_check_directory_path_failed()
{
    test_directory_path="/path/to/directory"
    expected_output=1

    output=($(check_directory_path $test_directory_path))

    assert $output $expected_output
}


test_check_directory_path_successful()
{
    test_directory_path="../library"
    expected_output=0

    output=($(check_directory_path $test_directory_path))

    assert $output $expected_output
}


test_is_decimal_number()
{
    test_values_list=("1.2" "something" "28.9191" "-0.5")
    expected_outputs_list=(0 1 0 0)

    multiple_assert is_decimal_number test_values_list expected_outputs_list
}


test_modify_decimal_format()
{
    local TESTED_FUNCTION_NAME="modify_decimal_format"
    local ERROR_MESSAGE="\nError: '$TESTED_FUNCTION_NAME' function"

    # Case of valid float input
    parameter_value="15.69"
    parameter_value=$(modify_decimal_format "$parameter_value")
    assert "$parameter_value" "15p69" || {
        echo -e "$ERROR_MESSAGE gives incorrect output for valid float input"\
        "values";
        return 1;
        }

    # Case of valid exponential input
    parameter_value="1.23e-4"
    parameter_value=$(modify_decimal_format "$parameter_value")
    assert "$parameter_value" "1p23e-4" || {
    echo -e "$ERROR_MESSAGE gives incorrect output for valid exponential input"\
        "values";
        return 1;
        }

    # Case of valid integer input
    parameter_value="123"
    parameter_value=$(modify_decimal_format "$parameter_value")
    assert "$parameter_value" "123" || {
    echo -e "$ERROR_MESSAGE gives incorrect output for valid integer input"\
        "values";
        return 1;
        }

}



################################################################################

# test_match_configuration_label_to_file()
# {
#     output=$(match_configuration_label_to_file "0024200")
#     expected_output="/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE/conf_Nf0_b6p20_L24T48_apeN1a0p72.0024200"

#     assert "$output" "$expected_output"
# }


# test_calculate_kappa_value() {
#     BARE_MASS=1.0
#     output=$(calculate_kappa_value "$BARE_MASS")
#     expected_output="0.1"

#     assert $output $expected_output
# }

# test_general_range_of_values_generator() {
#     local range_of_values=$(general_range_of_values_generator "2" "20" "2")
#     echo $range_of_values
# }


# test_exponential_range_of_values_generator() {
#     local range_of_values=$(exponential_range_of_values_generator "1e-2" "1e-6" "1e-2")
#     echo $range_of_values
# }


# test_general_range_of_values_generator()
# {
#     local TESTED_FUNCTION_NAME="general_range_of_values_generator"
#     local ERROR_MESSAGE="\nError: '$TESTED_FUNCTION_NAME' function"

#     # Valid case of integer range of values
#     output=$(general_range_of_values_generator 1 10 2)
#     expected_output="1 3 5 7 9"
#     assert "$output" "$expected_output" || {
#         echo -e "$ERROR_MESSAGE generates incorrect integer range of values";
#         return 1;
#         }

#     # Valid case of range of float values with single decimal point
#     output=$(general_range_of_values_generator 1.0 2.0 0.2)
#     expected_output="1.0 1.2 1.4 1.6 1.8 2.0"
#     assert "$output" "$expected_output" || {
#         echo -e "$ERROR_MESSAGE generates incorrect range of float values with"\
#         "single decimal point";
#         return 1;
#         }

#     # Valid case of range of float values with three decimal points
#     output=$(general_range_of_values_generator 1.0 1.01 0.002)
#     expected_output="1.000 1.002 1.004 1.006 1.008 1.010"
#     assert "$output" "$expected_output" || {
#         echo -e "$ERROR_MESSAGE generates incorrect range of float values with"\
#         "three decimal points";
#         return 1;
#         }

#     # Valid case of range of exponential float values
#     output=$(general_range_of_values_generator 1e-1 1.5e-1 1e-2)
#     expected_output="1.00e-01 1.10e-01 1.20e-01 1.30e-01 1.40e-01"
#     assert "$output" "$expected_output" || {
#         echo -e "$ERROR_MESSAGE generates incorrect range of exponential float"\
#         "values";
#         return 1;
#         }

#     # Valid case of range of exponential float values with negative step
#     output=$(general_range_of_values_generator 1e-1 1e-2 -1e-2)
#     expected_output="1.00e-01 9.00e-02 8.00e-02 7.00e-02 6.00e-02 5.00e-02 "
#     expected_output+="4.00e-02 3.00e-02 2.00e-02 1.00e-02"
#     assert "$output" "$expected_output" || {
#         echo -e "$ERROR_MESSAGE generates incorrect range of exponential float"\
#         "values with negative step";
#         return 1;
#         }
# }

# test_range_of_gauge_configurations_file_paths_generator()
# {
#     output=$(\range_of_gauge_configurations_file_paths_generator \
#         $GAUGE_LINKS_CONFIGURATIONS_DIRECTORY 1 3 1)
#     expected_output="/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE/"\
# "conf_Nf0_b6p20_L24T48_apeN1a0p72.0000200 /nvme/h/cy22sg1/scratch/Nf0/"\
# "Nf0_b6p20_L24T48-APE/conf_Nf0_b6p20_L24T48_apeN1a0p72.0000400 /nvme/h/cy22sg1"\
# "/scratch/Nf0/Nf0_b6p20_L24T48-APE/conf_Nf0_b6p20_L24T48_apeN1a0p72.0000600"

#     # assert "$output" "$expected_output"
# }


unittest $unittest_option
