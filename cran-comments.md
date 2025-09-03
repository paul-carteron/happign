## R CMD check results

I sucessfully pass R-CMD-Check test from rhun::rhub_chek().
   
Result can be found [here](https://github.com/paul-carteron/happign/actions/runs/17428471751)

ubuntu-release failed because of package out of my control

## R CMD check results

I sucessfully pass R-CMD-Check test for 7 OS :
   - {os: macos-latest,   r: 'release'}
   - {os: macos-14,       r: 'release'}
   - {os: windows-latest, r: 'release'}
   - {os: ubuntu-latest,  r: 'devel', http-user-agent: 'release'}
   - {os: ubuntu-latest,  r: 'release'}
   - {os: ubuntu-latest,  r: 'oldrel-1'}
   - {os: ubuntu-22.04,   r: 'release'}
   
Result can be found [here](https://github.com/paul-carteron/happign/actions/runs/17428457231)

## devtools::check_win_devel() results
Status: OK

Result can be found [here](https://win-builder.r-project.org/cNRSWOIfHo46/00check.log)

## local devtools::check() results
── R CMD check results ────────────────────────── happign 0.3.6 ────
Duration: 2m 41.3s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
