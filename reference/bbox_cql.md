# Build a BBOX ECQL filter

Constructs a spatial ECQL `BBOX` expression from a reference geometry.

## Usage

``` r
bbox_cql(x, geom_name, crs)
```

## Arguments

- x:

  An `sf` object providing the reference geometry.

- geom_name:

  Character string giving the geometry attribute name of the WFS layer.

- crs:

  A CRS definition (as accepted by
  [`sf::st_crs()`](https://r-spatial.github.io/sf/reference/st_crs.html))
  corresponding to the WFS layer.

## Value

A character string containing a `BBOX` ECQL filter.

## Details

The bounding box is computed from the geometry provided in `x`, after
transforming it to the CRS of the target WFS layer. If the layer CRS has
a valid EPSG code, it is included in the ECQL expression.

This function is an internal helper used by
[`spatial_cql()`](https://paul-carteron.github.io/happign/reference/spatial_cql.md)
and should not be called directly by users.

## See also

[`spatial_cql()`](https://paul-carteron.github.io/happign/reference/spatial_cql.md)
