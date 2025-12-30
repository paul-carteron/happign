# Apicarto Cadastre

Implementation of the cadastre module from the [IGN's
apicarto](https://apicarto.ign.fr/api/doc/cadastre)

## Usage

``` r
get_apicarto_cadastre(x,
                      type = "commune",
                      section = NULL,
                      numero = NULL,
                      code_abs = NULL,
                      source = "pci",
                      progress = TRUE)
```

## Arguments

- x:

  `sf`, `sfc`, `character` or `numeric` :

  - Shape : must be an object of class `sf` or `sfc`.

  - Code insee : must be a `character` of length 5 (see
    [com_2025](https://paul-carteron.github.io/happign/reference/com_2025.md))

  - Code departement : must be a `character` of length 2 or 3 (DOM-TOM)
    (see
    [dep_2025](https://paul-carteron.github.io/happign/reference/dep_2025.md))

- type:

  `character` : type of data needed, default to `"commune"`. One of
  `"commune"`, `"parcelle"`, `"section"`, `"localisant"`.

- section:

  `character` : corresponding to section of a city.

- numero:

  `character` : corresponding to numero of cadastral parcels.

- code_abs:

  `character` : corresponding to the code of absorbed commune. This
  prefix is useful to differentiate between communes that have merged

- source:

  `character` : `"bdp"` for BD Parcellaire or `"pci"` for Parcellaire
  express. Default to `"pci"`. See detail for more info.

- progress:

  Display a progress bar? Use TRUE to turn on a basic progress bar, use
  a string to give it a name. See
  [`httr2::req_perform_iterative()`](https://httr2.r-lib.org/reference/req_perform_iterative.html).

## Value

Object of class `sf`

## Details

**Vectorisation**:

Arguments `x`, `section`, `numero`, and `code_abs` are vectorized if
only one argument has `length > 1` (**Cartesian product**)

    x = 29158; section = c("A", "B")
    → (29158, "A"), (29158, "B")

    x = 29158, section = "A", numero = 1:3
    → (29158, "A", 1); (29158, "A", 2); (29158, "A", 3)

In case all vectorised arguments have the same length **Pairwise
matching** is used

    x = c(29158, 29158); section = c("A", "B"); numero = 1:2
    → (29158, "A", 1), (29158, "B", 2)

**Ambiguous vectorisation**:

If more than one argument has `length > 1` but lengths differ, it is
unclear whether to combine them pairwise or via cartesian product. This
is rejected with an error to avoid unintended queries.

    x = 29158, section = c("A", "B"), numero = 1:2
    Possible interpretations:
    1. Pairwise: (29158, "A", 1), (29158, "B", 2)
    2. Cartesian: (29158, "A", 1), (29158, "A", 2), (29158, "B", 1), (29158, "B", 2)

**Source**:

BD Parcellaire (`"bdp"`) is no longer updated and its use is
discouraged. PCI Express (`"pci"`) is strongly recommended and will
become mandatory. See IGN's [product comparison
table](https://geoservices.ign.fr/sites/default/files/2021-07/Comparatif_PEPCI_BDPARCELLAIRE.pdf).

## Examples

``` r
if (FALSE) { # \dontrun{
library(sf)
library(tmap)

# shape from the town of penmarch
penmarch <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))

# get commune borders
## from shape
penmarch_borders <- get_apicarto_cadastre(penmarch, type = "commune")
qtm(penmarch_borders)+qtm(penmarch, fill = "red")

## from insee_code
border <- get_apicarto_cadastre("29158", type = "commune")
borders <- get_apicarto_cadastre(c("29158", "29135"), type = "commune")
qtm(borders, fill="nom_com")

# get cadastral parcels
## from shape
parcels <- get_apicarto_cadastre(penmarch, type = "parcelle")
qtm(parcels, fill="section")

## from insee code
parcels <- get_apicarto_cadastre("29158", type = "parcelle")
qtm(parcels, fill="section")

# Use parameter recycling
## get sections "AW" parcels from multiple insee_code
parcels <- get_apicarto_cadastre(
   c("29158", "29135"),
   section = "AW",
   type = "parcelle"
   )
qtm(borders, fill = NA)+qtm(parcels)

## if multiple args with length > 1 result is ambigous
parcels <- get_apicarto_cadastre(
   x = c("29158", "29135"),
   section = c("AW", "AB"),
   numero = 1,
   type = "parcelle"
)

## get parcels numbered "0001", "0010" of section "AW" and "BR"
insee <- rep("29158", 2)
section <- c("AW", "BR")
numero <- c("0001", "0010")
parcels <- get_apicarto_cadastre(insee, section = section, numero = numero, type = "parcelle")
qtm(penmarch_borders, fill = NA)+qtm(parcels)

# Arrondissement insee code should be used for paris, lyon, marseille
error <- get_apicarto_cadastre(c(75056, 69123, 13055))
paris_arr123 <- get_apicarto_cadastre(c(75101, 75102, 75103))
qtm(paris_arr123, fill = "code_insee")

} # }
```
