#' ONS Boundaries Metadata
#'
#' Metadata about a subset of the geographical boundaries from [ONS'
#' geoportal](https://geoportal.statistics.gov.uk/) that can be downloaded by
#' `{ukgeographies}`.
#' These boundaries have been retrieved from the services provided by
#' [ONS' geoportal API](https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/) and
#' automatically categorised from their URLS, to
#' match Geoportal's menus and datasets.
#'
#' @format
#' A data frame with `r nrow(ons_boundaries)` rows and `r ncol(ons_boundaries)`
#' columns:
#' \describe{
#'   \item{id}{A unique identifier for every boundary}
#'   \item{service}{URL pointing to the API service}
#'   \item{boundary_type}{Type of boundary, according to ONS' classification: `r levels(ons_boundaries$boundary_type)`}
#'   \item{boundary}{Boundary name, according to ONS' naming: `r levels(ons_boundaries$boundary)`}
#'   \item{boundary_short}{Boundary (short) name, according to ONS' naming: `r levels(ons_boundaries$boundary_short)`}
#'   \item{detail_level}{Boundary's level of detail: `r levels(ons_boundaries$detail_level)`. For a detailed description of the methodology refer to [Digital boundaries](https://www.ons.gov.uk/methodology/geography/geographicalproducts/digitalboundaries) }
#'   \item{year}{Year in which the boundaries were created}
#'   \item{url_download}{URL querying the API service to return all features as a geojson file}
#'
#' }
#'
#' @source <https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/>
"ons_boundaries"
