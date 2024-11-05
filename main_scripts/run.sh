#!/bin/bash

# TODO: Write description
######################################################################
# generic_run.sh - Script for 
#
#
######################################################################

module purge
module load Anaconda3
module load GSL
module load Autotools
module load gompi


main_program_executable=$1
mpi_geometry=$2
parameters_file=$3
number_of_tasks=$4

mpirun -n ${number_of_tasks} --map-by ppr:8:socket --bind-to core \
        --report-bindings ${main_program_executable} geom=${mpi_geometry} \
                                                            ${parameters_file}
