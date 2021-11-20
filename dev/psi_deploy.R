# deployment functions and script

Sys.getenv("R_CONFIG_ACTIVE")
Sys.setenv("R_CONFIG_ACTIVE" = "shinyapps")
Sys.setenv("R_CONFIG_ACTIVE" = "local")


# add a new `accounts_user` table if none exists in this database
deploy_add_table <- function(proposed_table = "accounts_user") {
  con <- db_connection()
  data(proposed_table)
  if (proposed_table %in% dbListTables(con)) {
    message(sprintf("Table %s already exists", proposed_table))
  }
  else {
    message(sprintf("adding new table %s", proposed_table))
    make_table_with_index(con, table_name = proposed_table, table = eval(sym(proposed_table)))
    }


  dbDisconnect(con)
}

deploy_add_table("accounts_user")
deploy_add_table(proposed_table = "accounts_firebase")
