#!/bin/bash


# TODO: Write description
######################################################################
# unit_tests/test_parameters.sh - Script for 
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

test_extract_overlap_operator_method() {
    test_input_values_list=(
            # Relative paths with characteristic substring in different cases
            "/overlap-Chebyshev/scan.sh" \
            "/overlap-chebyshev/scan.sh" \
            "/overlap-CHEBYSHEV/scan.sh" \
            "/overlap-KL/scan.sh" \
            "/overlap-kl/scan.sh" \
            "/mainprogs/scan.sh" \
            # Full paths that might mislead the extraction
            "/nvme/h/cy22sg1/qpb_branches/KL_multishift_scaling/qpb/mainprogs/invert/qpb_parameters_scan_files/scan.sh" \
            "/nvme/h/cy22sg1/qpb_branches/KL_multishift_scaling/qpb/mainprogs/overlap-kl/invert/qpb_parameters_scan_files/scan.sh" \
            "/nvme/h/cy22sg1/qpb_branches/Chebyshev_modified_eigenvalues/qpb/mainprogs/overlap-Chebyshev/invert/qpb_parameters_scan_files/scan.sh" \
            "/nvme/h/cy22sg1/qpb_branches/Chebyshev_modified_eigenvalues/qpb/mainprogs/invert/qpb_parameters_scan_files/scan.sh"
        )
    expected_output_values_list=(
            "Chebyshev" \
            "Chebyshev" \
            "Chebyshev" \
            "KL" \
            "KL" \
            "Bare" \
            "Bare" \
            "KL" \
            "Chebyshev" \
            "Bare"
        )

    assert_multiple_function_outputs extract_overlap_operator_method \
                            test_input_values_list expected_output_values_list
}


test_extract_kernel_operator_type() {
    # Positive tests
    test_input_values_list=("Standard" "Stan" "0" "Brillouin" "Bri" "1")
    expected_output_values_list=("Standard" "Standard" "Standard" \
                                        "Brillouin" "Brillouin" "Brillouin")

    assert_multiple_function_outputs extract_kernel_operator_type \
                test_input_values_list expected_output_values_list || return 1

    # Negative test
    ! extract_kernel_operator_type "INCORRECT_INPUT" > /dev/null 2>&1 \
                                                                    || return 1
}


test_extract_QCD_beta_value() {
    # Positive tests
    test_input_values_list=(
        "/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE" \
        "/nvme/h/cy22sg1/scratch/Nf0/Nf0_b5p20_L16T32-APE" \
        )
    expected_output_values_list=("6.20" "5.20")

    assert_multiple_function_outputs extract_QCD_beta_value \
                test_input_values_list expected_output_values_list || return 1

    # Negative test
    ! extract_QCD_beta_value "INCORRECT_INPUT" > /dev/null 2>&1 || return 1
}


test_extract_lattice_dimensions() {
    # Positive tests
    test_input_values_list=(
        "/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE" \
        "/nvme/h/cy22sg1/scratch/Nf0/Nf0_b5p20_L16T32-APE"
        )
    expected_output_values_list=("48 24 24 24" "32 16 16 16")

    assert_multiple_function_outputs extract_lattice_dimensions \
                test_input_values_list expected_output_values_list || return 1

    # Negative test
    ! extract_lattice_dimensions "INCORRECT_INPUT" > /dev/null 2>&1 || return 1
}


test_extract_configuration_label_from_file() {
    # Positive tests
    test_input_values_list=(
        "conf_Nf0_b6p20_L24T48_apeN1a0p72.0024200" \
        "conf_Nf0_b6p20_L24T48.0036800" \
        )
    expected_output_values_list=("0024200" "0036800")

    assert_multiple_function_outputs extract_configuration_label_from_file \
                test_input_values_list expected_output_values_list || return 1;

    # Negative test
    ! extract_configuration_label_from_file "INCORRECT_INPUT" >/dev/null 2>&1 \
                                                                    || return 1;
}


test_match_configuration_label_to_file()
{
    output=$(match_configuration_label_to_file "0024200")
    expected_output="/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE/conf_Nf0_b6p20_L24T48_apeN1a0p72.0024200"

    assert "$output" "$expected_output"
}


test_calculate_kappa_value() {
    BARE_MASS=1.0
    output=$(calculate_kappa_value "$BARE_MASS")
    expected_output="0.1"

    assert $output $expected_output
}


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

