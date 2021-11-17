## code to prepare `accounts_user` dataset goes here

accounts_user <- read.csv(system.file("extdata", package = "cgmrdb", "sample_accounts_user.csv"))
usethis::use_data(accounts_user, overwrite = TRUE)
