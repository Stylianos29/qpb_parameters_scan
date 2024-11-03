#!/bin/bash


# TODO: Write description
######################################################################
# unit_tests/test_validation.sh - Script for 
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
# Check if an argument is provided; if not use the default value
unittest_option=${1:-$unittest_option_default_value}

# CUSTOM FUNCTIONS UNIT TESTS

test_extract_overlap_operator_method()
{
    test_input_values_list=(
            "/overlap-Chebyshev/multiple_runs.sh" \
            "/overlap-chebyshev/multiple_runs.sh" \
            "/overlap-CHEBYSHEV/multiple_runs.sh" \
            "/overlap-KL/multiple_runs.sh" \
            "/overlap-kl/multiple_runs.sh" \
            "/mainprogs/multiple_runs.sh"
        )
    expected_output_values_list=(
            "Chebyshev" \
            "Chebyshev" \
            "Chebyshev" \
            "KL" \
            "KL" \
            "Bare"
        )

    multiple_assert extract_overlap_operator_method test_input_values_list \
                                                    expected_output_values_list
}


test_extract_kernel_operator_type()
{
    # positive tests
    test_input_values_list=("Standard" "Stan" "0" "Brillouin" "Bri" "1")
    expected_output_values_list=("Standard" "Standard" "Standard" \
                                        "Brillouin" "Brillouin" "Brillouin")

    multiple_assert extract_kernel_operator_type test_input_values_list \
                                    expected_output_values_list || return 1;

    # negative test
    extract_kernel_operator_type "INCORRECT_INPUT" >/dev/null 2>&1 || return 0;
}


test_extract_QCD_beta_value()
{
    # positive tests
    test_input_values_list=(
        "/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE" \
        "/nvme/h/cy22sg1/scratch/Nf0/Nf0_b5p20_L16T32-APE" \
        )
    expected_output_values_list=("6.20" "5.20")

    multiple_assert extract_QCD_beta_value test_input_values_list \
                                expected_output_values_list || return 1;

    # negative test
    extract_QCD_beta_value "INCORRECT_INPUT" >/dev/null 2>&1 || return 0;
}


test_extract_lattice_dimensions()
{
    # positive tests
    test_input_values_list=(
        "/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE" \
        "/nvme/h/cy22sg1/scratch/Nf0/Nf0_b5p20_L16T32-APE" \
        )
    expected_output_values_list=("48 24 24 24" "32 16 16 16")

    multiple_assert extract_lattice_dimensions test_input_values_list \
                                expected_output_values_list || return 1;

    # negative test
    extract_lattice_dimensions "INCORRECT_INPUT" >/dev/null 2>&1 || return 0;
}


# # TODO: Setup a test for the ""extract_operator_type" function
# # test_extract_operator_type()
# # {


# #     # Set the OPERATOR_TYPE_FLAG variable
# #     OPERATOR_TYPE_FLAG=Stan

# #     # Source the function (if it is in another file, source that file)
# #     # source /path/to/function_definition.sh

# #     # Call the function to set OPERATOR_TYPE
# #     extract_operator_type

# #     # Print the resulting OPERATOR_TYPE
# #     echo "OPERATOR_TYPE is set to: $OPERATOR_TYPE"
# # }


# test_extract_operator_method()
# {
#     output=($(extract_QCD_beta_value "/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE"))
#     echo $output
# }


# test_validate_indices_array()
# {
#     local TESTED_FUNCTION_NAME="validate_indices_array"
#     local ERROR_MESSAGE="\nError: '$TESTED_FUNCTION_NAME' function"
    
#     # Valid input case
#     test_input_values_list=(10 0 2 6)
#     negative_assert \
#         "! $TESTED_FUNCTION_NAME \"test_input_values_list\"" \
#         "$ERROR_MESSAGE does not accept valid input" || return 1

#     # Case of non-integer numerical element
#     test_input_values_list=(10 0.6 8 6)
#     negative_assert \
#         "$TESTED_FUNCTION_NAME \"test_input_values_list\"" \
#             "$ERROR_MESSAGE accepts non-integer numerical elements as input"\
#             || return 1
    
#     # Case of non-integer non-numerical element
#     test_input_values_list=(10 0 TEST 6)
#     negative_assert \
#         "$TESTED_FUNCTION_NAME \"test_input_values_list\"" \
#         "$ERROR_MESSAGE accepts non-integer non-numerical elements as input"\
#             || return 1

#     # Case of out-of-range element
#     test_input_values_list=(10 100 8 6)
#     negative_assert \
#         "$TESTED_FUNCTION_NAME \"test_input_values_list\"" \
#         "$ERROR_MESSAGE accepts out-of-range elements as input" || return 1
    
#     # Case of duplicates
#     test_input_values_list=(10 6 8 6)
#     negative_assert \
#         "$TESTED_FUNCTION_NAME \"test_input_values_list\"" \
#             "$ERROR_MESSAGE accepts duplicates as input" || return 1
 
#     # Case of including the "OPERATOR_TYPE" index 
#     OPERATOR_TYPE_index=$(\
#                 find_index "OPERATOR_TYPE" "${MODIFIABLE_PARAMETERS_LIST[@]}")
#     test_input_values_list=(10 6 8 $OPERATOR_TYPE_index)
#     negative_assert \
#         "$TESTED_FUNCTION_NAME \"test_input_values_list\"" \
#         "$ERROR_MESSAGE accepts the "OPERATOR_TYPE" index as input" || return 1
# }


# test_validate_updated_constant_parameters_array()
# {
#     local TESTED_FUNCTION_NAME="validate_updated_constant_parameters_array"
#     local ERROR_MESSAGE="\nError: '$TESTED_FUNCTION_NAME' function"

