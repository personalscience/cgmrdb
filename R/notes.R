# Handling Notes-related functions

#' @title Write a notes dataframe to the database
#' @description
#' For backwards compatibility, it allows a table in cgmr original notes_records format.
#' @param con valid database connection
#' @param notes_df new valid glucose dataframe to write to this database 'glucose_records' table.
#' @param dry_run logical (default = TRUE) don't actually write to database.
#' @param user_id user ID
#' @return the records written to the database
#' @import  dplyr
#' @importFrom magrittr %>%
db_write_notes <- function(con, notes_df, user_id = 1234, dry_run = TRUE ) {

  ID = user_id

  new_records <- if (("SOMETHING" %in% names(notes_df))) {  # NOT USED but may be handy later
    notes_df %>% dplyr::rename("timestamp" = "time")
  } else notes_df


  maxDate <- tbl(con, "notes_records") %>% filter(.data[["user_id"]] == ID) %>%
    filter(.data[["Start"]] == max(.data[["Start"]], na.rm = TRUE)) %>% pull("Start")

  maxDate <- if (length(maxDate > 0)) maxDate else NA

  new_records <-
    new_records %>%
    dplyr::filter(.data[["Start"]] > {if(is.na(maxDate)) min(.data[["Start"]]) else maxDate}) %>%

    bind_cols(user_id=ID)



  if (dry_run){
    message(sprintf("Want to write %d records to notes_table", nrow(new_records)))
  } else {
    DBI::dbWriteTable(con,
                      name = "notes_records",
                      value = new_records,
                      row.names = FALSE,
                      append = TRUE)
  }


  return(new_records)
}
