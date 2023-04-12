## Checks

### Local check seems fine

`devtools::check()` result:

0 errors √ | 0 warning x | 0 notes √

### Online check seem fine as well :

/!\ : IGN is a french institut and 'cadastral' is a real word

`rhub::check_for_cran()`
── happign 0.1.9: NOTE

  Build ID:   happign_0.1.9.tar.gz-0e469a12151f4925a2950695be9198b9
  Platform:   Windows Server 2022, R-devel, 64 bit
  Submitted:  17h 16m 1.8s ago
  Build time: 6m 14.1s

❯ checking CRAN incoming feasibility ... [39s] NOTE
  Maintainer: 'Paul Carteron <carteronpaul@gmail.com>'
  
  Possibly misspelled words in DESCRIPTION:
    IGN (8:64)
    cadastral (12:33)

❯ checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'

0 errors ✔ | 0 warnings ✔ | 2 notes ✖

── happign 0.1.9: NOTE

  Build ID:   happign_0.1.9.tar.gz-7ccb2ec226ad4108a48e473ac361eaa7
  Platform:   Ubuntu Linux 20.04.1 LTS, R-release, GCC
  Submitted:  17h 16m 1.8s ago
  Build time: 4h 8m 38.1s

❯ checking CRAN incoming feasibility ... NOTE
  Maintainer: ‘Paul Carteron <carteronpaul@gmail.com>’
  
  Possibly misspelled words in DESCRIPTION:
    cadastral (12:33)
    IGN (8:64)

0 errors ✔ | 0 warnings ✔ | 1 note ✖

── happign 0.1.9: NOTE

  Build ID:   happign_0.1.9.tar.gz-db0fa32ae37042389d6b64120191f0e2
  Platform:   Fedora Linux, R-devel, clang, gfortran
  Submitted:  17h 16m 1.9s ago
  Build time: 3h 34m 36.4s

❯ checking CRAN incoming feasibility ... [11s/87s] NOTE
  Maintainer: ‘Paul Carteron <carteronpaul@gmail.com>’
  
  Possibly misspelled words in DESCRIPTION:
    IGN (8:64)
    cadastral (12:33)

❯ checking HTML version of manual ... NOTE
  Skipping checking HTML validation: no command 'tidy' found

0 errors ✔ | 0 warnings ✔ | 2 notes ✖
