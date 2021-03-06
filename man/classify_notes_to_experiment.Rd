% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/notes.R
\name{classify_notes_to_experiment}
\alias{classify_notes_to_experiment}
\title{Classify Notes According to Experiment}
\usage{
classify_notes_to_experiment(foodname, mapping_table)
}
\arguments{
\item{foodname}{character vector with name(s) of food item}

\item{mapping_table}{dataframe showing how to do the mapping.}
}
\value{
character vector with canonical name for the food item
}
\description{
User data might not have the precise word to describe a particular Comment (usually a food name). This
function will return a canonical version of the Comment, based on data from the Experiments table.
}
