#' Interactively Retrieve Geographical Boundaries
#'
#' A Command Line Interface that constructs a valid combination of geometry
#' type, year and detail level and downloads the selected boundary by calling
#' `boundaries_get()`.
#'
#' @return  a `sf` object with the selected combination of boundary, year and
#' detail level.
#'
#'
#' @export
#'
boundaries_select <- function() {
  # Boundary types ----------------------------------------------------------
  boundary_types <- levels(ons_boundaries$boundary_type)

  # Use the menu function to prompt the user to choose an option
  choice_boundary_type_n <- utils::menu(
    boundary_types,
    title = "Please choose the boundary type:"
  )

  choice_boundary_type <- boundary_types[choice_boundary_type_n]

  cat("You chose:", choice_boundary_type, "\n")


  # Boundary ----------------------------------------------------------------
  boundaries <- levels(droplevels(
    ons_boundaries[ons_boundaries$boundary_type == choice_boundary_type, "boundary"]
  ))

  choice_boundary_n <- utils::menu(boundaries,
    title = paste(choice_boundary_type, "has the following boundaries. Please choose the boundary name you'd like to download:")
  )

  choice_boundary <- boundaries[choice_boundary_n]

  cat("You chose:", choice_boundary, "\n")

  boundaries_lookup <- unique(ons_boundaries[c("boundary", "boundary_short")])

  choice_boundary_short <- as.character(
    boundaries_lookup$boundary_short[boundaries_lookup$boundary == choice_boundary])


  # Year --------------------------------------------------------------------

  years <- levels(as.factor(
    ons_boundaries[ons_boundaries$boundary == choice_boundary, "year"]
  ))

  choice_years_n <- utils::menu(
    years,
    title = paste(choice_boundary, "were updated in the following years. Please choose the year name you'd like to download:")
  )

  choice_year <- as.numeric(years[choice_years_n])

  print(choice_year)

  # Detail level -----------------------------------------------------------
  detail_levels <- levels(droplevels(
    ons_boundaries[ons_boundaries$boundary == choice_boundary & ons_boundaries$year == choice_year, "detail_level"]
  ))

  # Some combinations do not have any specified detail level
  if (nlevels(detail_levels) > 1) {

    choice_detail_levels_n <- utils::menu(
      detail_levels,
      title = "Choose the detail level you'd like to download"
    )

    choice_detail_levels <- detail_levels[choice_detail_levels_n]

  } else {

    cli::cli_alert_info("This combination only has a single detail level
                        available. Assigning it automatically")
    choice_detail_levels <- "NA"
  }



  # Download ---------------------------------------------------------------
  #return(paste(choice_boundary, choice_year, choice_detail_levels, sep = "_"))
  return(boundaries_get(choice_boundary_short, choice_year, choice_detail_levels))

  # Check if the user made a valid choice
  # if (choice_boundary_type> 0) {
  #   cat("You chose:", choice_boundary_type, "\n")
  #   return(choice_boundary_type)
  # } else {
  #   cat("No valid option was chosen.\n")
  #   return(NULL)
  # }
}
