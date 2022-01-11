
<!-- README.md is generated from README.Rmd. Please edit that file -->

# happign

<!-- badges: start -->

[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/happign)](https://cran.r-project.org/package=happign)
[![R-CMD-check](https://github.com/paul-carteron/happign/workflows/R-CMD-check/badge.svg)](https://github.com/paul-carteron/happign/actions)
[![codecov](https://codecov.io/gh/paul-carteron/happign/branch/main/graph/badge.svg?token=4QOH124P2K)](https://app.codecov.io/gh/paul-carteron/happign)
[![Project Status: Concept – Minimal or no implementation has been done
yet, or the repository is only intended to be a limited example, demo,
or
proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![license](https://img.shields.io/badge/license-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)
[![Last-changedate](https://img.shields.io/badge/last%20change-2022--01--06-yellowgreen.svg)](/commits/master)
[![Codecov test
coverage](https://codecov.io/gh/paul-carteron/happign/branch/main/graph/badge.svg)](https://app.codecov.io/gh/paul-carteron/happign?branch=main)
<!-- badges: end -->

The goal of happign is to …

## Installation

You can install the released version of happign from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("happign")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("paul-carteron/happign")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(happign)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this. You could also
use GitHub Actions to re-render `README.Rmd` every time you push. An
example workflow can be found here:
<https://github.com/r-lib/actions/tree/master/examples>.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
