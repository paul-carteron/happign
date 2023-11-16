## Test environments

* Windows Server 2022, R-devel, 64 bit
* Windows Server 2022, R-release, 32/64 bit
* Ubuntu Linux 20.04.1 LTS, R-release, GCC
* Fedora Linux, R-devel, clang, gfortran

## R CMD check results

There were no ERRORs or WARNINGs for each environnement

### Windows Server 2022, R-devel, 64 bit

── happign 0.2.1: NOTE

  Build ID:   happign_0.2.1.tar.gz-d913df9579c1400dba591299ccc039e8
  Platform:   Windows Server 2022, R-devel, 64 bit
  Submitted:  1h 12m 9s ago
  Build time: 8m 57s

❯ checking CRAN incoming feasibility ... [43s] NOTE
  Maintainer: 'Paul Carteron <carteronpaul@gmail.com>'
  
  Found the following (possibly) invalid URLs:
    URL: http://www.geoinformations.developpement-durable.gouv.fr/nomenclature-nationale-des-sup-r1082.html (moved to https://www.geoinformations.developpement-durable.gouv.fr/nomenclature-nationale-des-sup-r1082.html)
      From: man/get_apicarto_gpu.Rd
      Status: 200
      Message: OK

❯ checking for non-standard things in the check directory ... NOTE
  Found the following files/directories:
    ''NULL''
  Found the following files/directories:
    'lastMiKTeXException'

0 errors ✔ | 0 warnings ✔ | 2 notes ✖

── happign 0.2.1: IN-PROGRESS

  Build ID:   happign_0.2.1.tar.gz-297c789019a748c3a20531c4a5676423
  Platform:   Ubuntu Linux 20.04.1 LTS, R-release, GCC
  Submitted:  1h 12m 9.1s ago


── happign 0.2.1: NOTE

  Build ID:   happign_0.2.1.tar.gz-abc42f0e197d416a90bd15908ed4e383
  Platform:   Fedora Linux, R-devel, clang, gfortran
  Submitted:  1h 12m 9.2s ago
  Build time: 1h 6m 32.6s

❯ checking CRAN incoming feasibility ... [11s/67s] NOTE
  Maintainer: ‘Paul Carteron <carteronpaul@gmail.com>’
  
  Found the following (possibly) invalid URLs:
    URL: http://www.geoinformations.developpement-durable.gouv.fr/nomenclature-nationale-des-sup-r1082.html (moved to https://www.geoinformations.developpement-durable.gouv.fr/nomenclature-nationale-des-sup-r1082.html)
      From: man/get_apicarto_gpu.Rd
      Status: 200
      Message: OK

❯ checking HTML version of manual ... NOTE
  Skipping checking HTML validation: no command 'tidy' found

### Windows Server 2022, R-release, 32/64 bit

### Ubuntu Linux 20.04.1 LTS, R-release, GCC

### Fedora Linux, R-devel, clang, gfortran

