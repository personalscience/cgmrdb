## code to prepare `accounts_user_demographics` dataset goes here
accounts_user_demographics <- read.csv(system.file("extdata", package = "cgmrdb", "sample_accounts_user_demographics.csv"))

usethis::use_data(accounts_user_demographics, overwrite = TRUE)
