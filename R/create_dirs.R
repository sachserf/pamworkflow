#' Create directories for audio files
#'
#' @param filepath.target Character. Specify the full file path to the directory for the sample. The last subdirectory should designate a unique identifier for the location of the device that recorded the audio files.
#' @param YMDstart Character. Specify the date of the first recoring in the format YYYYmmdd.
#' @param YMDend Character. Specify the date of the last recoring in the format YYYYmmdd.
#' @param content Character. User-defined specification for the target directory.
#'
#' @export
#'
create_dirs <- function(filepath.target, YMDstart, YMDend, content) {

  path2site <- basename(filepath.target)
  path2date <- paste0(path2site, "_", YMDstart, "-", YMDend)
  path2files <- paste0(path2date, "_", content)

  filepath <- file.path(filepath.target, path2date, path2files)

  if(dir.exists(filepath)) {
    warning(paste("Directory already exists. Check input!"))
  } else {
    dir.create(filepath, recursive = TRUE)
    message(paste("Created directory:", filepath))
  }
  return(filepath)
}

