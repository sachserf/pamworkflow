# Installation

## R 
### guano (precondition)

**if you don´t have the guano package installed, see**   https://github.com/riggsd/guano-r

### this package

devtools::install_github('sachserf/pamworkflow')

## Python 3.11
### BirdNET

**There are multiple options to install BirdNET. The proposed workflow uses the command line installation of BirdNET.**

**For general installation instructions and usage, see**   https://birdnet-team.github.io/BirdNET-Analyzer/installation.html

**Summary of installation instructions with command line:**  

#### Linux

git clone https://github.com/birdnet-team/BirdNET-Analyzer.git  
cd BirdNET-Analyzer  
python3.11 -m venv .venv  
source .venv/bin/activate  
pip install .  
pip install keras_tuner  
deactivate  

#### Windows

git clone https://github.com/birdnet-team/BirdNET-Analyzer.git  
cd BirdNET-Analyzer  
python -m venv .venv  
. .\.venv\Scripts\activate  
pip install .  
pip install keras_tuner  
deactivate  

# usage

## summary of the general workflow

- You collected data with Audiomoth (configured with 'daily folders'-option)
- The file params.R (see next chapter) contains the information needed to set up everything for the workflow. The location of the file is not associated to the workflow and can be anywhere on the system (Desktop, Downloads-folder, etc). When it has been sourced, it is not needed anymore. Either delete it or reuse it next time.
- Running the script set up the workflow by writing directories and files at the target filepath specified in the params.R-file. 
- Now copy ALL files from the source (e.g. micro-SD-card) to the target (directory ends with '_original') with the software of your choice (file manager, command line program, etc.). 
- Go to the target directory and invoke the scripts in the predefined order: Use 'Rscript' or 'Source' - according to the file ending (more information below).
    - The first script will extract metadata of your Audio-files using the GUANO metadata standard via the R-package 'guano'.
    - The second script will run BirdNET via python. In case you installed BirdNET within a dedicated environment (recommended), you need to enter the environment before invoking the script.
    - The third script is an optional R-Script to visualize the output of BirdNET.

## first invocation after installation

**Copy the file *params.R* to a destination of your choice. You could reuse this file at any time. If you deleted it, just copy it with the following command from within R:**  

>> file.copy(from = system.file('params.R', package = 'pamworkflow'), to = '~/path/to/target/params.R')

**The whole workflow is based on scripts, executed via command line (e.g. bash, Powershell, etc.) and you don´t need to run an R or python session. Therefore, after copying the params.R-file: Exit R.**

## standard usage with existing params.R-file

**1. Edit the file params.R with any text editor and specify the file paths. Then close the file and execute it with the next step:**   
**2. Rscript ~/path/to/your/params.R**  
**3. Copy ALL files from source to target, using the software of your choice.**  
**4. Rscript ~/path/to/target/01_metadata.R**  
**5. source ~/path/to/your/BirdNET-Analyzer/installation/.venv/bin/activate**  
**6. source ~/path/to/target/02_birdnet.py**  
**7. Rscript ~/path/to/target/03_visualize_birdnet.R**  

>> Note: The command Rscript is meant to run scripts directly from command line without opening R. Check proper installation via 'Rscript --version'. Depending on the operating system, it might be necessary to add Rscript to your PATH when using it for the first time.

