## This code prepares `data-urls` dataset containing the urls to be queried to
## retrieve the data.

library(dplyr)

# Variables ---------------------------------------------------------------

geoportal_base_url <- "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/"


# Data frame --------------------------------------------------------------

data_urls_raw <- tibble::tribble(
  # Column Names ---
  # The category of the boundary, according to ONS. Administrative, Census...
  ~boundary_category,
  # The type of boundary. Can be Countries, Counties...
  ~boundary,
  ~year,
  # Resolution or clipping. Can be either: BFC, BFE, BGC, BUC.
  ~resolution,
  # string with url to download endpoint. If not present, will be generated
  # programatically.
  ~url_download,
  ~licence,
  # URL to the dataset's metadata.
  ~url_metadata,

  # Boundaries: Add one per line.
  # Countries
  "administrative", "countries", 2022, "BUC", "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Countries_December_2022_GB_BUC/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson", NA, NA,
  "administrative", "countries", 2019, "BUC", "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Countries_Dec_2019_UGCB_GB_2022/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson", NA, NA
)



data_urls <- data_urls_raw |>
  # Create unique id
  mutate(id = paste(boundary, year, resolution, sep = "_")) |>
  relocate(id) |>
  # Create url_download if empty
  mutate(url_download = case_when(
    is.na(url_download) ~ paste0(geoportal_base_url, "hello" ),
    .default = url_download)) |>
  # Convert to factors
  mutate(boundary_category = as.factor(boundary_category),
         boundary = as.factor(boundary),
         resolution = as.factor(resolution))



usethis::use_data(data_urls, overwrite = TRUE, internal = TRUE)
