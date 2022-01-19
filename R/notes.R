# Handling Notes-related functions




#' @title Drop Notes and Write From Scratch
#' @param con valid database connection
#' @param notes_df table to write to notes records
#' @param dry_run logical: if true, then don't make any permanent changes
write_notes_raw_from_scratch <- function(con, notes_df, dry_run = FALSE) {

  if(DBI::dbExistsTable(con, "notes_records_raw")){
    DBI::dbRemoveTable(con, "notes_records_raw")
  }

  make_table_with_index(con, table_name = "notes_records_raw", table = notes_df, index = "Comment")


}

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

#' @title Classify Notes According to Experiment
#' @description User data might not have the precise word to describe a particular Comment (usually a food name). This
#' function will return a canonical version of the Comment, based on data from the Experiments table.
#' @param foodname character vector with name(s) of food item
#' @param mapping_table dataframe showing how to do the mapping.
#' @export
#' @return character vector with canonical name for the food item
classify_notes_to_experiment <- function(foodname, mapping_table) {

  if(is.null(foodname)) {
    return(NA)
  }

  foodname <- stringr::str_to_lower(foodname)
  apply_across_all <- function(x) {
    item_name <- x
    classy_table <- mapping_table
    result <- classy_table %>% filter(stringr::str_detect(item_name, pattern))
    if(nrow(result)>0) return(result[["replacement"]][1])
    else return("other")
  }


  s <- purrr::map_chr(foodname, apply_across_all)
  return(s)


}

#' @title Classify Notes According to Experiment (Tastermonial Edition)
#' @description Same results as [classify_notes_to_experiment()] but uses pre-canned Tastermonial mapping
#' @param foodname character string name of the food item
#' @return character vector with canonical name for the food item
classify_notes_to_experiment_taster <- function(foodname) {

  # a CSV file with columns `pattern` and `replacement` to convert from each format
  taster_names_convert_table <- readr::read_csv(system.file("extdata", package = "cgmrdb", "experiments_mapping.csv"),
                                                col_types = "cc") %>%
    mutate(pattern = stringr::str_to_lower(pattern))

  classify_notes_to_experiment(foodname, mapping_table = taster_names_convert_table)
}
