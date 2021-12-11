

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

