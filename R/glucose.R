# Glucose


#' @title Write a glucose dataframe to the database
#' @description
#' For backwards compatibility, it allows a table in cgmr original glucose_records format.
#' @param con valid database connection
#' @param glucose_df new valid glucose dataframe to write to this database 'glucose_records' table.
#' @param dry_run logical (default = TRUE) don't actually write to database.
#' @param user_id user ID
#' @return the records written to the database
#' @import  dplyr
#' @importFrom magrittr %>%
db_write_glucose <- function(con, glucose_df, user_id = 1234, dry_run = TRUE ) {

  ID = user_id

  new_records <- if (!("timestamp" %in% names(glucose_df))) {
    glucose_df %>% dplyr::rename("timestamp" = "time")
  } else glucose_df


  maxDate <- tbl(con, "glucose_records") %>% filter(.data[["user_id"]] == ID) %>%
    filter(.data[["timestamp"]] == max(.data[["timestamp"]], na.rm = TRUE)) %>% pull("timestamp")

  maxDate <- if (length(maxDate > 0)) maxDate else NA

  new_records <-
    new_records %>%
    dplyr::filter(.data[["timestamp"]] > {if(is.na(maxDate)) min(.data[["timestamp"]]) else maxDate}) %>%

    bind_cols(user_id=ID)



  if (dry_run){
    message(sprintf("Want to write %d records to glucose_table", nrow(new_records)))
  } else {
    DBI::dbWriteTable(con,
                      name = "glucose_records",
                      value = new_records,
                      row.names = FALSE,
                      append = TRUE)
  }


  return(new_records)
}



