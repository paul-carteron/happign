# get_wfs_attributes

Helper to write ecql filter. Retrieve all attributes from a layer.

## Usage

``` r
get_wfs_attributes(layer = NULL)
```

## Arguments

- layer:

  `character`; name of the WFS layer. Must correspond to a layer
  available on the IGN WFS service (see
  [`get_layers_metadata()`](https://paul-carteron.github.io/happign/reference/get_layers_metadata.md)).

## Value

`character`vector with layer attributes

## Examples

``` r
if (FALSE) { # \dontrun{

get_wfs_attributes("LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune")

} # }
```
