## R CMD check results

I sucessfully pass R-CMD-Check test from rhun::rhub_chek() for windows and ubuntu os.

mac-os doesn't work becaus of other packages :
   - macos-arm64 (R-devel) : ✖ Failed to build httpuv 1.6.16 (40.2s)
   - m1-san (R-devel) : ✖ Failed to build httpuv 1.6.16 (51.1s)
   
Result can be found [here](https://github.com/paul-carteron/happign/actions/runs/14127781478)

## R CMD check results

I sucessfully pass R-CMD-Check test for 7 OS :
   - {os: macos-latest,   r: 'release'}
   - {os: macos-14,       r: 'release'}
   - {os: windows-latest, r: 'release'}
   - {os: ubuntu-latest,  r: 'devel', http-user-agent: 'release'}
   - {os: ubuntu-latest,  r: 'release'}
   - {os: ubuntu-latest,  r: 'oldrel-1'}
   - {os: ubuntu-22.04,   r: 'release'}
   
Result can be found [here](https://github.com/paul-carteron/happign/actions/runs/16449195501)

## devtools::check_win_devel() results

```
* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Paul Carteron <carteronpaul@gmail.com>'

```

Result can be found [here](https://win-builder.r-project.org/utOa5t5gAw7H/00check.log)

## local devtools::check() results
── R CMD check results ──────── happign 0.3.5 ────
Duration: 2m 46.7s

❯ checking for future file timestamps ... NOTE
  unable to verify current time

0 errors ✔ | 0 warnings ✔ | 1 note ✖
