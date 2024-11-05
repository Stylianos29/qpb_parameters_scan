#!/bin/bash

# TODO: Write description
######################################################################
# run.sh - Script for 
#
#
######################################################################

# ADDITIONAL SBATCH OPTIONS

#SBATCH --ntasks-per-node=16
#SBATCH --partition=nehalem

# DEPENDENCIES

module purge
module load Anaconda3
module load GSL
module load Autotools
module load gompi

# POSITIONAL ARGUMENTS PASSED TO SCRIPT

number_of_tasks=$1
main_program_executable=$2
mpi_geometry=$3
parameters_file=$4

mpirun -n ${number_of_tasks} --map-by ppr:8:socket --bind-to core \
        --report-bindings ${main_program_executable} geom=${mpi_geometry} \
                                                            ${parameters_file}
