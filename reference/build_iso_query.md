# build_iso_query

build query for isochrone-dist API

## Usage

``` r
build_iso_query(
  point,
  source,
  value,
  type,
  profile,
  direction,
  constraints,
  distance_unit,
  time_unit
)
```

## Arguments

- point:

  `character`; point formated with `x_to_iso`.

- source:

  `character`; This parameter specifies which source will be used for
  the calculation. Currently, "valhalla" and "pgr" sources are available
  (default "pgr"). See section `SOURCE` for further information.

- value:

  `numeric`; A quantity of time or distance.

- type:

  `character`; Specifies the type of calculation performed: "time" for
  isochrone or "distance" for isodistance (isochrone by default).

- profile:

  `character`; Type of cost used for calculation: "pedestrian" for \#'
  pedestrians and "car" for cars. and "car" for cars ("pedestrian" by
  default).

- direction:

  `character`; Direction of travel. Either define a "departure" point
  and obtain the potential arrival points. Or define an "arrival" point
  and obtain the potential points ("departure" by default).

- constraints:

  Used to express constraints on the characteristics to calculate
  isochrones/isodistances. See section `CONSTRAINTS`.

- distance_unit:

  `character`; Allows you to specify the unit in which distances are
  expressed in the answer: "meter" or "kilometer" (meter by default).

- time_unit:

  `character`; Allows you to specify the unit in which times are
  expressed in the answer: "hour", "minute" or "second" (minutes by
  default).

## Value

`httr2_request` object
