#!/bin/bash

######################################################################
# library/checks.sh.sh - ?
#
# This script contains ?
#
# Author: Stylianos Gregoriou
# Date last modified: 10th June 2024
#
# Usage: 
#        
#
######################################################################

module purge
module load Anaconda3
module load GSL
module load Autotools
module load gompi


binary=$1
mpi_geometry=$2
parameters_file=$3
number_of_tasks=$4

mpirun -n ${number_of_tasks} --map-by ppr:8:socket --bind-to core --report-bindings \
                            ${binary} geom=${mpi_geometry} ${parameters_file}
