% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{dep_2025}
\alias{dep_2025}
\title{French Departments Table (2025)}
\format{
A data frame with one row per department and the following columns:
\describe{
\item{DEP}{(chr) Department code (3 characters)}
\item{REG}{(int) Region code (2 characters)}
\item{CHEFLIEU_DEP}{(chr) Commune code of the departmental capital (5 characters)}
\item{TNCC_DEP}{(int) Name type indicator (1 character)}
\item{NCC_DEP}{(chr) Official name in uppercase (200 characters)}
\item{NCCENR_DEP}{(chr) Official name with proper typography (200 characters)}
\item{LIBELLE_DEP}{(chr) Official name with article and proper typography (200 characters)}
}
}
\source{
\url{https://www.insee.fr/fr/statistiques/fichier/8377162/cog_ensemble_2025_csv.zip}
}
\usage{
dep_2025
}
\description{
Data for French departments from the INSEE file "Départements".
}
\keyword{datasets}
