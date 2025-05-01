#' Write a log file of the specified parameters
#'
#' @param filepath.logfile Character. Specify file path to a log file. A new file will be written, if missing.
#' @param filepath.source Character. Specify the variable filepath.source.
#' @param filepath.target Character. Specify the variable filepath.target.
#'
#' @export
write_log <- function(filepath.logfile = NULL, filepath.source, filepath.target) {

  if(is.null(filepath.logfile)) return(message("No log file specified."))

  df <- tibble::tibble(timestamp = Sys.time(), filepath.logfile, filepath.source, filepath.target)

  if(file.exists(filepath.logfile)) {
    logfile <- rio::import(filepath.logfile)
    df <- dplyr::bind_rows(logfile, df)
  } else {
    dir.create(dirname(filepath.logfile), recursive = TRUE, showWarnings = FALSE)
  }
  rio::export(df, filepath.logfile, overwrite = TRUE)
}

