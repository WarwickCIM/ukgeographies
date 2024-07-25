## This code prepares `data-urls` dataset containing the urls to be queried to
## retrieve the data.

library(dplyr)
library(rvest)
library(stringr)


# Scrape URLS -------------------------------------------------------------

geoportal_base_url <- "https://services1.arcgis.com"

ons_geoportal <- read_html(paste0(
  geoportal_base_url,
  "/ESMARspQHYMw9BZ9/arcgis/rest/services/"
))

services <- ons_geoportal |>
  html_elements("li") |>
  html_elements("a") |>
  html_attr("href")


# Build the dataframe -----------------------------------------------------

ons_data <- as.data.frame(services) |>
  rename(service = services) |>
  # Remove Mapserver
  filter(str_detect(service, "/FeatureServer")) |>
  # Convert absolute URLS
  mutate(service = paste0(geoportal_base_url, service)) |>
  # Infer categories from titles
  mutate(
    boundary = case_when(
      str_detect(service, "Combined_Authorities") ~ "Combined Authorities",
      str_detect(service, "/Counties_and_Unitary_Authorities") ~ "Counties and Unitary Authorities",
      str_detect(service, "/Counties_") ~ "Counties",
      str_detect(service, "/Countries_") ~ "Countries",
      str_detect(service, "/County_Electoral_Division") ~ "County Electoral Division",
      str_detect(service, "/Local_Authority_Districts") ~ "Local Authority Districts",
      str_detect(service, "/Local_Planning_Authorities") ~ "Local Planning Authorities",
      str_detect(service, "/Metropolitan_Counties") ~ "Metropolitan Counties",
      str_detect(service, "/Parishes_and_Non_Civil_Parished_Areas") ~ "Parishes and Non Civil Parished Areas",
      str_detect(service, "/Parishes") ~ "Parishes",
      str_detect(service, "/Regions") ~ "Regions",
      str_detect(service, "/Upper_Tier") ~ "Upper Tier",
      str_detect(service, "/Wards") ~ "Wards",
      str_detect(service, "/Lower_Layer") ~ "Lower Layer Output Areas",
      str_detect(service, "/Middle_Layer") ~ "Middle Layer Output Areas",
      str_detect(service, "/Output_Areas") ~ "Output Areas",
    ),
    boundary = as.factor(boundary)
  ) |>
  mutate(
    boundary_short = case_when(
      str_detect(service, "Combined_Authorities") ~ "CAUTH",
      str_detect(service, "/Counties_and_Unitary_Authorities") ~ "CTYUA",
      str_detect(service, "/Counties_") ~ "CTY",
      str_detect(service, "/Countries_") ~ "CTRY",
      str_detect(service, "/County_Electoral_Division") ~ "CED",
      str_detect(service, "/Local_Authority_Districts") ~ "LAD",
      str_detect(service, "/Local_Planning_Authorities") ~ "LPA",
      str_detect(service, "/Metropolitan_Counties") ~ "MCTY",
      str_detect(service, "/Parishes_and_Non_Civil_Parished_Areas") ~ "PARNCP",
      str_detect(service, "/Parishes") ~ "PAR",
      str_detect(service, "/Regions") ~ "RGN",
      str_detect(service, "/Upper_Tier") ~ "UTLA",
      str_detect(service, "/Wards") ~ "WD",
      str_detect(service, "/Lower_Layer") ~ "LSOA",
      str_detect(service, "/Middle_Layer") ~ "MSOA",
      str_detect(service, "/Output_Areas") ~ "OA",
    ),
    boundary_short = as.factor(boundary_short)
  ) |>
  mutate(
    boundary_type = case_when(
      boundary_short %in% c(
        "CAUTH", "CTYUA", "CTY", "CTRY", "CED", "LAD",
        "LPA", "MCTY", "PARNCP", "PAR", "RGN", "UTLA", "WD"
      ) ~
        "Administrative",
      boundary %in% c("LSOA", "MSOA", "OA") ~ "Census Boundaries"
    ),
    boundary_type = as.factor(boundary_type)
  ) |>
  relocate(boundary_type, .before = boundary) |>
  mutate(
    detail_level = case_when(
      str_detect(service, "_BFC") ~ "BFC",
      str_detect(service, "_BFE") ~ "BFE",
      str_detect(service, "_BGC") ~ "BGC",
      str_detect(service, "_BUC") ~ "BUC"
    ),
    detail_level = as.factor(detail_level)
  ) |>
  mutate(
    year = str_extract(service, "_(19|20)(\\d){2}"),
    year = as.numeric(str_remove(year, "_"))
  ) |>
  mutate(
    type = case_when(
      str_detect(service, "Lookup") ~ "Lookup",
      !is.na(boundary) ~ "Boundary",
    ),
    type = as.factor(type)
  )

ons_boundaries <- ons_data |>
  filter(type == "Boundary") |>
  select(-type) |>
  # Create URL to query featureserver and return a geojson file.
  mutate(url_download = paste0(service, "/0/query?where=1%3D1&outFields=*&outSR=4326&f=json")) |>
  # Create unique id
  mutate(id = paste(boundary_short, year, detail_level, sep = "_")) |>
  relocate(id)

usethis::use_data(ons_boundaries, overwrite = TRUE)
