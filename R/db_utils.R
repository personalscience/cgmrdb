# general utilities to make it easier to access database functions

# Create
# Read
# Update
# Delete

#' @title make a database connection
#' @description hardcoded to look for Tastermonial db
#' @return database connection
#' @export
db_connection <- function() {
  conn_args <- config::get("dataconnection")

  con <- DBI::dbConnect(
    drv = conn_args$driver,
    user = conn_args$user,
    host = conn_args$host,
    port = conn_args$port,
    dbname = conn_args$dbname,
    password = conn_args$password
  )

  return(con)
}

#' @title Delete Rows For Specific `user_id`
#' @param con valid database connection
#' @param user_id user ID
#' @export
db_delete_user_from_table <- function (con, tablename, user_id){

  sql_query <- sprintf("DELETE FROM %1$s WHERE (%1$s.user_id = %2$s);", tablename, user_id)

  rows_affected <- DBI::dbExecute(con, sql_query)

  return(rows_affected)


}

#' @title Update All Records in `table_name` that match `user_id`
#' @param con valid database connection
#' @param user_id user ID
#' @param table_name character string name of a database table
#' @param table_df dataframe of records to substitute
#' @return integer number of rows affected
db_update_records <- function( con, user_id, table_name, table_df) {

  if(is.null(user_id)) {return(0)}


  sql_drop <- glue::glue_sql('
                           DELETE
                           FROM {`table_name`}
                           WHERE user_id IN ({user_id*})

                             ',
                             .con = con)


  query <- DBI::dbSendStatement(con, sql_drop)
  results <- DBI::dbGetRowsAffected(query)
  DBI::dbClearResult(query)

  if (results>0) {message(sprintf("User IDs replaced in %s rows",results))}
  DBI::dbWriteTable(con, table_name, table_df, append = TRUE)

  return(results)
}

