# Download WMS raster layer

Download a raster layer from the IGN Web Mapping Services (WMS). Specify
a location using a shape and provide the layer name.

## Usage

``` r
get_wms_raster(x,
               layer = "ORTHOIMAGERY.ORTHOPHOTOS",
               res = 10,
               crs = 2154,
               rgb = TRUE,
               filename = NULL,
               overwrite = FALSE,
               verbose = TRUE,
               interactive = FALSE)
```

## Arguments

- x:

  Object of class `sf` or `sfc`, located in France.

- layer:

  `character`; layer name obtained from `get_layers_metadata("wms-r")`
  or the [IGN website](https://geoservices.ign.fr/services-web-experts).

- res:

  `numeric`; resolution specified in the units of the coordinate system
  (e.g., meters for EPSG:2154, degrees for EPSG:4326). See details for
  more information.

- crs:

  `numeric`, `character`, or object of class `sf` or `sfc`; defaults to
  EPSG:2154. See
  [`sf::st_crs()`](https://r-spatial.github.io/sf/reference/st_crs.html)
  for more details.

- rgb:

  `boolean`; if set to `TRUE`, downloads an RGB image. If set to
  `FALSE`, downloads a single band with floating point values. See
  details for more information.

- filename:

  `character` or `NULL`; specifies the filename or an open connection
  for writing (e.g., "test.tif" or "~/test.tif"). The default format is
  ".tif" but all [GDAL
  drivers](https://gdal.org/en/latest/drivers/raster/index.html) are
  supported. When a filename is provided, the function uses it as a
  cache: if the file already exists and `overwrite` is set to `FALSE`,
  the function will directly load the raster from that file instead of
  re-downloading it.

- overwrite:

  `boolean`; if TRUE, the existing raster will be overwritten.

- verbose:

  `boolean`; if TRUE, message are added.

- interactive:

  `logical`; if TRUE, an interactive menu prompts for `apikey` and
  `layer` argument.

## Value

`SpatRaster` object from `terra` package.

## Details

- `res`: Note that setting `res` higher than the default resolution of
  the layer will increase the number of pixels but not the precision of
  the image. For instance, downloading the BD Alti layer from IGN is
  optimal at a resolution of 25m.

- `rgb`: Rasters are commonly used to download images such as
  orthophotos. In specific cases like DEMs, however, a value per pixel
  is essential. See examples below.

## See also

[`get_layers_metadata()`](https://paul-carteron.github.io/happign/reference/get_layers_metadata.md)

## Examples

``` r
if (FALSE) { # \dontrun{
library(sf)
library(tmap)

# Shape from the best town in France
penmarch <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))

# For quick testing use interactive = TRUE
raster <- get_wms_raster(x = penmarch, res = 25, interactive = TRUE)

# For specific data, choose apikey with get_apikey() and layer with get_layers_metadata()
apikey <- get_apikeys()[4]  # altimetrie
metadata_table <- get_layers_metadata("wms-r", apikey) # all layers for altimetrie wms
layer <- metadata_table[2,1] # ELEVATION.ELEVATIONGRIDCOVERAGE

# Downloading digital elevation model values not image
mnt_2154 <- get_wms_raster(penmarch, layer, res = 1, crs = 2154, rgb = FALSE)

# If crs is set to 4326, res is in degrees
mnt_4326 <- get_wms_raster(penmarch, layer, res = 0.0001, crs = 4326, rgb = FALSE)

# Plotting result
tm_shape(mnt_4326)+
   tm_raster()+
tm_shape(penmarch)+
   tm_borders(col = "blue", lwd  = 3)
} # }
```
