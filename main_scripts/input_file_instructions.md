A **qpb** main program executable typically requires a significant number of input parameters to run. This BASH wrapper is designed to facilitate parameter scans for these executables, focusing on a selected subset of the parameters.

The full set of parameters needed for the executable is split into two categories:
1. **Constant Parameters** – These parameters are unlikely to change during execution, although users can modify them in the template parameter files (not recommended).
2. **Modifiable Parameters** – These parameters can be adjusted by the user.

Within the modifiable parameters, there are two further categories:
- **Iterable Parameters** – Parameters whose values can vary during the execution of the `multiple_runs.sh` script. These are used for performing parameter scans.
- **Non-Iterable Parameters** – Parameters that are modifiable but remain fixed during the execution of `multiple_runs.sh`.

To use the script:
1. First, set the non-iterable parameters.
2. Then, decide which parameters from the iterable set will be varied during execution. You must specify at least one, but no more than three parameters to vary. These are referred to as the "varying parameters."
3. The remaining iterable parameters, whose values won't vary, are termed "constant iterable parameters."


# This wrapper for the qpb project facilitates running multiple executions of
# main programs' executable via the "multiple_runs.sh" script. The
# executable requires a parameters file with assigned values and a gauge links
# configuration file as input. Its output includes a log file and, in the case
# of an "invert" program, a binary invert solution file. This input file allows
# the user to specify parameters to for multiple executions.

############################ ENVIRONMENT VARIABLES #############################

# Set the relative path of the main program's executable
BINARY=../

# INPUT:

# This is the template, chosen specifically for the specific main program, with
# which the parameters files will be constructed. Set the relative path of the
# empty parameters file
# NOTE: "_params.ini_" is placed in the current directory by setup.sh
EMPTY_PARAMETERS_FILE_PATH=./_params.ini_

# Set the relative path for the parameters files directory (existing or not)
PARAMETERS_FILES_DIRECTORY=./params_files

# Set the full path of the preferred gauge links configuration files directory
GAUGE_LINKS_CONFIGURATIONS_DIRECTORY="/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE"

# OUTPUT:

# Set the relative path of the log files directory (existing or not)
LOG_FILES_DIRECTORY=./log_files

# For "invert" main progs, set full path for storing the solution binary files
BINARY_SOLUTION_FILES_DIRECTORY="/nvme/h/cy22sg1/scratch/invert_solutions_files"

########################### PARAMETERS SPECIFICATION ###########################

# The main program's executable requires a parameter file. This input file
# provides the ability only certain parameters to be modified using this input
# file, others are left constant and need an explicit modification of the empty
# parameters file left to the discretion of the user. Among these modifiable
# parameters from this input file, some parameters are "iterable," meaning they
# can take multiple values across different executions of the "multiple_runs.sh"
# script. Others are fixed, taking only a single value during each execution.
# Following, an an overview, is a list of all the modifiable parameters
# (regardless if they are accepted or not by the executable) split into two
# groups "non-iterable" and "iterable" parameters.

# List of non-iterable parameters:

# List of iterable parameters:

# NON-ITERABLE PARAMETERS VALUES

# Set values of non-iterable parameters NOTE: Parameters
# OVERLAP_OPERATOR_METHOD, QCD_BETA_VALUE, LATTICE_DIMENSIONS have their values
# set automatically using the "GAUGE_LINKS_CONFIGURATIONS_DIRECTORY" path. Only
# KERNEL_OPERATOR_TYPE value needs to be set by the user, 

# Choose operator type by setting for convenience any of the following:
# for "Standard" use: "Standard", "Stan", 0
# for "Brillouin" use: "Brillouin", "Bri", or 1
KERNEL_OPERATOR_TYPE_FLAG=0

# NON-ITERABLE PARAMETERS VALUES PRINTED IN FILENAMES

# Next you need to choose which of the non-iterable parameters you want them to
# be printed in the filename. It's suggested that OVERLAP_OPERATOR_METHOD and
# KERNEL_OPERATOR_TYPE are printed at least
# NOTE: Non-iterable parameters are printed first
LIST_OF_NON_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED=(0 1)

