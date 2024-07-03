#!/bin/bash


source ../library/unittest_framework.sh
source ../library/interface.sh
source ../library/auxiliary.sh
source ../library/constants.sh
source ../library/parameters.sh


unittest_option_default_value="-v"
# Check if an argument is provided; if not, use the default value
unittest_option=${1:-$unittest_option_default_value}


test_extract_operator_method()
{
    test_input_values_list=("/overlap-Chebyshev/multiple_runs.sh" "/mainprogs/multiple_runs.sh")
    expected_outputs_list=("Chebyshev" "Bare")

    multiple_assert extract_operator_method test_input_values_list expected_outputs_list
}


test_validate_indices_array()
{
    local TESTED_FUNCTION_NAME="validate_indices_array"
    local ERROR_MESSAGE="\nError: '$TESTED_FUNCTION_NAME' function"
    
    # Valid input case
    test_input_values_list=(10 0 2 6)
    negative_assert \
        "! $TESTED_FUNCTION_NAME \"test_input_values_list\"" \
        "$ERROR_MESSAGE does not accept valid input" || return 1

    # Case of non-integer numerical element
    test_input_values_list=(10 0.6 8 6)
    negative_assert \
        "$TESTED_FUNCTION_NAME \"test_input_values_list\"" \
            "$ERROR_MESSAGE accepts non-integer numerical elements as input"\
            || return 1
    
    # Case of non-integer non-numerical element
    test_input_values_list=(10 0 TEST 6)
    negative_assert \
        "$TESTED_FUNCTION_NAME \"test_input_values_list\"" \
        "$ERROR_MESSAGE accepts non-integer non-numerical elements as input"\
            || return 1

    # Case of out-of-range element
    test_input_values_list=(10 100 8 6)
    negative_assert \
        "$TESTED_FUNCTION_NAME \"test_input_values_list\"" \
        "$ERROR_MESSAGE accepts out-of-range elements as input" || return 1
    
    # Case of duplicates
    test_input_values_list=(10 6 8 6)
    negative_assert \
        "$TESTED_FUNCTION_NAME \"test_input_values_list\"" \
            "$ERROR_MESSAGE accepts duplicates as input" || return 1
 
    # Case of including the "OPERATOR_TYPE" index 
    OPERATOR_TYPE_index=$(\
                find_index "OPERATOR_TYPE" "${MODIFIABLE_PARAMETERS_LIST[@]}")
    test_input_values_list=(10 6 8 $OPERATOR_TYPE_index)
    negative_assert \
        "$TESTED_FUNCTION_NAME \"test_input_values_list\"" \
        "$ERROR_MESSAGE accepts the "OPERATOR_TYPE" index as input" || return 1
}


test_validate_updated_constant_parameters_array()
{
    local TESTED_FUNCTION_NAME="validate_updated_constant_parameters_array"
    local ERROR_MESSAGE="\nError: '$TESTED_FUNCTION_NAME' function"

    # Empty list case
    test_input_values_list=()
    negative_assert \
        "! $TESTED_FUNCTION_NAME \"\${test_input_values_list[@]}\"" \
        "$ERROR_MESSAGE must accept empty lists as valid input" || return 1

    # Valid input case
    test_input_values_list=("RHO=0.3")
    negative_assert \
        "! $TESTED_FUNCTION_NAME \"\${test_input_values_list[@]}\"" \
        "$ERROR_MESSAGE does not accept valid input" || return 1

    # Invalid input case
    test_input_values_list=("KAPPA=0.3")
    negative_assert \
        "$TESTED_FUNCTION_NAME \"\${test_input_values_list[@]}\"" \
        "$ERROR_MESSAGE accepts invalid input" || return 1
}


test_constant_parameters_update()
{
    # Arbitrary initialization
    local constant_parameters_1="15.6"
    local constant_parameters_2="INITIAL"

    expected_outputs_list=("10.8" "FINAL")
    
    constant_parameters_list=(
        "constant_parameters_1=${expected_outputs_list[0]}"
        "constant_parameters_2=${expected_outputs_list[1]}"
        )

    constant_parameters_update "${constant_parameters_list[@]}"

    if [[ "$constant_parameters_1" != "${expected_outputs_list[0]}" ]] \
        || [[ "$constant_parameters_2" != "${expected_outputs_list[1]}" ]];
        then
        return 1
    else
        return 0
    fi
}


