## code to prepare `sample_notes1` dataset goes here
sample_notes1 <- cgmr::notes_df_from_csv(system.file("extdata",
                                                     package = "cgmr",
                                                     "Firstname2Lastname2_notes.csv"),
                                         user_id = 1234)
usethis::use_data(sample_notes1, overwrite = TRUE)
