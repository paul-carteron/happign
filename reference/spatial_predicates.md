# Spatial predicate constructors

These functions create spatial predicates used by
[`get_wfs()`](https://paul-carteron.github.io/happign/reference/get_wfs.md)
to filter features based on their spatial relationship with a reference
geometry.

## Usage

``` r
intersects()

within()

disjoint()

contains()

touches()

crosses()

overlaps()

equals()

bbox()

dwithin(distance, units = "meters")

beyond(distance, units = "meters")

relate(pattern)
```

## Arguments

- distance:

  Numeric distance value (single value).

- units:

  Distance units supported by the WFS server (e.g. `"meters"`,
  `"kilometers"`).

- pattern:

  A 9-character DE-9IM pattern string.

## Value

A spatial predicate object (used internally by
[`get_wfs()`](https://paul-carteron.github.io/happign/reference/get_wfs.md)).

## Details

Predicates describe *how* geometries should be compared (e.g.
intersection, containment, distance-based relations). Users should not
construct predicates manually; instead, use the helper functions listed
below.

- `bbox()`: Select features intersecting the bounding box of the
  reference geometry.

- `intersects()`: Select features whose geometry intersects the
  reference geometry.

- `disjoint()`: Select features whose geometry intersects the reference
  geometry.

- `contains()`: Select features that completely contain the reference
  geometry.

- `within()`: Select features completely within the reference geometry.

- `touches()`: Select features that touch the reference geometry at the
  boundary.

- `crosses()`: Select features that cross the reference geometry.

- `overlaps()`: Select features that partially overlap the reference
  geometry.

- `equals()`: Select features geometrically equal to the reference
  geometry.

- `dwithin(distance, units)`: Select features within a given distance of
  the reference geometry.

- `beyond(distance, units)`: Select features farther than a given
  distance from the reference geometry.

- `relate(pattern)`: Select features matching a DE-9IM spatial
  relationship pattern.

## See also

[`get_wfs()`](https://paul-carteron.github.io/happign/reference/get_wfs.md)

## Examples

``` r
intersects()
#> $type
#> [1] "intersects"
#> 
bbox()
#> $type
#> [1] "bbox"
#> 
dwithin(50, "meters")
#> $type
#> [1] "dwithin"
#> 
#> $distance
#> [1] 50
#> 
#> $units
#> [1] "meters"
#> 
beyond(100, "meters")
#> $type
#> [1] "beyond"
#> 
#> $distance
#> [1] 100
#> 
#> $units
#> [1] "meters"
#> 
relate("T*F**F***")
#> $type
#> [1] "relate"
#> 
#> $pattern
#> [1] "T*F**F***"
#> 
```
