require("magrittr")

### normalize paths
filepath.source <- normalizePath(filepath.source, winslash = "/", mustWork = FALSE)
filepath.target <- normalizePath(filepath.target, winslash = "/", mustWork = FALSE)
filepath.logfile <- normalizePath(filepath.logfile, winslash = "/", mustWork = FALSE)

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
  filepath.birdnet.selection.table = file.path(filepath.birdnet, "BirdNET_SelectionTable.txt"),
  filepath.processing = filepath.processing,
  filepath.specieslist = file.path(filepath.metadata, "specieslist.txt"),
  filepath.instructions = filepath.instructions,
  filepath.logfile = filepath.logfile,
  filepath.params = file.path(filepath.metadata, "params.csv"),
  processed.at = as.POSIXct(NA),
  COMMENT = NA
)

if (!is.null(copycmd)) params$copycmd <- gsub(filepath.target, filepath.original, copycmd)

if (file.exists(file.path(params$filepath.original, "CONFIG.TXT"))) stop("Abort: CONFIG.TXT already exists in target directory. Choose another target and retry.")

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
birdnet_call <- pamworkflow::call_birdnet.py(input = shQuote(params$filepath.original),
                output = shQuote(params$filepath.birdnet),
                slist = shQuote(params$filepath.specieslist),
                threads = birdnet_threads, batch_size = birdnet_batchsize)
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
############################# prepare instructions #############################
################################################################################

instructions_stepbystep <- paste0("1. Edit the file params.R with any text editor and specify the file paths. Then close the file and execute it with the next step:
2. Rscript ~/path/to/your/params.R
3. Copy ALL files from ", params$filepath.source, " to ", params$filepath.original, ", using the software of your choice.
4. Rscript ", file.path(params$filepath.processing, '01_metadata.R'), "
5. ", birdnet_venv, "
6. ", birdnet_call, "
7. Rscript ", file.path(params$filepath.processing, '03_visualize_birdnet.R'),"
8. Rscript ", file.path(params$filepath.processing, '04_update_log.R'))

if (is.null(copycmd)) {
  instructions_stepbystep <- paste0("1. Edit the file params.R with any text editor and specify the file paths. Then close the file and execute it with the next step:
  2. Rscript ~/path/to/your/params.R
  3. Copy ALL files from ", params$filepath.source, " to ", params$filepath.original, ", using the software of your choice.
  4. Rscript ", shQuote(file.path(params$filepath.processing, '01_metadata.R')), "
  5. ", birdnet_venv, "
  6. ", birdnet_call, "
  7. Rscript ", shQuote(file.path(params$filepath.processing, '03_visualize_birdnet.R')),"
  8. Rscript ", shQuote(file.path(params$filepath.processing, '04_update_log.R')))
} else {
  instructions_stepbystep <- paste0("1. Edit the file params.R with any text editor and specify the file paths. Then close the file and execute it with the next step:
  2. Rscript ~/path/to/your/params.R
  3. ", params$copycmd, "
  4. Rscript ", shQuote(file.path(params$filepath.processing, '01_metadata.R')), "
  5. ", birdnet_venv, "
  6. ", birdnet_call, "
  7. Rscript ", shQuote(file.path(params$filepath.processing, '03_visualize_birdnet.R')),"
  8. Rscript ", shQuote(file.path(params$filepath.processing, '04_update_log.R')))
}


oneliner <- paste0("Rscript ", shQuote(file.path(params$filepath.processing, '01_metadata.R')), "; ", birdnet_venv, "; ", birdnet_call, "; Rscript ", shQuote(file.path(params$filepath.processing, '03_visualize_birdnet.R')), "; Rscript ", shQuote(file.path(params$filepath.processing, '04_update_log.R')))

instructions_text <- paste(c(instructions_stepbystep, "OneLiner after copying files:", oneliner), collapse = ", ")

params$processing_oneliner <- oneliner  ### add oneliner to logfile

################################################################################
################################# write params #################################
################################################################################

rio::export(params, file = params$filepath.params)

################################################################################
################################ write logfile ################################
################################################################################

pamworkflow::write_log(params, filepath.logfile)

################################################################################
############################## write instructions ##############################
################################################################################

writeLines(text = instructions_text, con = filepath.instructions)

if (is.null(copycmd)){
final_message <- paste0(
  "\n\n**********Setup finished**********\n\n",
  "Now, follow the instructions below (start with step 3):",
  "\n(Instructions also written to: ",
  filepath.instructions,"):",
  "\n\n---------------------------------------------------------\n",
  instructions_stepbystep,
  "\n\n---------------------------------------------------------\n",
  "OneLiner after copying files:\n",
  oneliner,
  "\n---------------------------------------------------------"
)
} else {
  final_message <- paste0(
    "\n\n**********Setup finished**********\n\n",
    "Now, follow the instructions below (start with step 3):",
    "\n(Instructions also written to: ",
    filepath.instructions,"):",
    "\n\n---------------------------------------------------------\n",
    instructions_stepbystep,
    "\n\n---------------------------------------------------------\n",
    "Copy files via:\n",
    params$copycmd,
    "\n\n---------------------------------------------------------\n",
    "OneLiner after copying files:\n",
    oneliner,
    "\n---------------------------------------------------------"
  )

}

message(final_message)

