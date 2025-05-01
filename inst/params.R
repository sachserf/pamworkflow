### start clean
rm(list=ls());gc()

### Character. specify the full file path to the directory where the AudioMoth files are stored (e.g. the full path to the microSD card)
filepath.source <- "/media/user/fs01"

### Character. Specify the full file path to the target directory for further processing of the files. The last subdirectory should designate a unique (!) identifier for the location of the device that recorded the audio files.
filepath.target <- "~/path/to/your/project/SITELOC_ID12"

### Character. Optional. Specify the full file path to a csv file to write a log. If you do not want to write a log file, use: filepath.logfile <- NULL
filepath.logfile <- "~/path/to/your/project/logfile.csv"

source(system.file("setup.R", package = "pamworkflow"))
