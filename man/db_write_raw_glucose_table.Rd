% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/db_create.R
\name{db_write_raw_glucose_table}
\alias{db_write_raw_glucose_table}
\title{Write a table to the database}
\usage{
db_write_raw_glucose_table(con, table_name = "raw_glucose", table_df)
}
\arguments{
\item{con}{valid database connection}

\item{table_name}{char string for table name}

\item{table_df}{valid dataframe to write to the database}
}
\value{
character string with a message that can be displayed to the user
}
\description{
Write a table to the database
}
