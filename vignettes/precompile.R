# Precompiled vignettes that depend on web geoservice
# Must manually move image files from eia/ to eia/vignettes/ after knit
# thanks to leonawicz from https://github.com/ropensci/eia/blob/master/vignettes/precompile.R
# for inspiration

library(knitr)

opts_knit$set(base.dir = "vignettes", base.url = "")

input <- "vignettes/getting_started.Rmd.orig"
output <- "vignettes/getting_started.Rmd"

# Convert R code into R chunks and delete chunk outputs
lines <- readLines(output)
state = "text"
for (i in seq_along(lines)) {
   l <- lines[i]
   if (l == "``` r") {
      l <- "```{r}"
      state <- "chunk"
   } else if(l == "```") {
      if (state == "text") {
         l <- "<!--  TO BE DELETED -->"
         state <- "output"
      } else if(state == "chunk") {
         state <- "text"
      } else if (state == "output") {
         l <- "<!--  TO BE DELETED -->"
         state <- "text"
      }
   } else if (state == "output") {
      l <- "<!--  TO BE DELETED -->"
   }
   if (i > 1) {
      if (l == "" && (lines[i - 1] == "" || lines[i - 1] == "<!--  TO BE DELETED -->")) {
         l <- "<!--  TO BE DELETED -->"
      }
   }
   lines[i] <- l
}
lines <- lines[lines != "<!--  TO BE DELETED -->"]
writeLines(unlist(lines), input)

knit(input, output)

# Post-processing
lines <- readLines(output)
# Remove only the caption lines (Is it still necessary?)
cleaned <- grep('<p class="caption">.*</p>', lines, invert = TRUE, value = TRUE)
# Remove automated generated images
cleaned <- cleaned[!grepl("^!\\[plot of chunk", cleaned)]
writeLines(cleaned, output)
# Clean folder from created images
unlink("vignettes/figure", recursive = TRUE, force = TRUE)
