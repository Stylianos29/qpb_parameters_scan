# Description

This is a BASH project designed as a wrapper for the [qpb
project](https://github.com/g-koutsou/qpb). Its main purpose is to simplify and
automate parameter scans for qpb executables. The project allows users to
explore different sets of input parameters values for the qpb program by varying
selected parameters over multiple runs, automating the process and minimizing
manual changes to input files.

# Installation

1. **Clone the repository** to a directory of your choice, preferably outside
   the qpb project directory.
2. **Navigate** to the `qpb_parameters_scan/main_scripts` directory.
3. **Run** the following command, where `<main_program_directory>` is the full
   path to a qpb `main_program` directory that contains the executable:
   ```bash
   ./setup -p <main_program_directory>
   ```

# Instructions

1. **Navigate** to `<main_program_directory>/qpb_parameters_scan_files`.
2. **Read** the `input_file_instructions.md` file for detailed guidelines on
   filling in the `input.txt` file.
3. **Set** the appropriate values in `input.txt` according to the parameter scan
   you wish to perform.
4. **Execute** the script:
    ```bash
    ./scan.sh
   ```
