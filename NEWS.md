# happign 0.1.3

* adding connection to isochrone and isodistance calculation of IGN with `get_iso()`
* new vignette [happign for forester](https://paul-carteron.github.io/happign/articles/web_only/happign_for_foresters.html)
* new vignete[SCAN 25, SCAN 100 et SCAN OACI](https://paul-carteron.github.io/happign/articles/web_only/SCAN_25_SCAN_100_SCAN_OACI.html)

# happign 0.1.2

* adding a `filename` argument to `get_wms_raster()` and `get_wfs()` allowing to save data on disk. This new feature also overcomes the problem of connection to some WMS with GDAL [#1](https://github.com/paul-carteron/happign/issues/1)
* Automatic weekly detection of http errors for all WFS and WMS APIs. Layers not readable by `get_wms_raster()`[#1](https://github.com/paul-carteron/happign/issues/1) are also listed. The automatic report is published on the [`happign` site](https://paul-carteron.github.io/happign/articles/web_only/Non_functional_APIs.html)
* adding data license of IGN (etalab 2.0) to readme

# happign 0.1.1

* add function to test internet connection and availability of IGN website when loading `happign`)
* test improvement
* readme and vignette improvement

# happign 0.1.0

* add interface for WFS, and WMS raster service with `get_wfs()` and `get_wms_raster()`
* add `get_apikeys()` and `get_layers_metadata` to allow access to metadata from R 
