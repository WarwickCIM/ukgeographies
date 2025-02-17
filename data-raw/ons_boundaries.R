## This code prepares `ons_boundaries` dataset containing the urls to be queried to
## retrieve the data.

# TODO: delete data-urls.R file.

library(dplyr)
library(jsonlite)
library(stringr)


# Query Geoportal API ----------------------------------------------------

geoportal_base_url <- "https://services1.arcgis.com"

geoportal_api_url <- paste0(
  geoportal_base_url, 
  "/ESMARspQHYMw9BZ9/arcgis/rest/services/"
)

geoportal_services <- fromJSON(
  paste0(
    geoportal_api_url,
    "?f=pjson"
  )) |> 
  as.data.frame()

# featureservers <- geoportal_services |> 
#   # We are just interested in FeatureServers. Remove Mapserver
#   filter(services.type == "FeatureServer")

# # Initiate blank dataframe to append info to.
# featureservers_details <- data.frame()

# for(url in featureservers$services.url) {
#   featureservers_details_json <- fromJSON(paste0(url, "?f=pjson")) 
  
#   name <- featureservers_details_json$layers$name
#   size <- featureservers_details_json$size
#   description <- featureservers_details_json$description

#   featureservers <- featureservers |> 
#     union(tmp_featureservers_details)

# }



# Build the dataframe ----------------------------------------------------

ons_features <- geoportal_services |> 
  # We are just interested in FeatureServers. Remove Mapserver
  rename(service = services.name) |>
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


# TODO: this still yields non-unique IDs.
ons_boundaries <- ons_features |>
  filter(services.type == "FeatureServer") |> 
  filter(type == "Boundary") |>
  select(-type) |>
  # Create URL to query featureserver and return a geojson file.
  mutate(url_download = paste0(services.url, "/0/query?where=1%3D1&outFields=*&outSR=4326&f=json")) |>
  # Create unique id
  mutate(id = paste(boundary_short, year, detail_level, sep = "_")) |>
  relocate(id)

usethis::use_data(ons_boundaries, overwrite = TRUE)



