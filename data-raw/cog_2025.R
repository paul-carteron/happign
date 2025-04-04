library(archive)

# URL du fichier ZIP contenant les données
url <- "https://www.insee.fr/fr/statistiques/fichier/8377162/cog_ensemble_2025_csv.zip"

# Fonction pour lire un fichier CSV depuis une archive en s'assurant de l'encodage UTF-8
read_utf8_csv <- function(archive_file, file_name) {
   data <- archive::archive_read(archive_file, file = file_name) |>
      read.csv(fileEncoding = "UTF-8", encoding = "UTF-8")  # Assurer l'encodage en UTF-8
   return(data)
}

# Lire les fichiers CSV sans enlever les accents
com_2025 <- read_utf8_csv(url, "v_commune_2025.csv")
cols_to_suffix <- c("TNCC", "NCC", "NCCENR", "LIBELLE")
col_names <- colnames(com_2025)
names(com_2025) <- replace(
   col_names,
   col_names %in% cols_to_suffix,
   paste0(cols_to_suffix, "_COM"))

dep_2025 <- read_utf8_csv(url, "v_departement_2025.csv")
cols_to_suffix <- c("CHEFLIEU", "TNCC", "NCC", "NCCENR", "LIBELLE")
col_names <- colnames(dep_2025)
names(dep_2025) <- replace(
   col_names,
   col_names %in% cols_to_suffix,
   paste0(cols_to_suffix, "_DEP"))

reg_2025 <- read_utf8_csv(url, "v_region_2025.csv")
cols_to_suffix <- c("CHEFLIEU", "TNCC", "NCC", "NCCENR", "LIBELLE")
col_names <- colnames(reg_2025)
names(reg_2025) <- replace(
   col_names,
   col_names %in% cols_to_suffix,
   paste0(cols_to_suffix, "_REG"))

# Sauvegarder les datasets nettoyés dans le package
usethis::use_data(com_2025, overwrite = TRUE, compress = "xz")
usethis::use_data(dep_2025, overwrite = TRUE, compress = "gzip")
usethis::use_data(reg_2025, overwrite = TRUE, compress = "gzip")
