

con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")


glucose_data1 <- cgmr::glucose_df_from_libreview_csv(system.file("extdata", package = "cgmr", "Firstname1Lastname1_glucose.csv"),
                                        user_id = 75)
glucose_data2 <- cgmr::glucose_df_from_libreview_csv(system.file("extdata", package = "cgmr", "Firstname2Lastname2_glucose.csv"),
                                        user_id = 99)


make_table_with_index(con, table_name = "glucose_records", table = rbind(glucose_data1, glucose_data2), index = "user_id")


test_that("db_delete_user_from_table",{
  expect_equal(db_delete_user_from_table(con, "glucose_records", user_id = 99),31737)
  expect_equal(tbl(con, "glucose_records") %>% filter(user_id == 75) %>% count()  %>% pull(n), 3984)
})



DBI::dbDisconnect(con)
