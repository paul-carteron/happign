# code to prepare `cog_2023` dataset goes here

# Avoid non-ascii warning by forcing to UTF-8 encode
cog_2023 <- read.csv("https://www.insee.fr/fr/statistiques/fichier/6800675/v_commune_2023.csv")

Encoding(cog_2023$LIBELLE) <- "latin1"
cog_2023$LIBELLE <- iconv(
   cog_2023$LIBELLE,
   "latin1",
   "UTF-8"
)

usethis::use_data(cog_2023, overwrite = T)
