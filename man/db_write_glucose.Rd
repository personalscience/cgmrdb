% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/glucose.R
\name{db_write_glucose}
\alias{db_write_glucose}
\title{Write a glucose dataframe to the database}
\usage{
db_write_glucose(con, glucose_df, user_id = 1234, dry_run = TRUE)
}
\arguments{
\item{con}{valid database connection}

\item{glucose_df}{new valid glucose dataframe to write to this database 'glucose_records' table.}

\item{user_id}{user ID}

\item{dry_run}{logical (default = TRUE) don't actually write to database.}
}
\value{
the records written to the database
}
\description{
For backwards compatibility, it allows a table in cgmr original glucose_records format.
}
