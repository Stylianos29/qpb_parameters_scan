#!/bin/bash


source ../library/unittest_framework.sh
source ../library/interface.sh
source ../library/auxiliary.sh
source ../library/constants.sh
source ../library/parameters.sh


unittest_option_default_value="-v"
# Check if an argument is provided; if not, use the default value
unittest_option=${1:-$unittest_option_default_value}


test_convert_mpi_geometry_to_number_of_tasks()
{
    test_mpi_geometry_string="2,2,2"
    expected_number_of_tasks="8"

    number_of_tasks=($(convert_mpi_geometry_to_number_of_tasks \
                                                    $test_mpi_geometry_string))

    assert ${number_of_tasks} ${expected_number_of_tasks}
}
