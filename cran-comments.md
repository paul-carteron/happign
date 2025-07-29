## R CMD check results

I sucessfully pass R-CMD-Check test from rhun::rhub_chek().
   
Result can be found [here](https://github.com/paul-carteron/happign/actions/runs/16590340052)

Windows only failed beacause of `htmlwidget` package.

## R CMD check results

I sucessfully pass R-CMD-Check test for 7 OS :
   - {os: macos-latest,   r: 'release'}
   - {os: macos-14,       r: 'release'}
   - {os: windows-latest, r: 'release'}
   - {os: ubuntu-latest,  r: 'devel', http-user-agent: 'release'}
   - {os: ubuntu-latest,  r: 'release'}
   - {os: ubuntu-latest,  r: 'oldrel-1'}
   - {os: ubuntu-22.04,   r: 'release'}
   
Result can be found [here](https://github.com/paul-carteron/happign/actions/runs/16590241629)

## devtools::check_win_devel() results

```
* checking CRAN incoming feasibility ... [15s] NOTE
Maintainer: 'Paul Carteron <carteronpaul@gmail.com>'

Possibly misspelled words in DESCRIPTION:
  Carto (13:27)
  happign (12:63)

```

Result can be found [here](https://win-builder.r-project.org/3MDcn7WSYkyl/)

## local devtools::check() results
── R CMD check results ───────────────────────── happign 0.3.5 ────
Duration: 3m 55.2s

❯ checking for future file timestamps ... NOTE
  unable to verify current time

0 errors ✔ | 0 warnings ✔ | 1 note ✖
