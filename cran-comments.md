## R CMD check results

I sucessfully pass R-CMD-Check test for 5 OS :
   * {os: macos-latest,   r: 'release'}
   * {os: windows-latest, r: 'release'}
   * {os: ubuntu-latest,   r: 'devel', http-user-agent: 'release'}
   * {os: ubuntu-latest,   r: 'release'}
   * {os: ubuntu-latest,   r: 'oldrel-1'}
   
Result can be found [here](https://github.com/paul-carteron/happign/actions/runs/8980856731)


## rhub::rhub_check()

I check 4 OS with new rhub::check_rhub(). Build can be found [here](https://github.com/paul-carteron/happign/actions/runs/8967409459).

Checks for Windows isn't working because of source installation of package terra.

I ask for the problem [here](https://github.com/r-hub/rhub/issues/605).

