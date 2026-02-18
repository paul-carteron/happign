## R CMD check results

I sucessfully pass R-CMD-Check test from rhub::rhub_check().
   
Result can be found [here](https://github.com/paul-carteron/happign/actions/runs/22150372230)

macos run doesn't work becvause of ``httpuv`

## R CMD check results

I sucessfully pass R-CMD-Check test for 7 OS :
   - {os: macos-latest,   r: 'release'}
   - {os: macos-14,       r: 'release'}
   - {os: windows-latest, r: 'release'}
   - {os: ubuntu-latest,  r: 'devel', http-user-agent: 'release'}
   - {os: ubuntu-latest,  r: 'release'}
   - {os: ubuntu-latest,  r: 'oldrel-1'}
   - {os: ubuntu-22.04,   r: 'release'}
   
Result can be found [here](https://github.com/paul-carteron/happign/actions/runs/22144271916)

## devtools::check_win_devel() results
Status: OK

Result can be found [here](https://win-builder.r-project.org/4f89GKZW6374)

## local devtools::check() results
── R CMD check results ──────────────────────────────────── happign 0.3.8 ────
Duration: 3m 21.4s

❯ checking for future file timestamps ... NOTE
  unable to verify current time

0 errors ✔ | 0 warnings ✔ | 1 note ✔
