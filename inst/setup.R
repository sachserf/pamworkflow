require("magrittr")

################################################################################
############################### get_rec_duration ###############################
################################################################################

recording.duration <- pamworkflow::get_recording_duration(filepath.source = filepath.source)

################################################################################
############################## create directories ##############################
################################################################################

filepath.original <- pamworkflow::create_dirs(
  filepath.target = filepath.target,
  YMDstart = as.integer(recording.duration[1]),
  YMDend = as.integer(recording.duration[2]),
  content = "original"
)

filepath.metadata <- pamworkflow::create_dirs(
  filepath.target = filepath.target,
  YMDstart = as.integer(recording.duration[1]),
  YMDend = as.integer(recording.duration[2]),
  content = "metadata"
)

filepath.figures <- pamworkflow::create_dirs(
  filepath.target = filepath.target,
  YMDstart = as.integer(recording.duration[1]),
  YMDend = as.integer(recording.duration[2]),
  content = "figures"
)

filepath.birdnet <- pamworkflow::create_dirs(
  filepath.target = filepath.target,
  YMDstart = as.integer(recording.duration[1]),
  YMDend = as.integer(recording.duration[2]),
  content = "birdnet"
)

filepath.processing <- pamworkflow::create_dirs(
  filepath.target = filepath.target,
  YMDstart = as.integer(recording.duration[1]),
  YMDend = as.integer(recording.duration[2]),
  content = "processing"
)

################################################################################
################################ define params ################################
################################################################################

filepath.instructions <- file.path(dirname(filepath.original), "instructions.txt")

params <- tibble::tibble(
  timestamp = Sys.time(),
  filepath.target = filepath.target,
  filepath.source = filepath.source,
  first.rec = as.integer(recording.duration[1]),
  last.rec =  as.integer(recording.duration[2]),
  filepath.original = filepath.original,
  filepath.metadata = filepath.metadata,
  filepath.figures = filepath.figures,
  filepath.birdnet = filepath.birdnet,
  filepath.processing = filepath.processing,
  filepath.specieslist = file.path(filepath.metadata, "specieslist.txt"),
  filepath.instructions = filepath.instructions,
  filepath.logfile = filepath.logfile,
  filepath.params = file.path(filepath.metadata, "params.csv"),
  processed.at = as.POSIXct(NA),
  COMMENT = NA
)

rio::export(params, file = params$filepath.params)

################################################################################
################################# write config #################################
################################################################################

#source("R/config2df.R")
pamworkflow::config2df(filepath.config = file.path(params$filepath.source, "CONFIG.TXT"),
          filepath.export = file.path(params$filepath.metadata, "config_audiomoth.csv"))

################################################################################
########################## Write predefined scripts. ##########################
################################################################################

text_01metadata <- paste0("foo <- utils::read.csv('", file.path(params$filepath.metadata, "params.csv')"),
                          "\n\n",
                          "pamworkflow::get_metadata(filepath.source = foo$filepath.original, filepath.target = file.path(foo$filepath.metadata, 'dfmeta.csv'))",
                          "\n\n",
                          "pamworkflow::visualize_metadata(filepath.metadata.csv = file.path(foo$filepath.metadata, 'dfmeta.csv'), dirname.target.figures = foo$filepath.figures)")
writeLines(text = text_01metadata, con = file.path(params$filepath.processing, "01_metadata.R"))

### copy speciesList
file.copy(from = system.file("species_list.txt", package = "pamworkflow"),
          to = params$filepath.specieslist)

### write birdnet.py
birdnet_call <- pamworkflow::call_birdnet.py(input = params$filepath.original,
                output = params$filepath.birdnet,
                slist = params$filepath.specieslist)
writeLines(birdnet_call, con = file.path(params$filepath.processing, "02_birdnet.py"))

### visualize BirdNET
text_03_visualize_birdnet <- paste0("foo <- utils::read.csv('", file.path(params$filepath.metadata, "params.csv')"),
                          "\n\n",
                          "pamworkflow::visualize_birdnet(BirdNET_selection_table = file.path(foo$filepath.birdnet, 'BirdNET_SelectionTable.txt'), dirname.target.figures = foo$filepath.figures)")
writeLines(text = text_03_visualize_birdnet, con = file.path(params$filepath.processing, "03_visualize_birdnet.R"))

### write update_logfile.R
update_log <-  paste0("pamworkflow::update_logfile(filepath.params = '", params$filepath.params, "', filepath.logfile = '", params$filepath.logfile, "')")
#update_log <- pamworkflow::update_logfile(filepath.params = params$filepath.params, filepath.logfile =  params$filepath.logfile)
writeLines(update_log, con = file.path(params$filepath.processing, "04_update_log.R"))

################################################################################
################################ write logfile ################################
################################################################################

pamworkflow::write_log(params, filepath.logfile)

################################################################################
############################## write instructions ##############################
################################################################################

instructions_text <- paste0("1. Edit the file params.R with any text editor and specify the file paths. Then close the file and execute it with the next step:
2. Rscript ~/path/to/your/params.R
3. Copy ALL files from ", params$filepath.source, " to ", params$filepath.original, ", using the software of your choice.
4. Rscript ", file.path(params$filepath.processing, '01_metadata.R'), "
5. source ~/path/to/your/BirdNET-Analyzer/installation/.venv/bin/activate
6. source ", file.path(params$filepath.processing, '02_birdnet.py'), "
7. Rscript ", file.path(params$filepath.processing, '03_visualize_birdnet.R'),"
8. Rscript ", file.path(params$filepath.processing, '04_update_log.R'),"

OneLiner after copying files:
Rscript ", file.path(params$filepath.processing, '01_metadata.R'), "; source ", file.path(params$filepath.processing, '02_birdnet.py'), "; Rscript ", file.path(params$filepath.processing, '03_visualize_birdnet.R'), "; Rscript ", file.path(params$filepath.processing, '04_update_log.R'))

writeLines(text = instructions_text, con = filepath.instructions)

message(
  paste0(
    "\n\n**********Setup finished**********\n\n",
    "Now, follow the instructions below (start with step 3):",
    "\n(Instructions also written to: ",
    filepath.instructions,"):",
    "\n\n---------------------------------------------------------\n",
    instructions_text,
    "\n---------------------------------------------------------"
  )
)

