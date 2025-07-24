#' Write a log file of the specified parameters
#'
#' @param params Object of class data.frame. A data frame containing information about specified parameters.
#' @param filepath.logfile Character. Specify file path to a log file. A new file will be written, if missing.
#'
#' @export
write_log <- function(params, filepath.logfile = NULL) {

  if(is.null(filepath.logfile)) return(message("No log file specified."))

  if(file.exists(filepath.logfile)) {
    logfile <- rio::import(filepath.logfile)
    UID <- params$UID <- nrow(logfile)+1
    params <- dplyr::bind_rows(logfile, params)
  } else {
    dir.create(dirname(filepath.logfile), recursive = TRUE, showWarnings = FALSE)
    UID <- params$UID <- 1
  }

  rio::export(params, filepath.logfile, overwrite = TRUE)
  return(UID)
}
