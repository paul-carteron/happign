# Metadata for one couple of apikey and data_type

Metadata are retrieved using the IGN APIs. The execution time can be
long depending on the size of the metadata associated with the API key
and the overload of the IGN servers.

## Usage

``` r
get_layers_metadata(data_type, apikey = NULL)
```

## Arguments

- data_type:

  Should be `"wfs"`, `"wms-r"` or `"wmts"`. See details for more
  information about these Web services formats.

- apikey:

  API key from
  [`get_apikeys()`](https://paul-carteron.github.io/happign/reference/get_apikeys.md)
  or directly from the [IGN
  website](https://geoservices.ign.fr/services-web-experts)

## Value

data.frame

## Details

- `"wfs"` : Web Feature Service designed to return data in vector format
  (line, point, polygon, ...) ;

- `"wms-r"` : Web Map Service focuses on raster data ;

- `"wmts"` : Web Map Tile Service is similar to WMS, but instead of
  serving maps as single images, WMTS serves maps by dividing the map
  into a pyramid of tiles at multiple scales.

## See also

[`get_apikeys()`](https://paul-carteron.github.io/happign/reference/get_apikeys.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Get all metadata for a datatype
metadata_table <- get_layers_metadata("wms-r")

# Get all "administratif" wms layers
apikey <- get_apikeys()[1] #administratif
admin_layers <- get_layers_metadata("wms-r", apikey)

} # }
```
