## R CMD check results

-- happign 0.1.1: NOTE

  Build ID:   happign_0.1.1.tar.gz-67bcba7ee8f441648a9745edae0c8c70
  Platform:   Windows Server 2022, R-devel, 64 bit
  Submitted:  38m 25.1s ago
  Build time: 7m 41s

> checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Paul Carteron <carteronpaul@gmail.com>'
  
  Possibly misspelled words in DESCRIPTION:
    WFS (10:28)
    WMS (10:48)

> checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'

0 errors √ | 0 warnings √ | 2 notes x

-- happign 0.1.1: NOTE

  Build ID:   happign_0.1.1.tar.gz-a94e04948a2f486d91ec91d953d79b17
  Platform:   Ubuntu Linux 20.04.1 LTS, R-release, GCC
  Submitted:  38m 25.2s ago
  Build time: 36m 8.4s

> checking CRAN incoming feasibility ... NOTE
  Maintainer: ‘Paul Carteron <carteronpaul@gmail.com>’
  
  Possibly mis-spelled words in DESCRIPTION:
    WFS (10:28)
    WMS (10:48)
  
  Found the following (possibly) invalid URLs:
    URL: https://geoservices.ign.fr/documentation/services/api-et-services-ogc
      From: man/get_layers_metadata.Rd
      Status: Error
      Message: libcurl error code 60:
        	SSL certificate problem: unable to get local issuer certificate
        	(Status without verification: OK)
    URL: https://geoservices.ign.fr/documentation/services/api-et-services-ogc/images-wms-ogc
      From: man/get_wms_raster.Rd
      Status: Error
      Message: libcurl error code 60:
        	SSL certificate problem: unable to get local issuer certificate
        	(Status without verification: OK)
    URL: https://geoservices.ign.fr/documentation/services/tableau_ressources
      From: man/get_apikeys.Rd
      Status: Error
      Message: libcurl error code 60:
        	SSL certificate problem: unable to get local issuer certificate
        	(Status without verification: OK)
    URL: https://geoservices.ign.fr/services-web-experts
      From: DESCRIPTION
            man/get_layers_metadata.Rd
            man/get_wfs.Rd
            man/get_wms_raster.Rd
            inst/doc/Getting_started.html
      Status: Error
      Message: libcurl error code 60:
        	SSL certificate problem: unable to get local issuer certificate
        	(Status without verification: OK)
    URL: https://geoservices.ign.fr/services-web-experts-altimetrie
      From: inst/doc/Getting_started.html
      Status: Error
      Message: libcurl error code 60:
        	SSL certificate problem: unable to get local issuer certificate
        	(Status without verification: OK)

0 errors √ | 0 warnings √ | 1 note x

-- happign 0.1.1: NOTE

  Build ID:   happign_0.1.1.tar.gz-ce0ce0b856754c16a2c10a8aa54f1871
  Platform:   Fedora Linux, R-devel, clang, gfortran
  Submitted:  38m 25.2s ago
  Build time: 37m 27.2s

> checking CRAN incoming feasibility ... NOTE
  Maintainer: ‘Paul Carteron <carteronpaul@gmail.com>’
  
  Possibly misspelled words in DESCRIPTION:
    WFS (10:28)
    WMS (10:48)
  
  Found the following (possibly) invalid URLs:
    URL: https://geoservices.ign.fr/documentation/services/api-et-services-ogc
      From: man/get_layers_metadata.Rd
      Status: Error
      Message: libcurl error code 60:
        	SSL certificate problem: unable to get local issuer certificate
        	(Status without verification: OK)
    URL: https://geoservices.ign.fr/documentation/services/api-et-services-ogc/images-wms-ogc
      From: man/get_wms_raster.Rd
      Status: Error
      Message: libcurl error code 60:
        	SSL certificate problem: unable to get local issuer certificate
        	(Status without verification: OK)
    URL: https://geoservices.ign.fr/documentation/services/tableau_ressources
      From: man/get_apikeys.Rd
      Status: Error
      Message: libcurl error code 60:
        	SSL certificate problem: unable to get local issuer certificate
        	(Status without verification: OK)
    URL: https://geoservices.ign.fr/services-web-experts
      From: DESCRIPTION
            man/get_layers_metadata.Rd
            man/get_wfs.Rd
            man/get_wms_raster.Rd
            inst/doc/Getting_started.html
      Status: Error
      Message: libcurl error code 60:
        	SSL certificate problem: unable to get local issuer certificate
        	(Status without verification: OK)
    URL: https://geoservices.ign.fr/services-web-experts-altimetrie
      From: inst/doc/Getting_started.html
      Status: Error
      Message: libcurl error code 60:
        	SSL certificate problem: unable to get local issuer certificate
        	(Status without verification: OK)

0 errors √ | 0 warnings √ | 1 note x

* This is a new release.
