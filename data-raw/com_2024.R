# code to prepare `cog_2023` dataset goes here

# Avoid non-ascii warning by forcing to UTF-8 encode
com_2024 <- read.csv("https://www.insee.fr/fr/statistiques/fichier/7766585/v_commune_2024.csv") |>
   dplyr::filter(!is.na(REG)) |>
   dplyr::select(COM, LIBELLE)

Encoding(com_2024$LIBELLE) <- "latin1"
com_2024$LIBELLE <- iconv(
   com_2024$LIBELLE,
   "latin1",
   "UTF-8"
)

usethis::use_data(com_2024, overwrite = T)
