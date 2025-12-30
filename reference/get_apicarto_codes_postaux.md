# Apicarto Codes Postaux

Implementation of the "Codes Postaux" module from the [IGN's
apicarto](https://apicarto.ign.fr/api/doc/codes-postaux). This API give
information about commune from postal code.

## Usage

``` r
get_apicarto_codes_postaux(code_post)
```

## Arguments

- code_post:

  `character` corresponding to the postal code of a commune

## Value

Object of class `data.frame`

## Examples

``` r
if (FALSE) { # \dontrun{

info_commune <- get_apicarto_codes_postaux("29760")

code_post <- c("29760", "08170")
info_communes <- get_apicarto_codes_postaux(code_post)

code_post <- c("12345")
info_communes <- get_apicarto_codes_postaux(code_post)

code_post <- c("12345", "08170")
info_communes <- get_apicarto_codes_postaux(code_post)
} # }
```
