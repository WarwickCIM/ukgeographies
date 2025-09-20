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
  rename(service = services.name) |>
  # Add metadata link
  mutate(services.url.metadata = paste0(services.url, "/info/metadata")) |> 
  # Infer year from title
  mutate(
    year = str_extract(service, "_(19|20)(\\d){2}"),
    year = as.numeric(str_remove(year, "_")),
  ) |>
  # Manually add year for items with wrong URL, based on metadata description
  mutate(
    year = case_when(
      str_detect(service, "_May_2023") ~ 2024,
      .default = year
    )
  ) |> 
  # Infer categories from titles
  mutate(
    boundary = case_when(
      str_detect(services.url, "Combined_Authorities") ~ "Combined Authorities",
      str_detect(services.url, "Counties_and_Unitary_Authorities") ~ "Counties and Unitary Authorities",
      str_detect(services.url, "Counties_") & !str_detect(service, "Metropolitan_") ~ "Counties",
      str_detect(services.url, "Countries_") ~ "Countries",
      str_detect(services.url, "County_Electoral_Division") ~ "County Electoral Division",
      str_detect(services.url, "Local_Authority_Districts") ~ "Local Authority Districts",
      str_detect(services.url, "Local_Planning_Authorities") ~ "Local Planning Authorities",
      str_detect(services.url, "Metropolitan_Counties") ~ "Metropolitan Counties",
      str_detect(services.url, "Parishes_and_Non_Civil_Parished_Areas") ~ "Parishes and Non Civil Parished Areas",
      str_detect(services.url, "Parishes") ~ "Parishes",
      str_detect(services.url, "Regions") & year %in% c(2024, 2023) & !str_detect(services.url, "NHS_") ~ "Regions",
      str_detect(services.url, "Upper_Tier") ~ "Upper Tier",
      str_detect(services.url, "Wards") ~ "Wards",
      str_detect(services.url, "Lower_Layer") ~ "Lower Layer Output Areas",
      str_detect(services.url, "Middle_Layer") ~ "Middle Layer Output Areas",
      str_detect(services.url, "Output_Areas") & !str_detect(services.url, "Middle|Lower") ~ "Output Areas",
      str_detect(services.url, "NHS_") ~ "NHS Regions"
    ),
    boundary = as.factor(boundary)
  ) |>
  mutate(
    boundary_short = case_when(
      boundary == "Combined Authorities" ~ "CAUTH",
      boundary == "Counties and Unitary Authorities" ~ "CTYUA",
      boundary == "Counties" ~ "CTY",
      boundary == "Countries" ~ "CTRY",
      boundary == "County Electoral Division" ~ "CED",
      boundary == "Local Authority Districts" ~ "LAD",
      boundary == "Local Planning Authorities" ~ "LPA",
      boundary == "Metropolitan Counties" ~ "MCTY",
      boundary == "Parishes and Non Civil Parished Areas" ~ "PARNCP",
      boundary == "Parishes" ~ "PAR",
      boundary == "Regions" ~ "RGN",
      boundary == "Upper Tier" ~ "UTLA",
      boundary == "Wards" ~ "WD",
      boundary == "Lower Layer Output Areas" ~ "LSOA",
      boundary == "Middle Layer Output Areas" ~ "MSOA",
      boundary == "Output Areas" ~ "OA",
      boundary == "NHS Regions" ~ "NHS"
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
      boundary_short %in% c("LSOA", "MSOA", "OA") ~ "Census Boundaries",
      boundary_short == "NHS" ~ "Health Boundaries"
    ),
    boundary_type = as.factor(boundary_type)
  ) |>
  relocate(boundary_type, .before = boundary) |>
  mutate(
    detail_level = case_when(
      str_detect(services.url, "_BFC") ~ "BFC",
      str_detect(services.url, "_BFE") ~ "BFE",
      str_detect(services.url, "_BGC") ~ "BGC",
      str_detect(services.url, "_BUC") ~ "BUC",
      str_detect(services.url, "_FCB_") ~"BFC",
      str_detect(services.url, "_FEB_") ~"BFE",
      str_detect(services.url, "_GCB_") ~"BGC",
      str_detect(services.url, "_Full_extent") ~"BFE",
      str_detect(services.url, "_Generalised_Boundaries") & !str_detect(service, "_Ultra_") ~"BGC",
      str_detect(services.url, "_Ultra_Generalised_Boundaries") ~"BUC",
      str_detect(services.url, "_UGCB_") ~"BUC",
      str_detect(services.url, "_SGCB_") ~"BSC",
      
    ),
    detail_level = as.factor(detail_level)
  ) |>
  # Infer constituent countries
  mutate(
    scope = case_when(
      str_detect(services.url, "_EN_") ~ "England",
      str_detect(services.url, "_GB_") ~ "Great Britain",
      str_detect(services.url, "_UK_") ~ "UK"
    )
  ) |> 
  mutate(
    type = case_when(
      str_detect(services.url, "Lookup") ~ "Lookup",
      str_detect(services.url, "Loo") ~ "Lookup",
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
  mutate(url_download2 = paste0(services.url, "/0/query?where=1%3D1&outFields=*&returnGeometry=true&f=geojson&resultRecordCount=5000")) |>
  # Create unique id
  mutate(id = case_when(
    is.null(scope) ~ paste(boundary_short, year, detail_level, sep = "_"),
    # TODO: get_boundaries should trigger a warning if duplicate id, prompting to specify scope.
    !is.null(scope) ~ paste(boundary_short, year, detail_level, scope, sep = "_")
  )) |>
  relocate(id)

unique_ids <- ons_boundaries |> 
  count(id, sort = TRUE) |> 
  filter(n > 1)

usethis::use_data(ons_boundaries, overwrite = TRUE)



