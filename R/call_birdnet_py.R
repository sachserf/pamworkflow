#' Return a Python call to analyse Audio files with BirdNET
#'
#' @param input Character. File path to audio files
#' @param output Character. File path to target directory.
#' @param overlap Numeric. See description of BirdNET software for valid values.
#' @param threads Integer. See description of BirdNET software for valid values.
#' @param batch_size Integer. See description of BirdNET software for valid values.
#' @param sensitivity Numeric. See description of BirdNET software for valid values.
#' @param slist Character. Specify path to species list.
#' @param locale Character. See description of BirdNET software for valid values.
#' @param lat Numeric. See description of BirdNET software for valid values.
#' @param lon Numeric. See description of BirdNET software for valid values.
#' @param week Integer. See description of BirdNET software for valid values.
#' @param min_conf Numeric. See description of BirdNET software for valid values.
#' @param rtype Character. See description of BirdNET software for valid values.
#' @param fmin Integer. See description of BirdNET software for valid values.
#' @param fmax Integer. See description of BirdNET software for valid values.
#' @param audio_speed Numeric. See description of BirdNET software for valid values.
#' @param combine_results Character. See description of BirdNET software for valid values.
#'
#' @export
call_birdnet.py <- function(input, output, overlap = 2, threads = NULL, batch_size = NULL, sensitivity = 1, slist, locale = "en", lat = -1, lon = -1, week = -1, min_conf = 0.1, rtype = "table", fmin = 0, fmax = 15000, audio_speed = 1.0, combine_results = NULL) {

  if(is.null(threads)) {
  if(.Platform$OS.type == "unix") {
    nthreads <- as.integer(system("nproc", intern = TRUE))
  } else {
    nthreads <- as.integer(Sys.getenv("NUMBER_OF_PROCESSORS"))
  }
  threads <- nthreads-1
  }

  if(is.null(batch_size)) batch_size = threads * 3

  birdnet <- paste0("python -m birdnet_analyzer.analyze ", input, " --output ", output, " --overlap ", overlap, " --threads ", threads, " --batch_size ", batch_size, " --sensitivity ", sensitivity, " --slist ", slist, " --locale ", locale, " --lat ", lat, " --lon ", lon, " --week ", week, " --min_conf ", min_conf, " --rtype ", rtype, " --fmin ", fmin, " --fmax ", fmax, " --audio_speed ", audio_speed, " --combine_results ", combine_results)

  return(birdnet)
}


