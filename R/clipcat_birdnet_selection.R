#' Clip and concatenate WAV-files and selection tables
#'
#' @param df Character. Dataframe of a birdnet selection table inclduing the follwing variables: Selection, View, Channel, `Begin Path`, `Begin Time (s)`, `End Time (s)`, `Low Freq (Hz)`, `High Freq (Hz)`, Confidence, `File Offset (s)`, rowid, `Common Name`.
#' @param output_dir Character. Directory for the output.
#' @param sec_before Numeric. Time (in seconds) that should be added to the clipped Audio before the actual snippet of interest.
#' @param sec_after Numeric. Time (in seconds) that should be added to the clipped Audio after the actual snippet of interest.
#' @param birdnet_clip_length Numeric. Clip length of the snippet of interest in seconds.
#' @param dur_silence Numeric. Time (in seconds) with silence between each clip.
#'
#' @importFrom magrittr %>%
#' @export
clipcat_birdnet_selection <- function(df, output_dir,
                                      sec_before = 5,
                                      sec_after = 12,
                                      birdnet_clip_length = 3,
                                      dur_silence = 0.5) {

  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
  save(df, file = file.path(output_dir, "df_rowuid.RData"))

  dfsample <- df %>%
    dplyr::select(Selection, View, Channel, `Begin Path`, `Begin Time (s)`,
                  `End Time (s)`, `Low Freq (Hz)`, `High Freq (Hz)`,
                  Confidence, `File Offset (s)`, rowid, `Common Name`) %>%
    dplyr::mutate(
      clip_start = pmax(`File Offset (s)` - sec_before, 0),
      snippet_start = `File Offset (s)` - pmax(`File Offset (s)` - sec_before, 0),
      clip_end = pmin(`File Offset (s)` + birdnet_clip_length + sec_after,
                      max(`File Offset (s)`) + birdnet_clip_length),
      clip_duration = clip_end - clip_start,
      label = NA_character_,
      reference_recording = NA_character_,
      other_species = NA_character_,
      comment = NA_character_
    )

  # Check file existence once
  if (any(!file.exists(dfsample$`Begin Path`))) {
    warning("At least one source file does not exist!")
    return(invisible(NULL))
  }
  message("All source files exist - continuing process.")

  # Vectorized sox command creation
  dfsample <- dfsample %>%
    dplyr::mutate(
      sox_cmd = paste0("'|sox ", `Begin Path`, " -p trim ",
                       clip_start, " ", clip_duration,
                       " pad 0", dur_silence, "'")
    )

  # Create single sox call for all rows
  sox_call <- paste(
    "sox --combine sequence",
    paste(dfsample$sox_cmd, collapse = " "),
    file.path(output_dir, "result.WAV")
  )

  # Adjust selection table timings for one combined file
  dfsel <- dfsample %>%
    dplyr::mutate(
      lagdur = dplyr::lag(clip_duration, default = 0) + dur_silence,
      `Begin Time (s)` = snippet_start + cumsum(lagdur),
      `End Time (s)` = `Begin Time (s)` + birdnet_clip_length,
      seltab = file.path(output_dir, "result.TXT")
    ) %>%
    dplyr::select(-lagdur)

  # Write single selection table
  rio::export(dplyr::select(dfsel, -sox_cmd, -seltab),
              file = file.path(output_dir, "result.TXT"))

  # Run sox command
  message("Processing: ", sox_call)
  system(sox_call)

  message("Process completed!")
}
