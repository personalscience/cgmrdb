
conn_args = config::get(value = "dataconnection")
conn_args
DBI::dbCanConnect(conn_args$driver,
                  host=conn_args$host,
                  user=conn_args$user,
                  password=conn_args$password,
                  port=conn_args$port,
                  dbname = conn_args$dbname)

Sys.setenv("R_CONFIG_ACTIVE"=
             "sqldb")

Sys.setenv("R_CONFIG_ACTIVE" = "sandbox")
conn_args = config::get(value = "dataconnection")
conn_args
DBI::dbCanConnect(conn_args$driver,
                  host=conn_args$host,
                  user=conn_args$user,
                  password=conn_args$password,
                  port=conn_args$port,
                  dbname = conn_args$dbname)


sandbox_db <- cgm_db(db_config = "sandbox")
local_db <- cgm_db(db_config = "local")

sql_db <- cgm_db(db_config = "sqldb")

sql_db$notes_records
sandbox_db$glucose_records %>% distinct(user_id)

# Make new notes ----

raw_notes <- tasterdb::run_taster_notes(raw = TRUE)
raw_notes2 <- cgmr::notes_df_from_glucose_table(local_db$glucose_records, user_id = 1234) %>% filter(Start>"2021-06-01")
new_notes <- bind_rows(raw_notes, raw_notes2) %>%
  mutate(Comment = map_chr(stringr::str_to_upper(Comment), tasterdb::taster_classify_food))
write_notes_raw_from_scratch(local_db$con, raw_notes)
write_notes_raw_from_scratch(sandbox_db$con, raw_notes)
write_notes_raw_from_scratch(sql_db$con, raw_notes)


DBI::dbWriteTable(local_db$con, name = "notes_records",
                  value = cgmr::notes_df_from_glucose_table(local_db$glucose_records, user_id = 1234),
                  row.names = FALSE, append = TRUE)


# Load a database from scratch ----
taster_db <- tasterdb::load_db(ps_database = "sandbox")

tasterdb::taster_classify_food("CLIF BAR CHOCOLATE CHIP")

sql_make_index <- glue::glue_sql("CREATE INDEX notes_records_Comment ON notes_records (Comment)")
sql_make_index
res <- DBI::dbSendStatement(db$con, sql_make_index)


sql <- glue::glue_sql('SELECT * FROM notes_records WHERE `user_id` > 1000;',
                      .con = sql_db$con)
sql
res <- DBI::dbSendStatement(sql_db$con, sql )
DBI::dbFetch(res)
DBI::dbClearResult(res)
