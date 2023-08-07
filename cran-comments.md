# Warning :
   I test with happign 1.0.0 but i finally decided to stay at 0.2.0. There's 
no difference in code between both version.

## Test environments

* Windows Server 2022, R-devel, 64 bit
* Windows Server 2022, R-release, 32/64 bit
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

### Windows Server 2022, R-release, 32/64 bit

There is 1 NOTE but i cannot do much because data contain accent

── happign 1.0.0: NOTE

Build ID: 	happign_1.0.0.tar.gz-3ecf3a4b4d2547fd9803fc834070abe9
Platform: 	Windows Server 2022, R-release, 32/64 bit
Submitted: 	7 minutes 52.1 seconds ago
Build time: 	7 minutes 49.2 seconds

NOTES:

* checking data for non-ASCII characters ... NOTE
  Note: found 7592 marked UTF-8 strings

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
