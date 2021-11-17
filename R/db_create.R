# create_db
#
# # WARNING: Be sure you know the value of R_CONFIG_ACTIVE before using these functions.
#
# set the active configuration globally via .Renviron
# Sys.setenv(R_CONFIG_ACTIVE = "tastercloud")
#Sys.setenv(R_CONFIG_ACTIVE = "local")  # save to local postgres
# Sys.setenv(R_CONFIG_ACTIVE = "sqldb") # local sqlite
# Sys.setenv(R_CONFIG_ACTIVE = "cloud")



#' @title Initialize a database object
#' @description With this object, there is no need to keep track of database connections in order to access
#' the Tastermonial database. Once initialized, you simply use the `$` methods to pull the glucose and notes
#' records results. If the database doesn't exist, initializing this object will create it for you.
#' @param db_config string name of configuration to be used  for this instance.
#' @import DBI magrittr dplyr
#' @export
cgm_db <- function(db_config = "sqldb") {

  conn_args = config::get(value = "dataconnection", config = db_config)
  con <- DBI::dbConnect(
    drv = conn_args$driver,
    user = conn_args$user,
    host = conn_args$host,
    port = conn_args$port,
    # dbname = conn_args$dbname,
    password = conn_args$password
  )

  data("accounts_firebase")
  data("accounts_user")
  data("accounts_user_demographics")
  data("sample_glucose1")
  data("sample_notes1")

  USER_DATA_FRAME <-
    tibble(first_name = "first", last_name = "last", birthdate = as.Date("1900-01-01"), libreview_status = as.character(NA), user_id = 0)



  if (class(con) == "PqConnection"){
  newdb_sqlstring <-
    paste0(
      "CREATE DATABASE ",
      conn_args$dbname,
      "
            WITH
            OWNER = postgres
            ENCODING = 'UTF8'
            CONNECTION LIMIT = -1;"
    )

  ## Add a new database named with the value of conn_args$dbname if none exists on this server
  if (conn_args$dbname %in%
      DBI::dbGetQuery(con, "SELECT datname FROM pg_database WHERE datistemplate = false;")$datname)
  { message("database already exists")
    DBI::dbDisconnect(con)

  } else {
    DBI::dbSendQuery(con, newdb_sqlstring)
  }
  }

  con <- DBI::dbConnect(
    drv = conn_args$driver,
    user = conn_args$user,
    host = conn_args$host,
    port = conn_args$port,
    dbname = conn_args$dbname,
    password = conn_args$password
  )

    make_table_with_index(con,
                              table_name = "glucose_records",
                              table = sample_glucose1,
                              index = "timestamp")
    make_table_with_index(con,
                              table_name = "notes_records",
                              table = sample_notes1,
                              index = "Comment")
    make_table_with_index(con,
                              table_name = "user_list",
                              table = USER_DATA_FRAME,
                              index = "user_id")

    make_table_with_index(con,
                          table_name = "accounts_user",
                          table = accounts_user,
                          index = "user_id")
    make_table_with_index(con,
                          table_name = "accounts_firebase",
                          table = accounts_firebase,
                          index = "user_id")
    make_table_with_index(con,
                          table_name = "accounts_user_demographics",
                          table = accounts_user_demographics,
                          index = "user_id")


  thisEnv <- environment()


  db <- list(
    thisEnv = thisEnv,
    con = con,
    disconnect = function() {
      DBI::dbDisconnect(con)
    },
    glucose_records = dplyr::tbl(con, "glucose_records"),
    notes_records = dplyr::tbl(con, "notes_records"),
    notes_records_df = function() {
      collect(tbl(con, "notes_records")) %>% mutate(Start = lubridate::as_datetime(Start),
                                                    End = lubridate::as_datetime(End))
    },
    list_objects = function() {
      dbName <- conn_args$dbname
      dbHost <- conn_args$host

      objects <- DBI::dbListObjects(con)
      tables <- DBI::dbListTables(con)
      return(list(dbName=dbName, dbHost=dbHost, objects=objects, tables=tables))
    },
    #' @describeIn  table_df returns a valid table
    table_df = function(table_name = "glucose_records") {
      dplyr::collect(dplyr::tbl(con, table_name))
    }
  )



  ## Define the value of the list within the current environment.
  assign('this',db,envir=thisEnv)

  structure(db, class = "data.frame",
            con  = con )

}


