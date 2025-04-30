#' Wrapper for reading and writing GUANO metadata
#'
#' @param filepath.source Character. Specify directory which contains GUANO files.
#' @param filepath.target Character.
#'
#' @importFrom magrittr %>%
#' @export
get_metadata <- function(filepath.source, filepath.target) {

  requireNamespace("guano")
### collect file metadata
### GUANO - Grand Unified Acoustic Notation Ontology
  dfmeta <- guano::read.guano.dir(filepath.source, recursive=TRUE)

  dfmeta <- dfmeta %>%
    #  mutate(File.Size = file.size(File.Path)) %>% ### add filesize (take some time!)
    dplyr::mutate(Hour = lubridate::hour(Timestamp)) %>%
    dplyr::mutate(Date = lubridate::date(Timestamp))
  utils::write.csv(dfmeta, file = filepath.target, row.names = FALSE)
}

