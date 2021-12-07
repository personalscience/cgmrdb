

experiment_table <- tibble(
  label = c("ax","B","C  m", "d"),
  simpleName = c("a","b","c", "D")
)

exp_patterns <- readr::read_csv("experiment_map.csv") %>% filter(stringr::str_detect(replacement, pattern))
print(exp_patterns)
experiment_patterns <- tibble(
  pattern = c("clif(\\s)*bar(\\s*\\w*)"),
  replacement = c("Clif Bar Chocolate")
)

test_that("Correct mapping of experiments",{
  expect_equal(classify_notes_to_experiment("C  m", experiment_table),
               "c")
  expect_equal(classify_notes_to_experiment(c("ax","b","B","d"), experiment_table),
               c("a","b","b","D"))
})

