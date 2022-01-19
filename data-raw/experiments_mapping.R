# experiments map

experiments_mapping <- readr::read_csv(system.file("extdata", package = "cgmrdb", "experiments_mapping.csv"),
                                     col_types = cols(
                                       pattern = col_character(),
                                       replacement = col_character()
                                     ))

usethis::use_data(experiments_mapping, overwrite = TRUE)