# ITERABLE PARAMETERS WITH VALUES DIFFERENT THAN THE DEFAULT ONES

# Next you need to choose values for the (iterable) parameters you
# chose to keep constant throughout the multiple execution of the main program.
# From the list of the iterable parameters above simply chose that you wish to
# have their values modify from the default ones, and state them inside the
# "LIST_OF_UPDATED_CONSTANT_VALUES" array. Remember any parameters stated here
# cannot be stated simultaneously below as varying parameters, namely acquiring possibly a
# different value with every execution. That will cause an error.

# Parameters with modified values than the default ones

# Set constant values of several parameters different than their 
# default ones, irrespective whether they are to be printed or not
# NOTE: Format "parameter=parameter_value" in a column; do not forget to use "".
LIST_OF_UPDATED_CONSTANT_VALUES=(
    "NUMBER_OF_VECTORS=5"
    "GAUGE_LINKS_CONFIGURATION_LABEL=0024200"
    )

# CONSTANT ITERABLE PARAMETERS VALUES PRINTED IN FILENAMES

# It doesn't make much sense to print both kappa and bare mass values
LIST_OF_CONSTANT_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED=(0 2)



# Selected parameters to be printed in output files names

# Select the indices of parameters to be printed in the specified order. 
# Use "()" for an empty list. The index for "OPERATOR_TYPE" is not valid.
LIST_OF_PARAMETERS_INDICES_TO_BE_PRINTED=(5 1)

# List of all modifiable parameters with their default values:
# Category A: Parameters with values printed by default in all output filenames.
# These are only two: operator method and operator type.

# NOTE: Operator method is extracted automatically from current directory path.

# Choose operator type by setting for convenience any of the following:
# for "Standard" use: "Standard", "Stan", 0, or empty (TODO)
# for "Brillouin" use: "Brillouin", "Bri", or 1
OPERATOR_TYPE_FLAG=0

# Category D:

# Choose at least 1 but no more than 3 parameters that will have their values
# varied in a range or a predefined set of values. State their index in the 
# array right below.
# NOTE: The stated indices in the array correspond (schematically) to the nested
# loops as follows: (inner loop, outer loop, overall outer loop). Thus, only the
# inner loop range or set of values is mandatory to be specified even with a 
# single element.
VARYING_PARAMETERS_INDICES_LIST=(2)



# Category D: Parameters with varying values

# Choose at least 1 but no more than 3 parameters that will have their values
# varied in a range or a predefined set of values. State their index in the 
# array right below.
# NOTE: The stated indices in the array correspond (schematically) to the nested
# loops as follows: (inner loop, outer loop, overall outer loop). Thus, only the
# inner loop range or set of values is mandatory to be specified even with a 
# single element.
# VARYING_PARAMETERS_INDICES_LIST=(1)

# Next select the range of values or predefined (explicit) set of values of each
# of the nested loops. For an explicit set values use the array format. If a 
# range of values is preferred, use then the a format: "[start end step]";
# do not forget to use "" for the range format.
# Inner loop values; mandatory to be filled, corresponds to 1st index
INNER_LOOP_VARYING_PARAMETER_SET_OF_VALUES="[1 5 1]"
# Outer loop values; fill only if a 2nd index was stated; it's ignored if not
OUTER_LOOP_VARYING_PARAMETER_SET_OF_VALUES=
# Overall outer loop values, only if a 3nd index was stated, ignored if not
OVERALL_OUTER_LOOP_VARYING_PARAMETER_SET_OF_VALUES=

################################ JOBS SUBMISSION ###############################

# Select partition for job. NOTE: On Cyclone the options are "p100" or "nehalem"
PARTITION_NAME="nehalem"
# NOTE: The product of MPI_GEOMETRY division per direction equals the total 
# number of cores used for the job
MPI_GEOMETRY="2,2,2"
# NOTE: On Cyclone you can only use 1, 2, or 4 nodes
NUMBER_OF_NODES=1
# NOTE: On Cyclone maximum 16 for "nehalem" and 32 for "p100"
NTASKS_PER_NODE=16
# NOTE: If reservation short is used then walltime is set automatically to 1h
WALLTIME="01:00:00"
