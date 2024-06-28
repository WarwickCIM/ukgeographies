## This code prepares `data-urls` dataset containing the urls to be queried to
## retrieve the data.

library(dplyr)
library(rvest)
library(stringr)


# Scrape URLS -------------------------------------------------------------

geoportal_base_url <- "https://services1.arcgis.com"

ons_geoportal <- read_html(paste0(geoportal_base_url,
                                  "/ESMARspQHYMw9BZ9/arcgis/rest/services/"))

services <- ons_geoportal |>
  html_elements("li") |>
  html_elements("a") |>
  html_attr("href")


# Build the dataframe -----------------------------------------------------

data_urls <- as.data.frame(services) |>
  # Remove Mapserver
  filter(str_detect(services, "/FeatureServer")) |>
  # Convert absolute URLS
  mutate(services = paste0(geoportal_base_url, services)) |>
  mutate(type = case_when(
    str_detect(services, "Lookup") ~ "Lookup",
  )) |>
  # Infer categories from titles
  mutate(boundary = case_when(
    str_detect(services, "Combined_Authorities") ~ "CAUTH",
    str_detect(services, "/Counties_and_Unitary_Authorities") ~ "CTYUA",
    str_detect(services, "/Counties_") ~ "CTY",
    str_detect(services, "/Countries_") ~ "CTRY",
    str_detect(services, "/County_Electoral_Division")  ~ "CED",
    str_detect(services, "/Local_Authority_Districts") ~ "LAD",
    str_detect(services, "/Local_Planning_Authorities") ~ "LPA",
    str_detect(services, "/Metropolitan_Counties") ~ "MCTY",
    str_detect(services, "/Parishes_and_Non_Civil_Parished_Areas") ~ "PARNCP",
    str_detect(services, "/Parishes") ~ "PAR",
    str_detect(services, "/Regions") ~ "RGN",
    str_detect(services, "/Upper_Tier") ~ "UTLA",
    str_detect(services, "/Wards") ~ "WD",
    str_detect(services, "/Lower_Layer") ~ "LSOA",
    str_detect(services, "/Middle_Layer") ~ "MSOA",
    str_detect(services, "/Output_Areas") ~ "OA",
    ),
    boundary = as.factor(boundary)) |>
  mutate(boundary_type = case_when(
    boundary %in% c("CAUTH", "CTYUA", "CTY", "CTRY", "CED", "LAD",
                    "LPA", "MCTY", "PARNCP", "PAR", "RGN", "UTLA", "WD") ~
      "Administrative",
    boundary %in% c("LSOA", "MSOA", "OA") ~ "Census Boundaries"
    ),
    boundary_type = as.factor(boundary_type)) |>
  relocate(boundary_type, .before = boundary) |>
  mutate(resolution = case_when(
    str_detect(services, "_BFC") ~ "BFC",
    str_detect(services, "_BFE") ~ "BFE",
    str_detect(services, "_BGC") ~ "BGC",
    str_detect(services, "_BUC") ~ "BUC"
    ),
    detail_level = as.factor(resolution)) |>
  mutate(year = str_extract(services, "_(19|20)(\\d){2}"),
         year = as.numeric(str_remove(year, "_"))) |>
  # Create URL to query featureserver and return a geojson file.
  mutate(url_download = paste0(services, "/0/query?where=1%3D1&outFields=*&outSR=4326&f=json")) |>
#
# data_boundaries <- data_urls |>
#   filter(!is.na(boundary)) |>
  # Create unique id
  mutate(id = paste(boundary, year, detail_level, sep = "_")) |>
  relocate(id)

usethis::use_data(data_urls, overwrite = TRUE, internal = TRUE)
