#' Add current timestamp to logfile
#'
#' @param UID Integer. Unique Identifier.
#' @param filepath.logfile Character. Filepath to logfile.csv
#'
#' @export
update_logfile <- function(UID, filepath.logfile) {

  if (!file.exists(filepath.logfile)) {
    stop(paste("Cannot find", filepath.logfile))
  } else {
    logfile <- rio::import(filepath.logfile)
  }

  row_id <- which(logfile$UID == UID)
  thisisnow <- Sys.time()
  logfile$processed.at <- as.POSIXct(logfile$processed.at)
  logfile$processed.at[row_id] <- thisisnow
  rio::export(logfile, filepath.logfile, overwrite = TRUE)
  message(paste("Processed at", thisisnow))
}
