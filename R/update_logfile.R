#' Add current timestamp to logfile
#'
#' @param filepath.params Character. Filepath to params.csv
#' @param filepath.logfile Character. Filepath to logfile.csv
#'
#' @export
update_logfile <- function(filepath.params, filepath.logfile) {

  if (!file.exists(filepath.params)) {
    stop() ###paste("Cannot find", filepath.params)
  } else {
    params <- rio::import(filepath.params)
  }

  if (!file.exists(filepath.logfile)) {
    stop()  ### paste("Cannot find", filepath.logfile)
  } else {
    logfile <- rio::import(filepath.logfile)
  }

  row_id <- logfile %>%
    dplyr::mutate(row_id = dplyr::row_number()) %>%
    dplyr::semi_join(params) %>%
    dplyr::pull(row_id)

  if (length(row_id == 1)) {
    thisisnow <- Sys.time()
    params$processed.at <- thisisnow
    logfile$processed.at <- as.POSIXct(logfile$processed.at)
    logfile$processed.at[row_id] <- thisisnow
    rio::export(params, filepath.params, overwrite = TRUE)
    rio::export(logfile, filepath.logfile, overwrite = TRUE)
    message(paste("Processed at", thisisnow))
  } else {
    stop("Rows do not match - skip update.")
  }
}
