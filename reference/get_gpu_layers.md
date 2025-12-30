# Available GPU layers

Helpers that return available GPU layers and their type.

## Usage

``` r
get_gpu_layers(type = NULL)
```

## Arguments

- type:

  `character` One of `"commune"`, `"du"`, `"prescription"`,
  `"acte-sup"`, `"assiette"`, `"generateur"`. If `NULL`, all layers are
  retuned. `NULL` by default

## Value

list

## Details

`"du"`: "Document d'urbanisme" `"sup"`: "Servitude d'utilité publique"

## Examples

``` r
# All layers
names(get_gpu_layers())
#>  [1] "municipality"      "document"          "zone-urba"        
#>  [4] "secteur-cc"        "prescription-surf" "prescription-lin" 
#>  [7] "prescription-pct"  "info-surf"         "info-lin"         
#> [10] "info-pct"          "acte-sup"          "assiette-sup-s"   
#> [13] "assiette-sup-l"    "assiette-sup-p"    "generateur-sup-s" 
#> [16] "generateur-sup-l"  "generateur-sup-p" 

# All sup layers
names(get_gpu_layers("generateur"))
#> [1] "generateur-sup-s" "generateur-sup-l" "generateur-sup-p"

# All sup and du layers
names(get_gpu_layers(c("generateur", "prescription")))
#> [1] "prescription-surf" "prescription-lin"  "prescription-pct" 
#> [4] "generateur-sup-s"  "generateur-sup-l"  "generateur-sup-p" 
```
