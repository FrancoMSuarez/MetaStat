# tests/testthat/test-fct_helpers.R
test_that("find_vars returns numeric column names", {
  df <- data.frame(a = 1:3, b = letters[1:3], c = 4:6)
  result <- find_vars(df, is.numeric)
  expect_equal(result, c("a", "c"))
})

test_that("find_vars returns character column names", {
  df <- data.frame(a = 1:3, b = letters[1:3])
  result <- find_vars(df, is.character)
  expect_equal(result, "b")
})

test_that("find_vars returns empty vector when no match", {
  df <- data.frame(a = 1:3)
  result <- find_vars(df, is.character)
  expect_length(result, 0)
})
