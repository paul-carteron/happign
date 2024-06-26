% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_iso.R
\name{get_iso}
\alias{get_iso}
\alias{get_isodistance}
\alias{get_isochrone}
\title{isochronous/isodistance  calculations}
\usage{
get_iso(x,
        value,
        type = "time",
        profile = "pedestrian",
        time_unit = "minute",
        distance_unit = "meter",
        direction = "departure",
        source = "pgr",
        constraints = NULL)

get_isodistance(x,
                dist,
                unit = "meter",
                source = "pgr",
                profile = "car",
                direction = "departure",
                constraints = NULL)

get_isochrone(x,
              time,
              unit = "minute",
              source = "pgr",
              profile = "car",
              direction = "departure",
              constraints = NULL)
}
\arguments{
\item{x}{Object of class \code{sf} or \code{sfc} with POINT geometry. There may be
several points in the object. In this case, the output will contain as many
polygons as points.}

\item{value}{\code{numeric}; A quantity of time or distance.}

\item{type}{\code{character}; Specifies the type of calculation performed:
"time" for isochrone or "distance" for isodistance (isochrone by default).}

\item{profile}{\code{character}; Type of cost used for calculation: "pedestrian"
for #' pedestrians and "car" for cars. and "car" for cars ("pedestrian"
by default).}

\item{time_unit}{\code{character}; Allows you to specify the unit in which times
are expressed in the answer: "hour", "minute" or "second" (minutes by
default).}

\item{distance_unit}{\code{character}; Allows you to specify the unit in which
distances are expressed in the answer: "meter" or "kilometer" (meter by
default).}

\item{direction}{\code{character}; Direction of travel. Either define a
"departure" point and obtain the potential arrival points. Or define an
"arrival" point and obtain the potential points ("departure" by default).}

\item{source}{\code{character}; This parameter specifies which source will
be used for the calculation. Currently, "valhalla" and "pgr" sources are
available (default "pgr"). See section \code{SOURCE} for further information.}

\item{constraints}{Used to express constraints on the characteristics
to calculate isochrones/isodistances. See section \code{CONSTRAINTS}.}

\item{dist}{\code{numeric}; A quantity of time.}

\item{unit}{see \code{time_unit} and \code{distance_unit} param.}

\item{time}{\code{numeric}; A quantity of time.}
}
\value{
object of class \code{sf} with \code{POLYGON} geometry
}
\description{
Calculates isochrones or isodistances in France from an sf object using the
IGN API on the Géoportail platform. The reference data comes from the IGN
BD TOPO® database. For further information see IGN
\href{https://geoservices.ign.fr/documentation/services/api-et-services-ogc/isochrone/api}{documentation.}
}
\section{Functions}{
\itemize{
\item \code{get_isodistance()}: Wrapper function to calculate isodistance from \link{get_iso}.

\item \code{get_isochrone()}: Wrapper function to calculate isochrone from \link{get_iso}.

}}
\section{SOURCE}{


Isochrones are calculated using the same resources as for route calculation.
PGR" and "VALHALLA" resources are used, namely "bdtopo-valhalla" and "bdtopo-pgr".
\itemize{
\item bdtopo-valhalla" : To-Do
\item bdtopo-iso" is based on the old services over a certain distance, to solve
performance problems. We recommend its use for large isochrones.
}

PGR resources are resources that use the PGRouting engine to calculate
isochrones. ISO resources are more generic. The engine used for calculations
varies according to several parameters. At present, the parameter concerned
is cost_value, i.e. the requested time or distance.
}

\seealso{
\link{get_isodistance}, \link{get_isochrone}
}
