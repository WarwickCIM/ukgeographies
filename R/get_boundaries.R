#' Retrieve Geographical Boundary
#'
#' Queries [ONS' Geoportal](https://geoportal.statistics.gov.uk/) endpoints and
#' retrieves the requested geographical boundaries in the form of a sf object.
#'
#' @param boundary a string containing...
#' @param year a number containing...
#' @param resolution a string containing...
#'
#'
#' @return a sf object
#' @export
#'
get_boundaries <- function(boundary, year, resolution="BUC"){
  # Check that boundary is not empty and is a string
  # Check that year is not empty and is a number

  lookup <- paste(boundary, year, resolution, sep = "_")


  url <- data_urls$url_download[data_urls$id == lookup]

  spdf <- sf::read_sf(url)
  return(spdf)
}

# test <- get_boundaries()
