### start clean
rm(list=ls());gc()

### Character. Specify the path to your BirdNET installation and the command to enter the virtual environment of your birdnet installation (command depends on operating system)
### Linux example: birdnet_venv <- paste("source", shQuote(normalizePath("~/git/BirdNET-Analyzer/.venv/bin/activate", winslash = "/", mustWork = FALSE)))
### Windows example: birdnet_venv <- paste(shQuote(normalizePath("C:\\path\\to\\BirdNET-Analyzer\\.venv\\Scripts\\activate", winslash = "/", mustWork = FALSE)))
birdnet_venv <- paste("source", shQuote(normalizePath("~/git/BirdNET-Analyzer/.venv/bin/activate", winslash = "/", mustWork = FALSE)))

### Character. specify the full file path to the directory where the AudioMoth files are stored (e.g. the full path to the microSD card)
filepath.source <- "/media/user/fs01"

### Character. Specify the full file path to the target directory for further processing of the files. The last subdirectory should designate a unique (!) identifier for the location of the device that recorded the audio files.
filepath.target <- "~/path/to/your/project/SITELOC_ID12"

### Character. Optional. Specify the full file path to a tsv file (tab-separated file) to write a log. If you do not want to write a log file, use: filepath.logfile <- NULL
filepath.logfile <- "~/path/to/your/project/logfile.tsv"

### optionally add a command line command to copy files, where filepath.target is a placeholder that will be automatically adjusted/completed. The command will not be executed but prepared and printed on screen for a faster workflow.
### If you do not want to add a command set "copycmd <- NULL"
copycmd <- paste("rsync -a --info=progress2", shQuote(filepath.source), shQuote(filepath.target))

### create directories, write log, prepare scripts and instructions for further processing: 
source(system.file("setup.R", package = "pamworkflow"))

