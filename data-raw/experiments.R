## code to prepare `accounts_user` dataset goes here

experiments <- read.csv(system.file("extdata", package = "cgmrdb", "sample_experiments.csv"))
usethis::use_data(experiments, overwrite = TRUE)
