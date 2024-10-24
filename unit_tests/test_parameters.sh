#!/bin/bash


source ../library/unittest_framework.sh
source ../library/auxiliary.sh
source ../library/constants.sh
source ../library/parameters.sh


unittest_option_default_value="-v"
# Check if an argument is provided; if not, use the default value
unittest_option=${1:-$unittest_option_default_value}


test_extract_configuration_label_from_file()
{
    # positive tests
    test_input_values_list=(
        "conf_Nf0_b6p20_L24T48_apeN1a0p72.0024200" \
        "conf_Nf0_b6p20_L24T48.0036800" \
        )
    expected_output_values_list=("0024200" "0036800")

    multiple_assert extract_configuration_label_from_file test_input_values_list \
                                    expected_output_values_list || return 1;

    # negative test
    extract_configuration_label_from_file "INCORRECT_INPUT" >/dev/null 2>&1 || return 0;
}


# test_check_lattice_dimensions()
# {
#     test_input_values_list=("24 12 12 12" "32 16 16 16" "40 20 20 21")
#     expected_outputs_list=(0 0 1)

#     multiple_assert check_lattice_dimensions test_input_values_list \
#                                                         expected_outputs_list
# }


# test_is_float()
# {
#     test_input_values_list=("42" "-42.0" "3.14" "abc" "3.14e-10")
#     expected_outputs_list=(0 0 0 1 0)

#     multiple_assert is_float test_input_values_list expected_outputs_list
# }


# test_is_positive_float()
# {
#     test_input_values_list=("0" "42" "3.14" "-42.0" "abc" "3.14e-10")
#     expected_outputs_list=(1 0 0 1 1 0)

#     multiple_assert is_positive_float test_input_values_list expected_outputs_list
# }


# test_check_rho_value()
# {
#     test_input_values_list=("0" "2" "1.5" "2.1" "-1.0" "abc")
#     expected_outputs_list=(0 0 0 1 1 1)

#     multiple_assert check_rho_value test_input_values_list expected_outputs_list
# }


# test_check_clover_term_coefficient_value()
# {
#     test_input_values_list=("0" "1" "0.5" "1.1" "-0.5" "abc")
#     expected_outputs_list=(0 0 0 1 1 1)

#     multiple_assert check_clover_term_coefficient_value test_input_values_list expected_outputs_list
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


# test_lattice_dimensions_range_of_strings_generator()
# {
#     output=$(lattice_dimensions_range_of_strings_generator 1 3 2)
#     expected_output="32 16 16 16 48 24 24 24"

#     assert "$output" "$expected_output"
# }


# test_calculate_kappa_value()
# {
#     BARE_MASS=1.0
#     output=$(calculate_kappa_value "$BARE_MASS")
#     expected_output="0.1"

#     assert $output $expected_output
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
