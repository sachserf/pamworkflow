#' Clip and concatenate WAV-files and selection tables
#'
#' @param input_file Character. File path to a BirdNET-selection-table.TXT.
#' @param output_dir Character. Directory for the output.
#' @param n_samples Integer. Number of samples per bin and BirdNET class (Species).
#' @param confidence_threshold Numeric. Minimum confidence threshold of the samples.
#' @param sec_before Numeric. Time (in seconds) that should be added to the clipped Audio before the actual snippet of interest.
#' @param sec_after Numeric. Time (in seconds) that should be added to the clipped Audio after the actual snippet of interest.
#' @param birdnet_clip_length Numeric. Clip length of the snippet of interest in seconds.
#' @param seed Integer. Set seed for the drawing the samples.
#' @param dur_silence Numeric. Time (in seconds) with silence between each clip.
#' @param target_species Character. Specify names of BirdNET classes according to the language of the Common Names of the input selection table. Separate multiple classes via |. The string will be evaluated by grepl i.e. 'owl' will return any class with 'owl' in its name.
#'
#' @importFrom magrittr %>%
#' @export
clipcat_birdnet_data <- function(input_file, output_dir, target_species, n_samples = 100, confidence_threshold = 0.6, sec_before = 5, sec_after = 12, birdnet_clip_length = 3, seed = 2354, dur_silence = 0.5) {

  # Load data
  df <- rio::import(input_file)

  # Add bins and row identifier
  df <- df %>%
    dplyr::mutate(bins = cut(Confidence, breaks = seq(0, 1, length.out = 11), labels = FALSE, include.lowest = TRUE) / 10) %>%
    tibble::rowid_to_column(var = "rowuid")

  # Create target directory
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
  save(df, file = file.path(output_dir, "df_rowuid.RData"))

  # Set seed
  set.seed(seed)

  # Subsample data
  index_verify <- df %>%
    dplyr::filter(Confidence >= confidence_threshold) %>%
    dplyr::filter(grepl(target_species, `Common Name`)) %>%
    dplyr::group_by(bins, `Common Name`) %>%
    dplyr::slice_sample(n = n_samples, replace = FALSE) %>%
    dplyr::ungroup() %>%
    dplyr::pull(rowuid)

  if(length(index_verify)==0) stop("Can not find snippets that fit to the specified requirements. Check language and minimum confidence threshold and retry.")

  df <- df %>% dplyr::mutate(subsample = rowuid %in% index_verify)

  # Prepare dfsample
  dfsample <- df %>%
    dplyr::filter(subsample == TRUE) %>%
    dplyr::select(Selection, View, Channel, `Begin Path`, `Begin Time (s)`, `End Time (s)`, `Low Freq (Hz)`, `High Freq (Hz)`, Confidence, `File Offset (s)`, bins, rowuid, `Common Name`)


  # add informaton with start+end of clips (the actual clip with additional audio for the context) and beginning of the snippet (BirdNET snippet)
  max_duration <- max(dfsample$`File Offset (s)`) + birdnet_clip_length

  dfsample <- dfsample %>%
    dplyr::mutate(
      clip_start = pmax(`File Offset (s)` - sec_before, 0),
      snippet_start = `File Offset (s)` - clip_start,
      clip_end = pmin(`File Offset (s)` + birdnet_clip_length + sec_after, max_duration),
      clip_duration = clip_end - clip_start,
      label = NA,
      reference_recording = NA,
      other_species = NA,
      comment = NA
    )

  # Check if source files exist
  if (any(!file.exists(dfsample$`Begin Path`))) {
    warning("At least one source file does not exist!")
    return(NULL)
  } else {
    message("All source files exist - continuing processing.")
  }


  # prepare a command for sox to each row
  dfsample <- dfsample %>%
    dplyr::rowwise() %>%
    dplyr::mutate(sox_cmd = paste0("'|sox ", `Begin Path`, " -p trim ", clip_start, " ", clip_duration, " pad 0", dur_silence, "'")) %>%
    dplyr::ungroup()

  # specify sox commands for each group (bins and BirdNET class/species)
  dfsox <- dfsample %>%
    dplyr::group_by(`Common Name`, bins) %>%
    dplyr::summarise(sox_call = paste0(sox_cmd, collapse = " "), .groups = 'drop') %>%
    dplyr::mutate(
      sox_call = paste("sox --combine sequence", sox_call, file.path(output_dir, paste0(gsub(" ", "", `Common Name`), "_", bins * 100, ".WAV"))),
      seltab = file.path(output_dir, paste0(`Common Name`, "_", bins * 100, ".TXT"))
    )

  # correct Begin Time (s) and End Time (s) of the selection tables according to the new clips
  dfsel <- dfsample %>%
    dplyr::mutate(seltab = file.path(output_dir, paste0(gsub(" ", "", `Common Name`), "_", bins * 100, ".TXT"))) %>%
    dplyr::group_by(`Common Name`, bins) %>%
    dplyr::mutate(
      lagdur = dplyr::lag(clip_duration, n = 1L, default = 0) + dur_silence,
      `Begin Time (s)` = snippet_start + cumsum(lagdur),
      `End Time (s)` = `Begin Time (s)` + birdnet_clip_length
    ) %>%
    select(-lagdur) %>%
    ungroup()

  # Write selection tables for each group
  loopi <- dfsel %>%
    dplyr::select(seltab) %>%
    dplyr::distinct() %>%
    dplyr::arrange(seltab)

  for (i in loopi$seltab) {
    dfsel %>%
      dplyr::filter(seltab == i) %>%
      dplyr::select(-seltab, -sox_cmd) %>%
      rio::export(., file = i)
  }

  # Run sox commands to write WAVs (one file for each group - same as selection tables)
  for (i in dfsox$sox_call) {
    message("Processing: ", i)
    system(i)
  }

  message("Processing complete!")
}
