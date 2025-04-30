#' get first and last recording date
#'
#' @param filepath.source Character. Specify the full file path to the directory where the AudioMoth files are stored (e.g. the full path to the microSD card). The directory should contain daily folders with names of dates in the format YYYYmmdd.
#'
#' @export
#'
get_recording_duration <- function(filepath.source) {
  if(!file.exists(file.path(filepath.source, "CONFIG.TXT"))) {
    stop("file path to micro SD does not contain the file 'CONFIG.TXT'. Check path and retry.")
  } else {
    mydirs <- list.dirs(path = filepath.source, full.names = FALSE, recursive = FALSE)
    valid_flags <- sapply(mydirs, function(x) !is.na(lubridate::ymd(x, quiet = TRUE)))
    recording.duration <- range(sort(mydirs[valid_flags]))
    if (is.null(recording.duration)) {
      stop("file path to micro SD contains no daily directories with audiofiles. Exit.")} else {
        return(recording.duration)
      }
    #as.Date(recording_duration, format = "%Y%m%d")
    #paste(recording_duration, collapse = "-")
  }
}