#     # Empty list case
#     test_input_values_list=()
#     negative_assert \
#         "! $TESTED_FUNCTION_NAME \"\${test_input_values_list[@]}\"" \
#         "$ERROR_MESSAGE must accept empty lists as valid input" || return 1

#     # Valid input case
#     test_input_values_list=("RHO=0.3")
#     negative_assert \
#         "! $TESTED_FUNCTION_NAME \"\${test_input_values_list[@]}\"" \
#         "$ERROR_MESSAGE does not accept valid input" || return 1

#     # Invalid input case
#     test_input_values_list=("KAPPA=0.3")
#     negative_assert \
#         "$TESTED_FUNCTION_NAME \"\${test_input_values_list[@]}\"" \
#         "$ERROR_MESSAGE accepts invalid input" || return 1
# }


# test_constant_parameters_update()
# {
#     # Arbitrary initialization
#     local constant_parameters_1="15.6"
#     local constant_parameters_2="INITIAL"

#     expected_output_values_list=("10.8" "FINAL")
    
#     constant_parameters_list=(
#         "constant_parameters_1=${expected_output_values_list[0]}"
#         "constant_parameters_2=${expected_output_values_list[1]}"
#         )

#     constant_parameters_update "${constant_parameters_list[@]}"

#     if [[ "$constant_parameters_1" != "${expected_output_values_list[0]}" ]] \
#         || [[ "$constant_parameters_2" != "${expected_output_values_list[1]}" ]];
#         then
#         return 1
#     else
#         return 0
#     fi
# }


# test_is_range_string()
# {
#     local TESTED_FUNCTION_NAME="is_range_string"
#     local ERROR_MESSAGE="\nError: '$TESTED_FUNCTION_NAME' function"

#     # Valid input case of range of integers
#     test_input_values_list="[2 6 1]"
#     negative_assert \
#         "! $TESTED_FUNCTION_NAME \"\${test_input_values_list[@]}\"" \
#         "$ERROR_MESSAGE does not accept valid input of range of integers"\
#          || return 1
    
#     # Valid input case of range of floats
#     test_input_values_list="[0.2 1.6 0.1]"
#     negative_assert \
#         "! $TESTED_FUNCTION_NAME \"\${test_input_values_list[@]}\"" \
#         "$ERROR_MESSAGE does not accept valid input of range of floats"\
#          || return 1
    
#     # Invalid input case with incorrect numerical format
#     test_input_values_list="[0.2 1.6 0,9]"
#     negative_assert \
#         "$TESTED_FUNCTION_NAME \"\${test_input_values_list[@]}\"" \
#         "$ERROR_MESSAGE accepts incorrect numerical format"\
#          || return 1

#     # Invalid input case with non-numerical specifier
#     test_input_values_list="[0.2 abs 0.9]"
#     negative_assert \
#         "$TESTED_FUNCTION_NAME \"\${test_input_values_list[@]}\"" \
#         "$ERROR_MESSAGE accepts non-numerical specifier"\
#          || return 1

#     # Invalid input case with more than 3 specifiers in the range string
#     test_input_values_list="[0.2 1.6 0.1 0.9]"
#     negative_assert \
#         "$TESTED_FUNCTION_NAME \"\${test_input_values_list[@]}\"" \
#         "$ERROR_MESSAGE accepts more than 3 specifiers in the range string"\
#          || return 1
# }


# # test_range_of_values_generator()
# # {
# #     test_input="[2 66 8]"
# #     output=$(range_of_values_generator "construct_number_of_Chebyshev_terms_range" "[2 66 8]")
# #     expected_output="2 10 18 26 34 42 50 58 66"

# #     assert "$output" "$expected_output"
# # }


# test_construct_number_of_Chebyshev_terms_range()
# {
#     start=10
#     end=1
#     step=-2

#     expected_output_array=(10 8 6 4 2)

#     # Capture the function's output into an array
#     output_array=()
#     read -r -a output_array <<< "$(construct_number_of_Chebyshev_terms_range "$start" "$end" "$step")"

#     array_assert output_array expected_output_array
# }


# test_exclude_elements_from_modifiable_parameters_list_by_index()
# {
#     indices_to_exclude=(0 1 2 3 4 5 6 7 9 10 11 12 13 14 15 16 17)
#     expected_output_array=(\
#         "${MODIFIABLE_PARAMETERS_LIST[8]}" "${MODIFIABLE_PARAMETERS_LIST[18]}")

#     # Capture the function's output into an array
#     output_array=()
#     read -r -a output_array <<< "$(exclude_elements_from_modifiable_parameters_list_by_index ${indices_to_exclude[@]})"

#     array_assert output_array expected_output_array
# }


# # test_match_configuration_label_to_file()
# # {
# #     output=$(match_configuration_label_to_file "0024200")
# #     expected_output="/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE/conf_Nf0_b6p20_L24T48_apeN1a0p72.0024200"

# #     assert "$output" "$expected_output"
# # }

# # test_parameter_range_of_values_generator()
# # {
# #     output=$(parameter_range_of_values_generator range_of_gauge_configurations_file_paths_generator "[1 1 1]")
# #     expected_output="/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE/conf_Nf0_b6p20_L24T48_apeN1a0p72.0000200"

# #     assert $output $expected_output
# # }


# # test_validate_varying_parameter_values_array()
# # {
# #     VARYING_PARAMETERS_INDICES_LIST=(1)
# #     INNER_LOOP_VARYING_PARAMETER_SET_OF_VALUES="[1 1 1]"
# #     output=$(validate_varying_parameter_values_array 0 \
# #                 INNER_LOOP_VARYING_PARAMETER_SET_OF_VALUES)
# #           echo $output      
# # }

unittest $unittest_option