#' @title Create or delete a new database as required
#' @description Intended for situations where you want to start all over,
#' this function will use direct SQL calls to either create a brand new database
#' or, if optionally `drop=TRUE`, wipe out any existing database.
#' IMPORTANT: database connection is dropped regardless, so if you need a connection,
#' be sure reconnect.
#' @param conn_args connection
#' @param db_name character string name for proposed new database
#' @param drop Nuke a database with this name if it already exists (default = `FALSE`)
#' @param force override the warning about creating a database with the magic name `qsdb` (default = `FALSE`)
make_new_database_if_necessary <- function(conn_args = config::get("dataconnection"),
                                           db_name,
                                           drop = FALSE,
                                           force = FALSE) {


  if(db_name=="qsdb") {
    message("are you absolutely certain?")
    message("I won't let you do this unless you call with the flag `force=TRUE`")

    return(NULL)
  }

  if(class(conn_args$driver) == "SQLiteDriver") {
    con <- DBI::dbConnect(
      drv = conn_args$driver,
      dbname = conn_args$dbname
    )
    return(con)
  }
  con <- DBI::dbConnect(
    drv = conn_args$driver,
    user = conn_args$user,
    host = conn_args$host,
    port = conn_args$port,
    # dbname = conn_args$dbname,
    password = conn_args$password
  )


  new_db_sql <-
    sprintf(
      "CREATE DATABASE %s WITH OWNER = %s ENCODING = 'UTF8' CONNECTION LIMIT = -1;",
      db_name,
      "postgres"
    )

  nuke_db_sql <-  sprintf(
    "DROP DATABASE IF EXISTS %s;",
    db_name
  )

  if (db_name %in% DBI::dbGetQuery(con,
                                  "SELECT datname FROM pg_database WHERE datistemplate = false;")$datname)
  {    message(sprintf("found database %s", db_name))
    if (drop) {

      message(sprintf("Nuking %s",  db_name))
      rs <- DBI::dbSendStatement(con, nuke_db_sql)
      DBI::dbClearResult(rs)
    }
    else  message(sprintf("But I'll do nothing about it"))

  }
  else   {message(sprintf("no database named %s", db_name))
    if (drop) {
      message(sprintf("I'll make a new one named %s", db_name))
      rs <- DBI::dbSendStatement(con, new_db_sql)
      DBI::dbClearResult(rs)
    }
  }
  DBI::dbDisconnect(con)
}


#' @title Write a table to the database
#' @param con valid database connection
#' @param table_name char string for table name
#' @param table_df valid dataframe to write to the database
#' @return character string with a message that can be displayed to the user
db_write_raw_glucose_table <- function(con, table_name = "raw_glucose", table_df) {

  msg <- "Nothing to write"
  if (DBI::dbExistsTable(con, table_name)) {
    # check that you're not adding another copy of the same table
    sn <- first(unique(table_df$serial_number))
    if(nrow(tbl(con, table_name) %>% filter(.data[["serial_number"]] == sn) %>% collect()) > 0){
      message(sprintf("Already have that serial number %s", sn))
      msg <- sprintf("Already have that serial number %s", sn)
      return(msg)
    } else {
      message(sprintf("writing %d rows to table %s",nrow(table_df), table_name))
      msg <- sprintf("wrote %d records to %s",nrow(table_df), table_name)
      DBI::dbAppendTable(con, table_name, table_df)
    }

  } else {


    DBI::dbWriteTable(con, table_name, table_df)
    msg <- "Wrote to table for the first time"
  }

  return(msg)

}
#' @title Make a new database tables with `index`
#' @param con valid database connection
#' @param table_name character string name for the table.
#' @param table a valid glucose data frame. Never use the default value unless you are testing.
#' @param index (list) table column to be used for index
#' @import DBI
#' @return NULL if table already exists. Otherwise creates the table and returns TRUE invisibly.
make_table_with_index <- function(con,
                                      table_name = "experiments",
                                      table = NULL, # a dataframe
                                      index = NULL
                                      ){

  if (DBI::dbExistsTable(con, table_name))
  {message(paste0("Table '",table_name,"' already exists"))
  } else {

    message(sprintf("Writing new table %s with index %s", table_name, index))
    # Lets you create an index
    dplyr::copy_to(con, df = table, name = table_name, index = index, temporary = FALSE)
  }

}
