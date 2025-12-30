# Download data from IGN WFS layer

Download features from the IGN Web Feature Service (WFS) using a spatial
predicate, an ECQL attribute query, or both.

## Usage

``` r
get_wfs(
  x = NULL,
  layer = NULL,
  predicate = bbox(),
  query = NULL,
  verbose = TRUE
)
```

## Arguments

- x:

  `sf`, `sfc` or `NULL`. If `NULL`, no spatial filter is applied and
  `query` must be provided.

- layer:

  `character`; name of the WFS layer. Must correspond to a layer
  available on the IGN WFS service (see
  [`get_layers_metadata()`](https://paul-carteron.github.io/happign/reference/get_layers_metadata.md)).

- predicate:

  `list`; a spatial predicate definition created with helper such as
  [`bbox()`](https://paul-carteron.github.io/happign/reference/spatial_predicates.md),
  [`intersects()`](https://paul-carteron.github.io/happign/reference/spatial_predicates.md),
  [`within()`](https://paul-carteron.github.io/happign/reference/spatial_predicates.md),
  [`contains()`](https://paul-carteron.github.io/happign/reference/spatial_predicates.md),
  [`touches()`](https://paul-carteron.github.io/happign/reference/spatial_predicates.md),
  [`crosses()`](https://paul-carteron.github.io/happign/reference/spatial_predicates.md),
  [`overlaps()`](https://paul-carteron.github.io/happign/reference/spatial_predicates.md),
  [`equals()`](https://paul-carteron.github.io/happign/reference/spatial_predicates.md),
  [`dwithin()`](https://paul-carteron.github.io/happign/reference/spatial_predicates.md),
  [`beyond()`](https://paul-carteron.github.io/happign/reference/spatial_predicates.md)
  or
  [`relate()`](https://paul-carteron.github.io/happign/reference/spatial_predicates.md).
  See
  [spatial_predicates](https://paul-carteron.github.io/happign/reference/spatial_predicates.md)
  for more info.

- query:

  `character`; an ECQL attribute query. When both `x` and `query` are
  provided, the spatial predicate and the attribute query are combined.

- verbose:

  `logical`; if `TRUE`, display progress information and other
  informative message.

## Value

An object of class `sf`.

## Details

- `get_wfs` use ECQL language : a query language created by the
  OpenGeospatial Consortium. More info about ECQL language can be found
  [here](https://docs.geoserver.org/latest/en/user/filter/ecql_reference.html).

## See also

[`get_layers_metadata()`](https://paul-carteron.github.io/happign/reference/get_layers_metadata.md)

## Examples

``` r
if (FALSE) { # \dontrun{
library(sf)

# Load a geometry
x <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))

# Retrieve commune boundaries intersecting x
commune <- get_wfs(
  x = x,
  layer = "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune"
)

plot(st_geometry(commune), border = "firebrick")

# Attribute-only query (no spatial filter)

# If unknown, available attributes can be retrieved using `get_wfs_attributes()`
attrs <- get_wfs_attributes("LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune")
print(attrs)

plou_communes <- get_wfs(
  x = NULL,
  layer = "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune",
  query = "nom_officiel ILIKE 'PLOU%'"
)
plot(st_geometry(plou_communes))

# Multiple Attribute-only query (no spatial filter)
plou_inf_2000 <- get_wfs(
  x = NULL,
  layer = "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune",
  query = "nom_officiel ILIKE 'PLOU%' AND population < 2000"
)
plot(st_geometry(plou_communes))
plot(st_geometry(plou_inf_2000), col = "firebrick", add = TRUE)

# Spatial predicate usage

layer <- "BDCARTO_V5:rond_point"

bbox_feat <- get_wfs(commune, layer, predicate = bbox())
plot(st_geometry(bbox_feat), col = "red")
plot(st_geometry(commune), add = TRUE)

intersects_feat <- get_wfs(commune, layer, predicate = intersects())
plot(st_geometry(intersects_feat), col = "red")
plot(st_geometry(commune), add = TRUE)

dwithin_feat <- get_wfs(commune, layer, predicate = dwithin(5, "kilometers"))
plot(st_geometry(dwithin_feat), col = "red")
plot(st_geometry(commune), add = TRUE)
} # }
```
