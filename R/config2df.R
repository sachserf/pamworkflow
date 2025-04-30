#' Tabularize Audiomoth configuration file
#'
#' @param filepath.config Character. Specify filepath to the directory containing all files copied from the microSD-card of the AudioMoth.
#' @param filepath.export Character. Optionally specify filepath to export results as csv.
#'
#' @importFrom magrittr %>%
#' @export
config2df <- function(filepath.config, filepath.export = NULL) {
  config <- file.path(filepath.config)
  if (!file.exists(config)) {
    stop(paste("CONFIG.TXT does not exist. Check filepath.config:", filepath.config))
  }

    dfconfig <- utils::read.delim(config, header = FALSE) %>%
      tidyr::separate(., "V1", c("name", "value"), ":", extra = "merge") %>%
      dplyr::mutate(name = stringr::str_squish(name)) %>%
      dplyr::mutate(value = stringr::str_squish(value)) %>%
      tidyr::pivot_wider(names_from = name, values_from = value) %>%
      dplyr::rename(Serial = "Device ID")

  ### export
  if (!is.null(filepath.export)) {
#    target <- function(label, file_ext) file.path(dirname(dirname(filepath.config)), paste0(label, ".", file_ext))
#  write.csv(dfconfig, file = target(label = "config_AudioMoth", file_ext = "csv"))
#  message(paste0("Exported configuraion to: ", target(label = "config_AudioMoth", file_ext = "csv")))
    utils::write.csv(dfconfig, filepath.export, row.names = FALSE)
  }
  return(dfconfig)
}

