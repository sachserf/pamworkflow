#' Write predefined plots from BirdNET selection table
#'
#' @param BirdNET_selection_table Character. Specify full file path to a BeridNET selection table (Raven compatible format).
#' @param dirname.target.figures Character. Specify file path to to the target directory for the figures.
#'
#' @importFrom magrittr %>%
#' @export
visualize_birdnet <- function(BirdNET_selection_table, dirname.target.figures) {

df <- rio::import(BirdNET_selection_table)   #### substitude with base function?!

df <- df %>%
  dplyr::mutate(bins = cut(Confidence, breaks = seq(0, 1, length.out = 11), labels = FALSE, include.lowest = TRUE)/10)

df <- df %>%
  dplyr::group_by(`Common Name`) %>%
  dplyr::mutate(mean = mean(Confidence)) %>%
  dplyr::ungroup() %>%
  dplyr::distinct(`Common Name`, mean) %>%
  dplyr::arrange(mean) %>%
  tibble::rowid_to_column() %>%
  dplyr::select(-mean) %>%
  dplyr::left_join(df, ., by = dplyr::join_by(`Common Name`))

fig1 <- df %>%
  dplyr::count(bins, `Common Name`, rowid) %>%
  dplyr::mutate(score = n*bins) %>%
  ggplot2::ggplot() +
  ggplot2::geom_tile(ggplot2::aes(bins, stats::reorder(`Common Name`, rowid), fill = log(n))) +
  ggplot2::scale_fill_viridis_b() +
  ggplot2::scale_x_continuous(breaks = seq(0, 1, by = .1)) +
  ggplot2::labs(y = "Common Name") +
  ggplot2::theme_minimal() +
  ggplot2::theme(panel.grid.minor = ggplot2::element_blank())

ggplot2::ggsave(fig1, filename = file.path(dirname.target.figures, "speciesBins.png"), height = 13)

fig2 <- df %>%
  ggplot2::ggplot() +
  ggplot2::geom_boxplot(ggplot2::aes(Confidence, stats::reorder(`Common Name`, rowid))) +
  ggplot2::scale_x_continuous(breaks = seq(0, 1, by = .1)) +
  ggplot2::labs(y = "Common Name") +
  ggplot2::theme_minimal() +
  ggplot2::theme(panel.grid.minor = ggplot2::element_blank())

ggplot2::ggsave(fig2, filename = file.path(dirname.target.figures, "speciesConfidence.png"), height = 13)
}
