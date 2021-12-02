## code to prepare `accounts_firebase` dataset goes here

accounts_firebase <- readr::read_csv(system.file("extdata", package = "cgmrdb", "sample_accounts_firebase.csv"),
                                     col_types = cols(
                                       id = col_double(),
                                       user_id = col_double(),
                                       firebase_id = col_character(),
                                       created = col_datetime(),
                                       modified = col_datetime()
                                     ))
usethis::use_data(accounts_firebase, overwrite = TRUE)
