# Retrieve additional information for wms layer

For some wms layer more information can be found with GetFeatureInfo
request. This function first check if info are available. If not,
available layers are returned.

## Usage

``` r
get_location_info(x,
                  apikey = "ortho",
                  layer = "ORTHOIMAGERY.ORTHOPHOTOS",
                  read_sf = TRUE,
                  version = "1.3.0")
```

## Arguments

- x:

  Object of class `sf` or `sfc`. Only single point are supported for
  now. Needs to be located in France.

- apikey:

  `character`; API key from get_apikeys() or directly from the IGN
  website

- layer:

  `character`; layer name obtained from `get_layers_metadata("wms-r")`
  or the [IGN website](https://geoservices.ign.fr/services-web-experts).

- read_sf:

  `logical`; if `TRUE` an `sf` object is returned but response times may
  be higher.

- version:

  `character`; old param

## Value

`character` or `sf` containing additional information about the layer

## Examples

``` r
if (FALSE) { # \dontrun{
library(sf)
library(tmap)

# From single point
x <- st_centroid(read_sf(system.file("extdata/penmarch.shp", package = "happign")))
location_info <- get_location_info(x, "ortho", "ORTHOIMAGERY.ORTHOPHOTOS", read_sf = F)
location_info$date_vol

# From multiple point
x1 <- st_sfc(st_point(c(-3.549957, 47.83396)), crs = 4326) # Carnoet forest
x2 <- st_sfc(st_point(c(-3.745995, 47.99296)), crs = 4326) # Coatloch forest

forests <- lapply(list(x1, x2),
                  get_location_info,
                  apikey = "environnement",
                  layer = "FORETS.PUBLIQUES",
                  read_sf = T)

qtm(forests[[1]]) + qtm(forests[[2]])

# Find all queryable layers
queryable_layers <- lapply(get_apikeys(), are_queryable) |> unlist()
} # }
```
