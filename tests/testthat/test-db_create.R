
# con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
db <- cgm_db(db_config = "sqldb")
db$list_objects()

test_that("cgm_db object works",{
  expect_equal(db$list_objects()$tables, c("accounts_firebase",
                                           "accounts_user",
                                           "accounts_user_demographics",
                                           "experiments",
                                           "experiments_mapping",
                                           "glucose_records",
                                           "notes_records",
                                           "sqlite_stat1" ,
                                           "sqlite_stat4" ,
                                           "user_list"  ) )
  expect_equal(db$notes_records_df()[["Comment"]][1], "Bagel")
})

glucose_data1 <- cgmr::libreview_csv_df(system.file("extdata", package = "cgmr", "Firstname1Lastname1_glucose.csv"))
glucose_data2 <- cgmr::libreview_csv_df(system.file("extdata", package = "cgmr", "Firstname2Lastname2_glucose.csv"))

con <- db$con

test_that("First Write works", {
  expect_equal(db_write_raw_glucose_table(con, table_name = "sample_table", glucose_data1$glucose_raw ), "Wrote to table for the first time")
  expect_equal(db_write_raw_glucose_table(con, table_name = "sample_table", glucose_data1$glucose_raw ), "Already have that serial number F91A8D8B-15FF-4028-A066-F97CD2ED2660")
  expect_equal(db_write_raw_glucose_table(con, table_name = "sample_table", head(glucose_data2)$glucose_raw), "wrote 31737 records to sample_table")
})

test_that("Sample data loaded correctly", {
  expect_equal(db$table_df("accounts_firebase")$user_id[1], 1234)
})

test_that("Make a new table",{
  expect_equal(class(make_table_with_index(con, table_name = "newtable", table = tibble(a=c(1,2,3),b=c("a","b","c")))),
               c('tbl_SQLiteConnection', 'tbl_dbi', 'tbl_sql', 'tbl_lazy', 'tbl'))
})

print(tbl(con, "notes_records") %>% names())

# Clean up
db$disconnect()
if(file.exists("mydb.sqlite")){
  file.remove("mydb.sqlite")
}


