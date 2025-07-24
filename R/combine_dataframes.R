#' Combine multiple similar dataframes
#' @description
#' A wrapper function that reads and combines dataframes with the data.table-package.
#'
#' @param file_paths Character vector. Specify a vector of filepaths to multiple dataframes. Intended usage is to combine BirdNET-results by using the column 'filepath.birdnet.selection.table' from the log-file.
#'
#' @importFrom magrittr %>%
#' @export

combine_dataframes <- function(file_paths) {
  combined_df <- data.table::rbindlist(lapply(file_paths, data.table::fread), use.names = TRUE, fill = TRUE)

  return(combined_df)
}

