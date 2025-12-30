# Download WMTS raster tiles

Download an RGB raster layer from IGN Web Map Tile Services (WMTS). WMTS
focuses on performance and can only query pre-calculated tiles.

## Usage

``` r
get_wmts(x,
         layer = "ORTHOIMAGERY.ORTHOPHOTOS",
         zoom = 10L,
         crs = 2154,
         filename = tempfile(fileext = ".tif"),
         verbose = FALSE,
         overwrite = FALSE,
         interactive = FALSE)
```

## Arguments

- x:

  Object of class `sf` or `sfc`. Needs to be located in France.

- layer:

  `character`; layer name from `get_layers_metadata(apikey, "wms")` or
  directly from [IGN
  website](https://geoservices.ign.fr/services-web-experts).

- zoom:

  `integer` between 0 and 21; at low zoom levels, a small set of map
  tiles covers a large geographical area. In other words, the smaller
  the zoom level, the less precise the resolution. For conversion
  between zoom level and resolution see [WMTS IGN
  Documentation](https://geoservices.ign.fr/documentation/services/services-geoplateforme/diffusion#70062)

- crs:

  `numeric`, `character`, or object of class `sf` or `sfc`. It is set to
  EPSG:2154 by default. See
  [`sf::st_crs()`](https://r-spatial.github.io/sf/reference/st_crs.html)
  for more detail.

- filename:

  `character` or `NULL`; filename or a open connection for writing. (ex
  : "test.tif" or "~/test.tif"). If `NULL`, `layer` is used as filename.
  Default drivers is ".tif" but all gdal drivers are supported, see
  details for more info.

- verbose:

  `boolean`; if TRUE, message are added.

- overwrite:

  If TRUE, output raster is overwrite.

- interactive:

  `logical`; If TRUE, interactive menu ask for `apikey` and `layer`.

## Value

`SpatRaster` object from `terra` package.

## See also

[`get_apikeys()`](https://paul-carteron.github.io/happign/reference/get_apikeys.md),
[`get_layers_metadata()`](https://paul-carteron.github.io/happign/reference/get_layers_metadata.md)

## Examples

``` r
if (FALSE) { # \dontrun{
library(sf)
library(tmap)

penmarch <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))

# Get orthophoto
layers <- get_layers_metadata("wmts", "ortho")$Identifier
ortho <- get_wmts(penmarch, layer = layers[1], zoom = 21)
plotRGB(ortho)

# Get all available irc images
layers <- get_layers_metadata("wmts", "orthohisto")$Identifier
irc_names <- grep("irc", layers, value = TRUE, ignore.case = TRUE)

irc <- lapply(irc_names, function(x) get_wmts(penmarch, layer = x, zoom = 18)) |>
   setNames(irc_names)

# remove empty layer (e.g. only NA)
irc <- Filter(function(x) !all(is.na(values(x))), irc)

# plot
all_plots <- lapply(irc, plotRGB)

} # }
```
