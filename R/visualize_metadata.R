#' Plot predefined figures of metadata
#'
#' @param filepath.metadata.csv Character. Specify file path to csv containing GUANO metadata.
#' @param dirname.target.figures Character. Specify file path to to the target directory for the figures.
#'
#' @importFrom magrittr %>%
#' @export
visualize_metadata <- function(filepath.metadata.csv, dirname.target.figures) {

  dfmeta <- rio::import(filepath.metadata.csv)

  ### Visualization of Recording periods/failures
  fig1 <- dfmeta %>%
    ggplot2::ggplot() +
    ggplot2::geom_point(ggplot2::aes(Timestamp, Temperature.Int, color = as.numeric(OAD.Battery.Voltage)), size = 3)
  ggplot2::ggsave(fig1, filename = file.path(dirname.target.figures, "fig1_temperature_history_and_battery_voltage.png"))

  fig2 <- dfmeta %>%
    #  filter(File.Size > 0) %>%
    dplyr::count(Date, Hour) %>%
    ggplot2::ggplot() +
    ggplot2::geom_tile(ggplot2::aes(Date, Hour, fill = n)) +
    ggplot2::labs(caption = "Number of files per day and hour") +
    ggplot2::scale_fill_viridis_c()
  ggplot2::ggsave(fig2, filename = file.path(dirname.target.figures, "fig2_files_per_day_and_hour.png"))

  fig3 <- dfmeta %>%
    #  filter(File.Size > 0) %>%
    ggplot2::ggplot() +
    ggplot2::geom_histogram(ggplot2::aes(Date)) +
    ggplot2::labs(caption = "Number of files per day")
  ggplot2::ggsave(fig3, filename = file.path(dirname.target.figures, "fig3_files_per_day.png"))

}

