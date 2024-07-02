
<!-- README.md is generated from README.Rmd. Please edit that file and run
`devtools::build_readme()` -->

# UKgeogRaphies

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![R-CMD-check](https://github.com/WarwickCIM/ukgeographies/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/WarwickCIM/ukgeographies/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

> \[!WARNING\]  
> This package is highly experimental and is still a WIP. Expect
> uncomplete features, frequent breaks, lack of documentation and
> changes in the API.

> ### Because UK Geographies are complex enough[^1], working with them
>
> should be easy enough.

The goal of `{UKgeogRaphies}` is to provide an interface to easily
retrieve geospatial data from ONS’ Geoportal and make it usable within
R.

So far it provides very limited functionality to download boundaries in
the UK and convert them to `sf` objects.

**Acknowledgement**: this packages is highly inspired (feature wise) by
[`{UKgeog}`](https://l-hodge.github.io/ukgeog/), which ceased to work
after ONS changed their API and has not been maintained since 2022.

## Installation

You can install the development version of ukgeographies from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("WarwickCIM/ukgeographies")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(ukgeographies)

# Get a sf object from 
countries_2023 <- boundaries_get("CTRY", 2023, "BUC")
#> Warning in CPL_read_ogr(dsn, layer, query, as.character(options), quiet, : GDAL
#> Message 1: organizePolygons() received a polygon with more than 100 parts. The
#> processing may be really slow.  You can skip the processing by setting
#> METHOD=SKIP, or only make it analyze counter-clock wise parts by setting
#> METHOD=ONLY_CCW if you can assume that the outline of holes is counter-clock
#> wise defined
```

``` r

class(countries_2023)
#> [1] "sf"         "tbl_df"     "tbl"        "data.frame"
```

``` r

countries_2023
#> Simple feature collection with 4 features and 11 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -8.649996 ymin: 49.88234 xmax: 1.763706 ymax: 60.86087
#> Geodetic CRS:  WGS 84
#> # A tibble: 4 × 12
#>     FID CTRY23CD  CTRY23NM       CTRY23NMW  BNG_E  BNG_N LONG  LAT   Shape__Area
#>   <int> <chr>     <chr>          <chr>      <int>  <int> <chr> <chr>       <dbl>
#> 1     1 E92000001 England        Lloegr    394883 370883 -2.0… 53.2…     1.31e11
#> 2     2 N92000002 Northern Irel… Gogledd …  86544 535337 -6.8… 54.6…     1.43e10
#> 3     3 S92000003 Scotland       Yr Alban  277744 700060 -3.9… 56.1…     7.86e10
#> 4     4 W92000004 Wales          Cymru     263405 242881 -3.9… 52.0…     2.08e10
#> # ℹ 3 more variables: Shape__Length <dbl>, GlobalID <chr>,
#> #   geometry <MULTIPOLYGON [°]>
```

``` r

plot(countries_2023["CTRY23NM"])
```

<img src="man/figures/README-example-1.png" width="100%" />

[^1]: To get started, ONS has edited a [A Beginner’s Guide to UK
    Geography](https://geoportal.statistics.gov.uk/datasets/c0db0e8c67d04935bcf1749ca6027fef/about)
    which *only* has 137 pages.
