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
            "/overlap-Zolotarev/scan.sh" \
            "/overlap-zolotarev/scan.sh" \
            "/overlap-ZOLOTAREV/scan.sh" \
            "/overlap-Neuberger/scan.sh" \
            "/overlap-neuberger/scan.sh" \
            "/overlap-NEUBERGER/scan.sh" \
            "/overlap-KL/scan.sh" \
            "/overlap-kl/scan.sh" \
            "/mainprogs/scan.sh" \
            # Full paths that might mislead the extraction
            "/KL_multishift_scaling/qpb/mainprogs/invert/qpb_parameters_scan_files/scan.sh" \
            "/KL_multishift_scaling/qpb/mainprogs/overlap-kl/invert/qpb_parameters_scan_files/scan.sh" \
            "/Chebyshev_modified_eigenvalues/qpb/mainprogs/overlap-Chebyshev/invert/qpb_parameters_scan_files/scan.sh" \
            "/Zolotarev_tests/qpb/mainprogs/overlap-Zolotarev/sign-squared-violation/qpb_parameters_scan_files/scan.sh" \
            "/Neuberger_scaling/qpb/mainprogs/overlap-Neuberger/invert/qpb_parameters_scan_files/scan.sh" \
            "/Chebyshev_modified_eigenvalues/qpb/mainprogs/invert/qpb_parameters_scan_files/scan.sh"
        )
    expected_output_values_list=(
            "Chebyshev" \
            "Chebyshev" \
            "Chebyshev" \
            "Zolotarev" \
            "Zolotarev" \
            "Zolotarev" \
            "Neuberger" \
            "Neuberger" \
            "Neuberger" \
            "KL" \
            "KL" \
            "Bare" \
            "Bare" \
            "KL" \
            "Chebyshev" \
            "Zolotarev" \
            "Neuberger" \
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
                test_input_values_list expected_output_values_list || return 1

    # Negative test
    ! extract_configuration_label_from_file "INCORRECT_INPUT" >/dev/null 2>&1 \
                                                                    || return 1
}


test_calculate_kappa_value_from_bare_mass() {
    test_input_values_list=("1.0" "1" "-2" "-4.5")
    expected_output_values_list=("0.1" "0.1" "0.25" "-1.0")

    assert_multiple_function_outputs calculate_kappa_value_from_bare_mass \
                test_input_values_list expected_output_values_list
}


test_calculate_bare_mass_from_kappa_value() {
    test_input_values_list=("0.1" "0.1" "0.25" "-1.0")
    expected_output_values_list=("1.0" "1.0" "-2.0" "-4.5")

    assert_multiple_function_outputs calculate_bare_mass_from_kappa_value \
                test_input_values_list expected_output_values_list
}


test_calculate_number_of_tasks_from_mpi_geometry() {
    test_input_values_list=("2,2,2" "3,2,1")
    expected_output_values_list=("8" "6")

    assert_multiple_function_outputs \
        calculate_number_of_tasks_from_mpi_geometry \
                test_input_values_list expected_output_values_list
}

# Missing tests for:
# - extract_configuration_label_from_file()
# - match_configuration_label_to_file()
# - extract_lattice_dimensions_label_with_value()

unittest $unittest_option
