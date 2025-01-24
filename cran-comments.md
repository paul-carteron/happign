## R CMD check results

I sucessfully pass R-CMD-Check test from rhun::rhub_chek()
   
Result can be found [here](https://github.com/paul-carteron/happign/actions/runs/12946026482)


## R CMD check results

I sucessfully pass R-CMD-Check test for 5 OS :
   * {os: macos-latest,   r: 'release'}
   * {os: windows-latest, r: 'release'}
   * {os: ubuntu-latest,   r: 'devel', http-user-agent: 'release'}
   * {os: ubuntu-latest,   r: 'release'}
   * {os: ubuntu-latest,   r: 'oldrel-1'}
   
Result can be found [here](https://github.com/paul-carteron/happign/actions/runs/12946018851)

## devtools::check_win_devel() results

Only one NOTE from figure folder I use to store precompile image for vignette

```
Non-standard file/directory found at top level:
  'figure'
```

Result can be found [here](https://win-builder.r-project.org/6RWAeEsUDSly/00check.log)

## local devtools::check() results
── R CMD check results  happign 0.3.2 ───
Duration: 2m 33.1s

❯ checking for future file timestamps ... NOTE
  unable to verify current time

0 errors ✔ | 0 warnings ✔ | 1 note ✖
