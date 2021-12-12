

experiment_table <- tibble(
  pattern = c("ax","B","C  m", "d"),
  replacement = c("a","b","c", "D")
) %>% mutate(pattern = stringr::str_to_lower(pattern))


test_that("Correct mapping of experiments",{
  expect_equal(classify_notes_to_experiment("C  m", experiment_table),
               "c")
  expect_equal(classify_notes_to_experiment(c("ax","b","B","d"), experiment_table),
               c("a","b","b","D"))
})

test_that("Map tastermonial experiment names",{
  expect_equal(classify_notes_to_experiment_taster("munk pack"),
               "Munk Pack")
  expect_equal(classify_notes_to_experiment_taster(c("rice krispies",
                                                     "Moon Cheese",
                                                     "clif bar",
                                                     "clif bar chocolate",
                                                     "snapeas",
                                                     "something with snapeas in it")),
               c("Kelloggs Rice Krispies",
                 "Moon Cheese",
                 "Clif Bar Chocolate",
                 "Clif Bar Chocolate",
                 "Snapeas",
                 "Snapeas"))
})

# If you want to see how well the notes data is using the `classify_notes_to_experiment_taster()` function, run this
#
# ```R
# notes_raw <- tasterdb::run_taster_notes(raw = TRUE)
# notes <- tasterdb::run_taster_notes()
# tibble(notes = notes$Comment,
#        raw = notes_raw$Comment,
#        simplified = classify_notes_to_experiment_taster(notes_raw$Comment)
# )  %>%
#   filter(notes != simplified)
#
# ```
#
