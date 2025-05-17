## R CMD check results

I sucessfully pass R-CMD-Check test from rhun::rhub_chek()
   
Result can be found [here](https://github.com/paul-carteron/happign/actions/runs/14127781478)

ubuntu next : Failed to build s2 1.1.8 (2.4s)
ubuntu release : ✖ Failed to build s2 1.1.8 (1.7s)
m1-san : ✖ Failed to build httpuv 1.6.16 (25.3s)
mac-os-arm-64 : ✖ Failed to build httpuv 1.6.16 (25.4s)
## R CMD check results

I sucessfully pass R-CMD-Check test for 7 OS :
   - {os: macos-latest,   r: 'release'}
   - {os: macos-14,       r: 'release'}
   - {os: windows-latest, r: 'release'}
   - {os: ubuntu-latest,  r: 'devel', http-user-agent: 'release'}
   - {os: ubuntu-latest,  r: 'release'}
   - {os: ubuntu-latest,  r: 'oldrel-1'}
   - {os: ubuntu-22.04,   r: 'release'}

   
Result can be found [here](https://github.com/paul-carteron/happign/actions/runs/14114446956)

## devtools::check_win_devel() results

```
* checking CRAN incoming feasibility ... [12s] WARNING
Maintainer: 'Paul Carteron <carteronpaul@gmail.com>'

```

Result can be found [here](https://win-builder.r-project.org/Ikr7K9gjqqX5/00check.log)

## local devtools::check() results
── R CMD check results ─ happign 0.3.4 ────
Duration: 4m 4.6s

❯ checking for future file timestamps ... NOTE
  unable to verify current time

0 errors ✔ | 0 warnings ✔ | 1 note ✖
