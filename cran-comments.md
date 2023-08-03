## Test environments

* Windows Server 2022, R-devel, 64 bit
* Ubuntu Linux 20.04.1 LTS, R-release, GCC
* Fedora Linux, R-devel, clang, gfortran

## R CMD check results

There were no ERRORs or WARNINGs for each environnement

### Windows Server 2022, R-devel, 64 bit

There are 2 NOTES which can be ignored :
- lastMiKTeXException : see https://github.com/r-hub/rhub/issues/503
- NULL : see https://github.com/r-hub/rhub/issues/560

── happign 1.0.0: NOTE

  Build ID:   happign_1.0.0.tar.gz-3f5a67511a43498bbc0b99be7af2f6df
  Platform:   Windows Server 2022, R-devel, 64 bit
  Submitted:  48m 59.5s ago
  Build time: 7m 21.6s

❯ checking for non-standard things in the check directory ... NOTE
  Found the following files/directories:
    ''NULL''

❯ checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'

0 errors ✔ | 0 warnings ✔ | 2 notes ✖

### Ubuntu Linux 20.04.1 LTS, R-release, GCC

There is 1 NOTE that can be ignored :
- tidy : https://github.com/r-hub/rhub/issues/548

── happign 1.0.0: NOTE

  Build ID:   happign_1.0.0.tar.gz-85edc5b55e4b484cbd4c71c8a0f68332
  Platform:   Ubuntu Linux 20.04.1 LTS, R-release, GCC
  Submitted:  48m 59.6s ago
  Build time: 43m 54.3s

❯ checking HTML version of manual ... NOTE
  Skipping checking HTML validation: no command 'tidy' found

0 errors ✔ | 0 warnings ✔ | 1 note ✖

### Fedora Linux, R-devel, clang, gfortran

There is 1 NOTE that can be ignored :
- tidy : https://github.com/r-hub/rhub/issues/548

── happign 1.0.0: NOTE

  Build ID:   happign_1.0.0.tar.gz-4edc205be092475bb1d3180ac532e29a
  Platform:   Fedora Linux, R-devel, clang, gfortran
  Submitted:  48m 59.6s ago
  Build time: 37m 21.6s

❯ checking HTML version of manual ... NOTE
  Skipping checking HTML validation: no command 'tidy' found

0 errors ✔ | 0 warnings ✔ | 1 note ✖
