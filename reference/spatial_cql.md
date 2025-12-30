# Build a spatial ECQL filter

Converts a spatial predicate and a reference geometry into an ECQL
expression suitable for use in a WFS `GetFeature` request.

## Usage

``` r
spatial_cql(x, layer, predicate)
```

## Arguments

- x:

  An `sf` or `sfc`

- layer:

  `character` giving the WFS layer name.

- predicate:

  A spatial predicate object created by predicate helpers.

## Value

A character string containing a spatial ECQL filter.

## Details

This function is an internal helper used by
[`get_wfs()`](https://paul-carteron.github.io/happign/reference/get_wfs.md)
to translate spatial predicate objects (see
[spatial_predicates](https://paul-carteron.github.io/happign/reference/spatial_predicates.md))
into ECQL syntax understood by the WFS server.

Users should not call this function directly.
