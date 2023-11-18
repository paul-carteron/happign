## Test environments

* Windows Server 2022, R-devel, 64 bit
* Ubuntu Linux 20.04.1 LTS, R-release, GCC
* Fedora Linux, R-devel, clang, gfortran

## R CMD check results

There were no ERRORs or WARNINGs for each environnement. I re-check URL for 
Windows, they are good

### Windows Server 2022, R-devel, 64 bit

happign 0.2.1: NOTE

Build ID:	happign_0.2.1.tar.gz-e5da6226f8dd4990b695137eefe1d93e
Platform:	Windows Server 2022, R-devel, 64 bit
Submitted:	15 minutes 8.4 seconds ago
Build time:	15 minutes 7.5 seconds

NOTES:
* checking CRAN incoming feasibility ... [522s] NOTE
Maintainer: 'Paul Carteron <carteronpaul@gmail.com>'

Found the following (possibly) invalid URLs:
  URL: https://geoservices.ign.fr/documentation/services/api-et-services-ogc/images-wms-ogc
    From: man/get_wms_raster.Rd
    Status: Error
    Message: libcurl error code 28:
      	Operation timed out after 60001 milliseconds with 0 bytes received
  URL: https://geoservices.ign.fr/services-web-experts
    From: man/are_queryable.Rd
          man/get_layers_metadata.Rd
          man/get_location_info.Rd
          man/get_wfs.Rd
          man/get_wfs_attributes.Rd
          man/get_wms_raster.Rd
          man/get_wmts.Rd
          inst/doc/Getting_started.html
    Status: Error
    Message: libcurl error code 28:
      	Operation timed out after 60001 milliseconds with 0 bytes received
* checking for non-standard things in the check directory ... NOTE
Found the following files/directories:
  ''NULL''
* checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
### Ubuntu Linux 20.04.1 LTS, R-release, GCC

happign 0.2.1: NOTE

Build ID:	happign_0.2.1.tar.gz-0722a249a50e4cd19c45e6b92e8dd160
Platform:	Ubuntu Linux 20.04.1 LTS, R-release, GCC
Submitted:	1 hour 4 minutes 57.3 seconds ago
Build time:	1 hour 4 minutes 52 seconds

NOTES:
* checking HTML version of manual ... NOTE
Skipping checking HTML validation: no command 'tidy' found

### Fedora Linux, R-devel, clang, gfortran

happign 0.2.1: NOTE

Build ID:	happign_0.2.1.tar.gz-85ec9ef126cc40a3a504178edf07e393
Platform:	Fedora Linux, R-devel, clang, gfortran
Submitted:	55 minutes 50 seconds ago
Build time:	55 minutes 45.4 seconds

NOTES:
* checking HTML version of manual ... NOTE
Skipping checking HTML validation: no command 'tidy' found
