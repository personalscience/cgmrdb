# general utilities to make it easier to access database functions

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
