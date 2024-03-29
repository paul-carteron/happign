% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_apicarto_cadastre.R
\name{get_apicarto_cadastre}
\alias{get_apicarto_cadastre}
\title{Apicarto Cadastre}
\usage{
get_apicarto_cadastre(x,
                      type = "parcelle",
                      source = "PCI",
                      section = list(NULL),
                      numero = list(NULL),
                      code_arr = list(NULL),
                      code_abs = list(NULL),
                      code_com = list(NULL),
                      dTolerance = 0)
}
\arguments{
\item{x}{It can be a shape, insee codes or departement codes :
\itemize{
\item Shape : must be an object of class \code{sf} or \code{sfc}.
\item Code insee : must be a \code{character} of length 5
\item Code departement : must be a \code{character} of length  2 or 3 (DOM-TOM)
}}

\item{type}{A \code{character} from \code{"parcelle"}, \code{"commune"}, \code{"feuille"},
\code{"division"}, \code{"localisant"}}

\item{source}{Can be "BDP" for BD Parcellaire or "PCI" for Parcellaire express.
See detail for more info.}

\item{section}{A \code{character} of length 2}

\item{numero}{A \code{character} of length 4}

\item{code_arr}{A \code{character} corresponding to district code for Paris,
Lyon, Marseille}

\item{code_abs}{A \code{character} corresponding to the code of absorbed commune.
This prefix is useful to differentiate between communes that have merged}

\item{code_com}{A \code{character} of length 5 corresponding to the commune code. Only use with
\code{type = "division"} or \code{type = "feuille"}}

\item{dTolerance}{numeric; Complex shape cannot be handle by API; using \code{dTolerance}
allow to simplify them. See \code{?sf::st_simplify}}
}
\value{
Object of class \code{sf}
}
\description{
Implementation of the cadastre module from the
\href{https://apicarto.ign.fr/api/doc/cadastre}{IGN's apicarto}
}
\details{
\code{x}, \code{section}, \code{numero}, \code{code_arr}, \code{code_abs}, \code{code_com} can take vector of character.
In this case vector recycling is done. See the example section below.

\code{source}: BD Parcellaire is a discontinued product. Its use is no longer
recommended because it is no longer updated. The use of PCI Express is
strongly recommended and will become mandatory. More information on the
comparison of this two products can be found
\href{https://geoservices.ign.fr/sites/default/files/2021-07/Comparatif_PEPCI_BDPARCELLAIRE.pdf}{here}
}
\examples{
\dontrun{
library(sf)

# shape from the town of penmarch
penmarch <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))

# get commune borders
## from shape
penmarch_borders <- get_apicarto_cadastre(penmarch, type = "commune")

## from insee_code
border <- get_apicarto_cadastre("29158", type = "commune")
borders <- get_apicarto_cadastre(c("29158", "29165"), type = "commune")

# get cadastral parcels
## from shape
parcels <- get_apicarto_cadastre(penmarch, section = "AX")

## from insee code
parcels <- get_apicarto_cadastre("29158")

# Use parameter recycling
## get sections "AX" parcels from multiple insee_code
parcels <- get_apicarto_cadastre(c("29158", "29165"), section = "AX")

## get parcels numbered "0001", "0010" of section "AX" and "BR"
section <- c("AX", "BR")
numero <- rep(c("0001", "0010"), each = 2)
parcels <- get_apicarto_cadastre("29158", section = section, numero = numero)

## generalization with expand.grid
params <- expand.grid(code_insee = c("29158", "29165"),
                      section = c("AX", "BR"),
                      numero = c("0001", "0010"),
                      stringsAsFactors = FALSE)
parcels <- get_apicarto_cadastre(params$code_insee,
                                 section = params$section,
                                 numero = params$numero)

}

}
