#' COG 2023
#'
#' A dataset containing insee code and wording of commune as of January 1, 2023. COG mean
#' Code Officiel Géographique
#'

#' @format ## `cog_2023`
#' A data frame with 34990 rows and 2 columns:
#' \describe{
#'   \item{COM}{insee code}
#'   \item{LIBELLE}{Name of commune}
#' }
#' @source \url{https://www.insee.fr/fr/information/6800675}
"cog_2023"

#' COG 2024
#'
#' A dataset containing insee code and wording of commune as of January 1, 2024. COG mean
#' Code Officiel Géographique
#'

#' @format ## `com_2024`
#' A data frame with 34980 rows and 2 columns:
#' \describe{
#'   \item{COM}{insee code}
#'   \item{LIBELLE}{Name of commune}
#' }
#' @source \url{https://www.insee.fr/fr/information/7766585}
"com_2024"

#' French Communes Table (2025)
#'
#' Data for French communes from the INSEE file "v_commune_2025.csv".
#'
#' @format A data frame with one row per commune and the following columns:
#' \describe{
#'   \item{TYPECOM}{(chr) Type of commune (4 characters)}
#'   \item{COM}{(chr) Commune code (5 characters)}
#'   \item{REG}{(int) Region code (2 characters)}
#'   \item{DEP}{(chr) Department code (3 characters)}
#'   \item{CTCD}{(chr) Code of the territorial collectivity with departmental powers (4 characters)}
#'   \item{ARR}{(chr) District (arrondissement) code (4 characters)}
#'   \item{TNCC_COM}{(int) Name type indicator (1 character)}
#'   \item{NCC_COM}{(chr) Official name in uppercase (200 characters)}
#'   \item{NCCENR_COM}{(chr) Official name with proper typography (200 characters)}
#'   \item{LIBELLE_COM}{(chr) Official name with article and proper typography (200 characters)}
#'   \item{CAN}{(chr) Canton code (5 characters). For “multi-canton” communes, code ranges from 99 to 90 (pseudo-canton) or 89 to 80 (new communes)}
#'   \item{COMPARENT}{(int) Parent commune code for municipal districts and associated or delegated communes (5 characters)}
#' }
#'
#' @source \url{https://www.insee.fr/fr/statistiques/fichier/8377162/cog_ensemble_2025_csv.zip}
"com_2025"

#' French Departments Table (2025)
#'
#' Data for French departments from the INSEE file "Départements".
#'
#' @format A data frame with one row per department and the following columns:
#' \describe{
#'   \item{DEP}{(chr) Department code (3 characters)}
#'   \item{REG}{(int) Region code (2 characters)}
#'   \item{CHEFLIEU_DEP}{(chr) Commune code of the departmental capital (5 characters)}
#'   \item{TNCC_DEP}{(int) Name type indicator (1 character)}
#'   \item{NCC_DEP}{(chr) Official name in uppercase (200 characters)}
#'   \item{NCCENR_DEP}{(chr) Official name with proper typography (200 characters)}
#'   \item{LIBELLE_DEP}{(chr) Official name with article and proper typography (200 characters)}
#' }
#'
#' @source \url{https://www.insee.fr/fr/statistiques/fichier/8377162/cog_ensemble_2025_csv.zip}
"dep_2025"

#' French Regions Table (2025)
#'
#' Data for French regions from the INSEE file "Régions".
#'
#' @format A data frame with one row per region and the following columns:
#' \describe{
#'   \item{REG}{(int) Region code (2 characters)}
#'   \item{CHEFLIEU_REG}{(chr) Commune code of the regional capital (5 characters)}
#'   \item{TNCC_REG}{(int) Name type indicator (1 character)}
#'   \item{NCC_REG}{(chr) Official name in uppercase (200 characters)}
#'   \item{NCCENR_REG}{(chr) Official name with proper typography (200 characters)}
#'   \item{LIBELLE_REG}{(chr) Official name with article and proper typography (200 characters)}
#' }
#'
#' @source \url{https://www.insee.fr/fr/statistiques/fichier/8377162/cog_ensemble_2025_csv.zip}
"reg_2025"

