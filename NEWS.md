# happign 0.2.2
* Fix bug when creating bbox for `get_wms_raster()` getMap request when crs isn't latlong.

# happign 0.2.1
* Fix `get_wms_raster()` because of [#21](https://github.com/paul-carteron/happign/issues/21). Now using vrt and warping combine.
* Add support to wmts to `get_layers_metadata()`

# happign 0.2.0
* `get_wms_raster` is made faster by using gdalwarp from `sf::gdal_utils`. 
There is no longer need to download several tiles.
* update `cog_2022` dataset to `cog_2023`
* remove `get_apicarto_commune()` now supported by `get_apicarto_cadastre()`
* `jsonlite` is used instead of `geojsonsf` package
* some `get_wms_raster` and `get_wfs` parameter names have been changed :
   - shape -> x
   - layer_name -> layer
   - resolution -> res
* remove `get_wms_info` for `get_location_info`
* apikey `"enr"` is added

# happign 0.1.9
* add `get_apicarto_viticole()`
* add `get_apicarto_codes_postaux()`
* add `get_apicarto_rpg()`
* rework of `get_apicarto_gpu()`
* depreciation of `get_apicarto_commune()` now supported by `get_apicarto_cadastre()`
* rework of `get_last_news()`
* remove dependency to `checkmate`

# happign 0.1.8
* Correction of get_raw_lidar()
* New vignette "completion_of_ign_data_road_example"
* Precomputation of cran vignette
* Apply DRY principle to option("timeout") handling
* Add "penmarch.shp" as internal data for test and example
* Better handling of filename saving for `get_wfs()`
* Adding support for spatial and ecql filter to `get_wfs()`
* Remove dependecy to magritrr pipe `%>%` by `|>`
* Add internal shape for testing `point`, `multipoint`, `line`, `multiline`, `poly`, `multipoly`
* add `get_wfs_attributes()` function
* `NULL` is returned when no data found

# happign 0.1.7
* Correct bug preventing `get_apicarto_commune` to work with dep and insee code
* Adding 1 hour of downloading to `get_wfs()` for big shape
* Remove connection to IGN news when library is load. Now `get_last_news()` can be used
to retrieve last news.
* Adding `interactive` parameter to `get_wfs` and `get_wms_raster` to allow quick use
* Catch error from `get_raw_lidar`
* Change and complete vignette "happign for forester" on website
* Handling errors with tryCatch
* `get_apicarto_plu()` is now `get_apicarto_gpu()` : it can handle complex shape 
and access all ressources from [APIcarto GPU](https://apicarto.ign.fr/api/doc/gpu)
* For consistency, it is now necessary to add drivers to filename in `get_wms_raster()`
 like `get_wfs()`. The automatic addition of resolution to `filename` has been removed
for simplicity.

# happign 0.1.6
* `get_wms_raster()` use gdal with `sf::gdal_utils()` for downloading and `terra::vrt()` for
merging for quiet faster results. `stars` package is not used anymore.
* `get_wms_raster()` supports the download of big raster of several gigabytes
* `get_wms_raster()` has new `crs` argument
* New function `get_raw_lidar()` to download raw lidar data
* New function `get_apicarto_commune()` to download commune borders from apicarto
* A new dataset containing names of communes and their associated insee code has been added
* Simplify `get_layers_metadata()` to retrieve only title, name, and abstract
* Remove dependency to `tidyr`
* new function `get_raw_lidar()` to download raw lidar data from IGN
* new function `get_apicarto_commune` to download commune borders from the apicarto "cadastre" of IGN

# happign 0.1.5
* remove `get_iso()`
* remove dependency to `httr` by `httr2`
* add `get_wms_info()` to find metadata of a layer
* add `get_apicarto_plu()` (Plan Local d'Urbanisme)
* Rework of `get_wms_raster()`
* Adding new apikey "ocsge"
* Better testing
* Add all insee code as package data `data("code_insee")`
* `get_apicarto_*` now support MultiPolygon
* `get_wms_raster` now have 1h for downloading tile instead of 1min (for low connection)

# happign 0.1.4

* Fix resolution for `get_wms_raster()`. Depending on shape and resolution, multiple tile are downloaded and combine to get the right resolution. Also adding vignette Resolution for raster for further explanation
* New start up message based on RSS flux of IGN website to warn user if there issues (slowdown, shutdown) or news resources
*`get_wms_raster()` now fix S2 geometry problems
* adding `method` and `mode` argument of `download.file()` to have more freedom on the type of download with `get_wms_raster()`
* Completion of the `happign_for_forester` vignette
* adding first `get_apicarto_*` vectorized function for cadastre
* adding `shp_to_geojson()` function to avoid `geojsonsf` package dependency


# happign 0.1.3

* adding connection to isochrone and isodistance calculation of IGN with `get_iso()`
* new vignette [happign for forester](https://paul-carteron.github.io/happign/articles/web_only/happign_for_foresters.html)
* new vignette [SCAN 25, SCAN 100 et SCAN OACI](https://paul-carteron.github.io/happign/articles/SCAN_25_SCAN_100_SCAN_OACI.html)

# happign 0.1.2

* adding a `filename` argument to `get_wms_raster()` and `get_wfs()` allowing to save data on disk. This new feature also overcomes the problem of connection to some WMS with GDAL [#1](https://github.com/paul-carteron/happign/issues/1)
* Automatic weekly detection of http errors for all WFS and WMS APIs. Layers not readable by `get_wms_raster()`[#1](https://github.com/paul-carteron/happign/issues/1) are also listed.
* adding data license of IGN (etalab 2.0) to readme

# happign 0.1.1

* add function to test internet connection and availability of IGN website when loading `happign`)
* test improvement
* readme and vignette improvement

# happign 0.1.0

* add interface for WFS, and WMS raster service with `get_wfs()` and `get_wms_raster()`
* add `get_apikeys()` and `get_layers_metadata()` to allow access to metadata from R 
