# Precompiled vignettes that depend on web geoservice
# Must manually move image files from eia/ to eia/vignettes/ after knit
# thanks to leonawicz from https://github.com/ropensci/eia/blob/master/vignettes/precompile.R
# for inspiration

library(knitr)

opts_knit$set(base.dir = "vignettes", base.url = "")

input <- "vignettes/getting_started_orig.Rmd/orig"
output <- "vignettes/getting_started.Rmd"
knit(input, output)

# Remove only the caption lines
lines <- readLines(output)
cleaned <- grep('<p class="caption">.*</p>', lines, invert = TRUE, value = TRUE)
writeLines(cleaned, output)

# figure
fig_dir <- "vignettes/figure"
fig <- list.files(fig_dir, full.names = TRUE)
lapply(fig, file.copy, "vignettes", overwrite = TRUE)
unlink(fig_dir, force = T, recursive = T)

lines <- readLines(output)
cleaned <- gsub('figure/', "", lines, fixed = T)
writeLines(cleaned, output)