test_is_range_string()
{
    local TESTED_FUNCTION_NAME="is_range_string"
    local ERROR_MESSAGE="\nError: '$TESTED_FUNCTION_NAME' function"

    # Valid input case of range of integers
    test_input_values_list="[2 6 1]"
    negative_assert \
        "! $TESTED_FUNCTION_NAME \"\${test_input_values_list[@]}\"" \
        "$ERROR_MESSAGE does not accept valid input of range of integers"\
         || return 1
    
    # Valid input case of range of floats
    test_input_values_list="[0.2 1.6 0.1]"
    negative_assert \
        "! $TESTED_FUNCTION_NAME \"\${test_input_values_list[@]}\"" \
        "$ERROR_MESSAGE does not accept valid input of range of floats"\
         || return 1
    
    # Invalid input case with incorrect numerical format
    test_input_values_list="[0.2 1.6 0,9]"
    negative_assert \
        "$TESTED_FUNCTION_NAME \"\${test_input_values_list[@]}\"" \
        "$ERROR_MESSAGE accepts incorrect numerical format"\
         || return 1

    # Invalid input case with non-numerical specifier
    test_input_values_list="[0.2 abs 0.9]"
    negative_assert \
        "$TESTED_FUNCTION_NAME \"\${test_input_values_list[@]}\"" \
        "$ERROR_MESSAGE accepts non-numerical specifier"\
         || return 1

    # Invalid input case with more than 3 specifiers in the range string
    test_input_values_list="[0.2 1.6 0.1 0.9]"
    negative_assert \
        "$TESTED_FUNCTION_NAME \"\${test_input_values_list[@]}\"" \
        "$ERROR_MESSAGE accepts more than 3 specifiers in the range string"\
         || return 1
}


# test_range_of_values_generator()
# {
#     test_input="[2 66 8]"
#     output=$(range_of_values_generator "construct_number_of_Chebyshev_terms_range" "[2 66 8]")
#     expected_output="2 10 18 26 34 42 50 58 66"

#     assert "$output" "$expected_output"
# }


test_construct_number_of_Chebyshev_terms_range()
{
    start=10
    end=1
    step=-2

    expected_output_array=(10 8 6 4 2)

    # Capture the function's output into an array
    output_array=()
    read -r -a output_array <<< "$(construct_number_of_Chebyshev_terms_range "$start" "$end" "$step")"

    array_assert output_array expected_output_array
}


test_exclude_elements_from_modifiable_parameters_list_by_index()
{
    indices_to_exclude=(0 1 2 3 4 5 6 7 9 10 11 12 13 14 15 16 17)
    expected_output_array=(\
        "${MODIFIABLE_PARAMETERS_LIST[8]}" "${MODIFIABLE_PARAMETERS_LIST[18]}")

    # Capture the function's output into an array
    output_array=()
    read -r -a output_array <<< "$(exclude_elements_from_modifiable_parameters_list_by_index ${indices_to_exclude[@]})"

    array_assert output_array expected_output_array
}


test_match_configuration_label_to_file()
{
    output=$(match_configuration_label_to_file "0024200")
    expected_output="/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE/conf_Nf0_b6p20_L24T48_apeN1a0p72.0024200"

    assert "$output" "$expected_output"
}

test_parameter_range_of_values_generator()
{
    output=$(parameter_range_of_values_generator range_of_gauge_configurations_file_paths_generator "[1 1 1]")
    expected_output="/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE/conf_Nf0_b6p20_L24T48_apeN1a0p72.0000200"

    assert $output $expected_output
}


# test_validate_varying_parameter_values_array()
# {
#     VARYING_PARAMETERS_INDICES_LIST=(1)
#     INNER_LOOP_VARYING_PARAMETER_SET_OF_VALUES="[1 1 1]"
#     output=$(validate_varying_parameter_values_array 0 \
#                 INNER_LOOP_VARYING_PARAMETER_SET_OF_VALUES)
#           echo $output      
# }

unittest $unittest_option
