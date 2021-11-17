## code to prepare `accounts_firebase` dataset goes here

accounts_firebase <- read.csv(system.file("extdata", package = "cgmrdb", "sample_accounts_firebase.csv"))
usethis::use_data(accounts_firebase, overwrite = TRUE)
