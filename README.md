# Description

This is a BASH project designed as a wrapper for the [qpb project](https://github.com/g-koutsou/qpb). Its main purpose is to simplify and automate parameter scans for qpb executables, allowing users to efficiently explore different configurations. The project allows users to explore different sets of input parameters for the qpb program by varying selected parameters over multiple runs, automating the process and minimizing manual changes to input files.

# Installation

1. **Clone the repository** to a directory of your choice, preferably outside the qpb project directory.
2. **Navigate** to the `multiple_runs_project/main_scripts` directory.
3. **Run** the following command, where `<main_program_directory>` is the full path to a qpb `main_program` directory that contains the executable:
   ```bash
   ./setup p <main_program_directory>
   ```
4. **Navigate** to `<main_program_directory>/multiple_runs_scripts`.
5. **Read** the `input_file_instructions.md` file for detailed guidelines on filling in the `input.txt` file.
6. **Set** the appropriate values in `input.txt` according to the parameter scan you wish to perform.
7. **Execute** the script:
    ```bash
    ./multiple_runs.sh
   ```
