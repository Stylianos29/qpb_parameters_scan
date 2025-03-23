<!-- TODO: Change this file's name for easier user on the terminal uf "input.txt" -->
### Introduction: Inputs and Outputs of the Main Program Executable
The file `input.txt` contains all essential information required for the
successful execution of the `scan.sh` script:
```bash
./scan.sh
```
This guide explains the purpose of each line in input.txt, detailing the
required entries and the correct input format.

In brief, the `scan.sh` script prepares both the inputs and outputs for the main
program executable, which is designed to run multiple times with varying
parameter values.

More specifically, each **qpb** main program executable run requires a parameters
file that includes a complete list of input parameter values, and a binary file
with gauge link values based on the specific gauge theory and lattice size. Upon
execution, the program outputs calculated results and, for an "invert" program,
an additional binary file with the inversion solution. Due to the high
computational demand, it is recommended to run this program on a computing
cluster, which may involve additional input parameters such as SLURM sbatch
options and a path for the job log file. Together, these are considered inputs
and outputs for the main program executable, and all values or paths can be
viewed as "parameters" for execution.

In summary, the sections of `input.txt` include:
1. **Environment Variables** – General paths and directories.
2. **Parameter Specification** – Lists of parameters to be used in the qpb
   program, separated into fixed (non-iterable) and variable (iterable)
   categories.
3. **SLURM Options** – Scheduling details for SLURM-based execution,
   facilitating efficient use of cluster resources.

############################ ENVIRONMENT VARIABLES #############################
The paths to files and directories related to the main program executable itself
and its inputs and outputs.

First, you need to set the relative path of the main program's executable. An
attempt is made by the "setup.sh" script to guess the name of the this
executable file. For example:
```
MAIN_PROGRAM_EXECUTABLE=../sign_squared_violation
```
Next come the paths related to the inputs of the main program's executable.
`_params.ini_` is the template (empty) parameters file, chosen specifically for
the specific main program. It will be used for the constructions of the
individual parameters files for each execution of the main program. This line
requires that you set the relative path of the template. Note however that
`_params.ini_` is placed intensionally in the current directory by `setup.sh`.
```
EMPTY_PARAMETERS_FILE_PATH=./_params.ini_
```
Next, you should set the relative path for the directory (existing already or
not) for the generated individual parameters files by `scan.sh`.
```
PARAMETERS_FILES_DIRECTORY=./params_files
```
And finishing with the inputs, you need to set the full path of the preferred
gauge links configuration files directory. For example:
```
GAUGE_LINKS_CONFIGURATIONS_DIRECTORY="/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE"
```
For the outputs, the relative path of the log files directory (existing or not)
is necessary. Again, these are actually the output files of the Slurm job, but
still they will catch the output of the executable itself. For example:
```
LOG_FILES_DIRECTORY=./log_files
```
Lastly, for "invert" main programs only, a path for storing the solution binary
files is needed. For example:
```
BINARY_INVERT_SOLUTION_FILES_DIRECTORY="/nvme/h/cy22sg1/scratch/invert_solutions_files"
```

########################### PARAMETERS SPECIFICATION ###########################

### Parameters Categories
So again, this BASH wrapper is designed to facilitate parameter scans for these
executables, focusing on a selected subset of these parameters. Let's brake them
down into categories for better communication. The full set of parameters needed
for the executable is split into two categories:
1. **Constant Parameters** – These parameters are unlikely to change during
   execution, although users can modify them in the template parameter files
   (not recommended).
2. **Modifiable Parameters** – These parameters can be adjusted by the user.

Within the modifiable parameters, there are two further categories:
- **Iterable Parameters** – Parameters whose values can vary during the
  execution of the `multiple_runs.sh` script. These are used for performing
  parameter scans.
- **Non-Iterable Parameters** – Parameters that are modifiable but remain fixed
  during the execution of `multiple_runs.sh`.

1. First, set the non-iterable parameters.
2. Then, decide which parameters from the iterable set will be varied during
   execution. You must specify at least one, but no more than three parameters
   to vary. These are referred to as the "varying parameters."
3. The remaining iterable parameters, whose values won't vary, are termed
   "constant iterable parameters."

The main program's executable requires a parameter file. This input file
provides the ability only certain parameters to be modified using this input
file, others are left constant and need an explicit modification of the empty
parameters file left to the discretion of the user. Among these modifiable
parameters from this input file, some parameters are "iterable," meaning they
can take multiple values across different executions of the "multiple_runs.sh"
script. Others are fixed, taking only a single value during each execution.
Following, an an overview, is a list of all the modifiable parameters
(regardless if they are accepted or not by the executable) split into two
groups "non-iterable" and "iterable" parameters.

The following lists allow the used to choose parameter by index and inspect its
default value:
```
# List of non-iterable parameters:
```
```
List of iterable parameters:
```

