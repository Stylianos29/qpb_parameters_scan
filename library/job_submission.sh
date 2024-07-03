#!/bin/bash


CURRENT_SCRIPT_FULL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_SCRIPT_FULL_PATH/constants.sh"


convert_mpi_geometry_to_number_of_tasks()
{
: '
  Takes an arr
  '

  local mpi_geometry_string=$1

  # Extract the numbers from the string
  IFS=',' read -r num1 num2 num3 <<< "$mpi_geometry_string"

  product=$((num1 * num2 * num3))

  echo $product
}


fill_in_parameter_file()
{

  for constant_parameter in "${constant_parameters_list[@]}"; do
    # Get the value of the replacement variable
    value="${!constant_parameter}"

    # Use sed to perform the replacement
    sed -i "s@_${constant_parameter}_@${value}@g" "$EMPTY_PARAMETERS_TEMPLATE_FILE"
  done

}