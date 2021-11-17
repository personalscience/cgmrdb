## code to prepare `sample_glucose1` dataset goes here
glucose_df <- cgmr::glucose_df_from_libreview_csv(system.file("extdata",
                                                                   package = "cgmr",
                                                                   "Firstname2Lastname2_glucose.csv"),
                                                       user_id = 1234)


  sample_glucose1 <-   if (!("timestamp" %in% names(glucose_df))) {
    glucose_df %>% dplyr::rename("timestamp" = "time")
  } else
    glucose_df


usethis::use_data(sample_glucose1, overwrite = TRUE)
