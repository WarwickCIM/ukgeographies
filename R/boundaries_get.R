#' Retrieve Geographical Boundaries
#'
#' Queries [ONS' Geoportal](https://geoportal.statistics.gov.uk/) endpoints and
#' retrieves the requested geographical boundaries in the form of a sf object.
#'
#' @param boundary a string containing the acronym of name of the boundary to be
#' downloaded. Accepted values are: `r levels(ons_boundaries$boundary_short)`
#' @param year a number containing the year when the boundary was created.
#' @param detail_level a string defining the level of detail in the geometry.
#' (this affects the download size).
#'  Accepted values are: `r levels(ons_boundaries$detail_level)`. Each value
#'  corresponds to:
#'
#'   - _Full Extent (BFE)_ – Full resolution boundaries go to the Extent of the Realm (Low Water Mark) and are the most detailed of the boundaries.
#'   - _Full Clipped (BFC)_ – Full resolution boundaries that are clipped to the coastline (Mean High Water mark).
#'   - _Generalised Clipped (BGC)_ - Generalised to 20m and clipped to the coastline (Mean High Water mark) and more generalised than the BFE boundaries.
#'   - _Super Generalised Clipped (BSC) (200m)_ – Generalised to 200m and clipped to the coastline (Mean High Water mark).
#'   - _Ultra Generalised Clipped (BUC) (500m)_ – Generalised to 500m and clipped to the coastline (Mean High Water mark).
#'   - _Grid, Extent (BGE)_ - Grid formed of equally sized cells which extend beyond the coastline.
#'   - _Generalised, Grid (BGG)_ - Generalised 50m grid squares.
#'
#'  For a detailed description of how these boundaries were created refer to
#'  [Digital boundaries](https://www.ons.gov.uk/methodology/geography/geographicalproducts/digitalboundaries)
#'
#'
#'
#' @return a `sf` object with the selected boundaries.
#'
#' @export
#'
#' @examples
#' CA_2023_BGC <- boundaries_get("CAUTH", 2023, "BGC")
#'
#' class(CA_2023_BGC)
#'
boundaries_get <- function(boundary, year = NULL, detail_level = "BUC") {
  # Check parameters --------------------------------------------------------

  if (!rlang::is_character(boundary, n = 1)) {
    cli::cli_abort(
      c(
        "{.var boundary} must be a single string.",
        "x" = "You've supplied a {.cls {class(boundary)}} of length
        {.cls {length(boundary)}}."
      ),
      class = "error_not_single_string"
    )
  }
  if (!boundary %in% levels(ons_boundaries$boundary_short)) {
    cli::cli_abort(
      paste(
        "`boundary` must be one of these values:",
        levels(ons_boundaries$boundary_short)
      ),
      class = "error_boundary_not_valid"
    )
  }
  if (!rlang::is_double(year, n = 1)) {
    cli::cli_abort("`year` must be a single number",
      class = "error_not_single_number"
    )
  }
  if (!year %in% 1991:2024) {
    cli::cli_abort("{.var year} must be a single number between 1991 and 2025",
      class = "error_year_not_valid"
    )
  }
  # TODO if there's no combination of boundary and year, assign the closer
  # number (floor) and print a message stating the assumption.

  # Download --------------------------------------------------------

  lookup <- paste(boundary, year, detail_level, sep = "_")

  url <- ons_boundaries$url_download[ons_boundaries$id == lookup]

  if (length(url) == 0) {
    cli::cli_abort(
      c(
        "ONS doesn't have any boundaries matching the input combination",
        "i" = "You may want to use {.fn boundaries_select} to help you find a
        valid boundary"
      ),
      class = "error_boundary_invalid_combination"
    )
  }

  cli::cli_progress_step("Querying ONS API")
  cli::cli_progress_step("Downloading the selected dataset from ONS services",
                         spinner = TRUE
  )

  spdf <- sf::read_sf(url)



  return(spdf)
}
