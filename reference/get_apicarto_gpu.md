# Apicarto module Geoportail de l'urbanisme

Apicarto module Geoportail de l'urbanisme

## Usage

``` r
get_apicarto_gpu(x, layer, category = NULL)
```

## Arguments

- x:

  `sf`, `sfc` or `character` :

  - Shape : must be an object of class `sf` or `sfc`.

  - Code insee (layer = `"municipality"`) : must be a `character` of
    length 5 (see
    [com_2025](https://paul-carteron.github.io/happign/reference/com_2025.md))

  - Partition : must be a valid partition `character` for checking and
    [Geoportail](https://www.geoportail-urbanisme.gouv.fr/image/UtilisationAPI_GPU_1-0.pdf)
    for documentation

- layer:

  `character`; Layer name from
  [`get_gpu_layers()`](https://paul-carteron.github.io/happign/reference/get_gpu_layers.md)

- category:

  public utility easement according to the [national
  nomenclature](https://www.geoportail-urbanisme.gouv.fr/infos_sup/)

## Value

`sf`

## Details

**/!\\ API cannot returned more than 5000 features.**

All existing parameters for `layer` :

- `"municipality"` : information on the communes (commune with RNU,
  merged commune)

- `"document"` : information on urban planning documents (POS, PLU,
  PLUi, CC, PSMV, SCoT)

- `"zone-urba"` : zoning of urban planning documents,

- `"secteur-cc"` : communal map sectors

- `"prescription-surf"`, `"prescription-lin"`, `"prescription-pct"` :
  its's a constraint or a possibility indicated in an urban planning
  document (PLU, PLUi, ...)

- `"info-surf"`, `"info-lin"`, `"info-pct"` : its's an information
  indicated in an urban planning document (PLU, PLUi, ...)

- `"acte-sup"` : act establishing the SUP

- `"generateur-sup-s"`, `"generateur-sup-l"`, `"generateur-sup-p"` : an
  entity (site or monument, watercourse, water catchment, electricity or
  gas distribution of electricity or gas, etc.) which generates on the
  surrounding SUP (of passage, alignment, protection, land reservation,
  etc.)

- `"assiette-sup-s"`, `"assiette-sup-l"`, `"assiette-sup-p"` : spatial
  area to which SUP it applies.

## Examples

``` r
if (FALSE) { # \dontrun{
library(sf)
library(tmap)

# Find if commune is under the RNU (national urbanism regulation)
# If no RNU it means communes probably have a PLU
rnu <- get_apicarto_gpu("29158", "municipality")
rnu$is_rnu

# Get urbanism document
# Rq : when using geometry, multiple documents can be returned due to intersection
x <- get_apicarto_cadastre("29158", "commune")
document <- get_apicarto_gpu(x, "document")
document$partition
penmarch <- document$partition[2]

# get gpu features
## from shape
gpu <- get_apicarto_gpu(x, "zone-urba")
qtm(gpu, fill="typezone")

## from partition
gpu <- get_apicarto_gpu(penmarch, "zone-urba")
qtm(gpu, fill="typezone")

# example : all prescription
layers <- names(get_gpu_layers("prescription"))
prescriptions <- lapply(layers, \(x) get_apicarto_gpu(penmarch, x)) |>
   setNames(layers)

qtm(prescriptions$`prescription-pct`, fill = "libelle")+
qtm(prescriptions$`prescription-lin`, col = "libelle")+
qtm(prescriptions$`prescription-surf`, fill = "libelle")

# When using SUP, category can be used for filtering
# AC1 : Monuments historiques
penmarch <- get_apicarto_cadastre(29158)
mh <- get_apicarto_gpu(penmarch, "assiette-sup-s", category = "AC1")

# example : public utility servitude (SUP) generateur
## /!\ a generator can justify several assiette
gen_mh <- get_apicarto_gpu(penmarch, "generateur-sup-s", "AC1")

qtm(mh, fill = "lightblue")+qtm(gen_mh, fill = "red")

} # }
```
