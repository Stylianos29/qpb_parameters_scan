#!/bin/bash


source ../library/unittest_framework.sh
source ../library/checks.sh


unittest_option_default_value="-v"
# Check if an argument is provided; if not, use the default value
unittest_option=${1:-$unittest_option_default_value}


test_check_operator_type()
{
    test_input_values_list=("Brillouin" "Standard" "Stnd")
    expected_outputs_list=(0 0 1)

    multiple_assert check_operator_type test_input_values_list expected_outputs_list
}


test_check_rho_value()
{
    test_rho_values_list=("1.2" "something" "2.9" "-0.5")
    expected_outputs_list=(0 0 1 1)

    multiple_assert check_rho_value test_rho_values_list expected_outputs_list
}


unittest $unittest_option
