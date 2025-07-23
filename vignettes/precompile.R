# Precompiled vignettes that depend on web geoservice
# Must manually move image files from eia/ to eia/vignettes/ after knit
# thanks to leonawicz from https://github.com/ropensci/eia/blob/master/vignettes/precompile.R
# for inspiration

library(knitr)
knit("vignettes/getting_started.Rmd.orig", "vignettes/getting_started.Rmd")