#### NON-ITERABLE PARAMETERS VALUES
Set values of non-iterable parameters NOTE: Parameters
OVERLAP_OPERATOR_METHOD, QCD_BETA_VALUE, LATTICE_DIMENSIONS have their values
set automatically using the "GAUGE_LINKS_CONFIGURATIONS_DIRECTORY" path. Only
KERNEL_OPERATOR_TYPE value needs to be set by the user, 

Choose *operator type* by setting for convenience any of the following:
- For "Standard" use: "Standard", "Stan", 0
- For "Brillouin" use: "Brillouin", "Bri", or 1
For example:
```
KERNEL_OPERATOR_TYPE_FLAG=0
```

#### NON-ITERABLE PARAMETERS VALUES PRINTED IN OUTPUT FILENAMES
Next you need to choose which of the non-iterable parameters you want them to be
printed in the filename. It's suggested that OVERLAP_OPERATOR_METHOD and
KERNEL_OPERATOR_TYPE are printed at least. Note, please, that non-iterable
parameters are printed first by default. For example:
```
LIST_OF_NON_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED=(0 1)
```

#### VARYING ITERABLE PARAMETERS AND THEIR VALUES
Choose at least 1 but no more than 3 parameters that will have their values
varied in a range or a predefined set of values. State their index in the 
array right below.
NOTE: The stated indices in the array correspond (schematically) to the nested
loops as follows: (inner loop, outer loop, overall outer loop). Thus, only the
inner loop range or set of values is mandatory to be specified even with a 
single element.
For example:
```
VARYING_PARAMETERS_INDICES_LIST=(0 1)
```
Next select the range of values or predefined (explicit) set of values of each
of the nested loops. For an explicit set values use the array format. If a 
range of values is preferred, use then the a format: "[start end step]";
do not forget to use "" for the range format.
Inner loop values; mandatory to be filled, corresponds to 1st index
```
INNER_LOOP_VARYING_PARAMETER_SET_OF_VALUES="[1 5 1]"
```
Outer loop values; fill only if a 2nd index was stated; it's ignored if not
```
OUTER_LOOP_VARYING_PARAMETER_SET_OF_VALUES=
```
Overall outer loop values, only if a 3nd index was stated, ignored if not
```
OVERALL_OUTER_LOOP_VARYING_PARAMETER_SET_OF_VALUES=
```

#### CONSTANT ITERABLE PARAMETERS WITH VALUES DIFFERENT THAN THE DEFAULT ONES

Next you need to choose values for the (iterable) parameters you chose to keep
constant throughout the multiple execution of the main program. From the list of
the iterable parameters above simply chose that you wish to have their values
modify from the default ones, and state them inside the
"LIST_OF_UPDATED_CONSTANT_VALUES" array. Remember any parameters stated here
cannot be stated simultaneously below as varying parameters, namely acquiring
possibly a different value with every execution. That will cause an error. Set
constant values of several parameters different than their default ones,
irrespective whether they are to be printed or not NOTE: Format
"parameter=parameter_value" in a column; do not forget to use "". For example:
```
LIST_OF_UPDATED_CONSTANT_VALUES=(
    "NUMBER_OF_VECTORS=5"
    "GAUGE_LINKS_CONFIGURATION_LABEL=0024200"
    )
```

#### CONSTANT ITERABLE PARAMETERS VALUES PRINTED IN FILENAMES

Selected constant iterable parameters to be printed in output files names

Select the indices of parameters to be printed in the specified order. Use "()"
for an empty list. You cannot choose any of the already stated varying
parameters. Note, also that it doesn't make much sense to print both kappa and
bare mass values. For example:
```
LIST_OF_CONSTANT_ITERABLE_PARAMETERS_INDICES_TO_BE_PRINTED=(3 6)
```

#### OPTIONAL ADDITIONAL TEXT
Finally, there's the option to add manually a suffix to the output filenames. It
can be left empty if not necessary:
```
ADDITIONAL_TEXT_TO_BE_PRINTED=
```

################################# SLURM OPTIONS ################################
Options necessary for the successful submission of Slurm jobs on the cluster

Select partition for job. Please note that on Cyclone the options are "p100" or
"nehalem". For example:
```
PARTITION_NAME="nehalem"
```
Please note that the product of MPI_GEOMETRY equals the total number of cores
used for the job. For example:
```
MPI_GEOMETRY="2,2,2"
```
Please note that on Cyclone you can only use 1, 2, or 4 nodes. For example:
```
NUMBER_OF_NODES=1
```
Please note that on Cyclone maximum 16 for "nehalem" and 32 for "p100". For
example:
```
NTASKS_PER_NODE=16
```
Please note that if reservation short is used then walltime is set automatically
to 1h. For example:
```
WALLTIME="01:00:00"
```
