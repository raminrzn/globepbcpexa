# Cases entered in the official calculator (globalpbc.com/globe, 13 November
# 2026): age, bilirubin, bilirubin ULN, ALP, ALP ULN, albumin, albumin LLN,
# platelets; shown score (2 decimals) and survival % at 3, 5, 10, 15 years.
web <- list(
  list(c(50, 17, 17, 360, 120, 45, 30, 250), c(-0.24, 97.3, 95.1, 87.4, 78.6)),
  list(c(70, 17, 17, 360, 120, 45, 30, 250), c(0.65, 93.5, 88.6, 72.2, 55.7)),
  list(c(35, 8, 21, 90, 115, 44, 35, 320), c(-1.89, 99.5, 99.1, 97.5, 95.5)),
  list(c(62, 40, 17, 600, 130, 32, 35, 120), c(2.90, 52.4, 31.4, 4.4, 0.4)),
  list(c(45, 1.2, 1.0, 200, 104, 40, 34, 180), c(0.47, 94.5, 90.3, 76.0, 61.1)),
  list(c(78, 3.4, 1.2, 450, 120, 30, 35, 90), c(3.93, 16.6, 4.0, 0.0, 0.0)),
  list(c(55, 12, 20, 150, 150, 38, 35, 400), c(-0.32, 97.5, 95.5, 88.3, 80.0)),
  list(c(41, 25, 21, 980, 115, 36, 35, 150), c(1.20, 88.9, 81.0, 56.7, 36.1)),
  list(c(66, 60, 17, 300, 120, 28, 35, 70), c(3.64, 25.8, 8.8, 0.1, 0.0)),
  list(c(52, 0.6, 1.2, 130, 120, 42, 35, 260), c(-0.49, 97.9, 96.2, 90.1, 82.9)),
  list(c(58, 20, 17, 250, 120, 40.5, 35, 210), c(1.02, 90.6, 83.8, 62.1, 42.6)))

run <- function(v) globe_score(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8])

test_that("results equal the official GLOBE calculator (11 cases)", {
  # Low to very high risk, bilirubin in umol/L and mg/dL. The calculator shows
  # the score to 2 decimals and survival to 0.1%.
  for (w in web) {
    r <- run(w[[1]])
    expect_equal(round(r$globe_score, 2), w[[2]][1],
                 info = paste(w[[1]], collapse = " "))
    expect_equal(unname(round(100 * unlist(r$transplant_free_survival), 1)), w[[2]][2:5],
                 info = paste(w[[1]], collapse = " "))
  }
})

test_that("the paper's worked example", {
  # The manuscript gives age 50, bilirubin 1 x ULN, ALP 3 x ULN, albumin
  # 1.5 x LLN and platelets 250, and prints score 0.64, S(5) 88.6% and S(10)
  # 72.2%. Its equation gives -0.24, 95.1% and 87.4% for these inputs, as does
  # the official calculator; the printed results match age 70 instead.
  r50 <- globe_score(50, 1, 1, 3, 1, 1.5, 1, 250)
  expect_equal(round(r50$globe_score, 2), -0.24)
  r70 <- globe_score(70, 1, 1, 3, 1, 1.5, 1, 250)
  expect_equal(round(100 * r70$transplant_free_survival$year_5, 1), 88.6)
  expect_equal(round(100 * r70$transplant_free_survival$year_10, 1), 72.2)
})

test_that("coefficients agree with the paper's Table 2 hazard ratios", {
  # Multivariable HRs: age 1.045/year, bilirubin 2.560, ALP 1.399 (per ln
  # unit), albumin 0.104 per x LLN. Platelets are printed as 0.970 per 10
  # units, but its CI (0.961-0.990) is centred on 0.975 = exp(-0.02581).
  expect_equal(round(exp(c(0.044378, 0.93982, 0.335648, -2.266708)), 3),
               c(1.045, 2.560, 1.399, 0.104))
  expect_equal(round(exp(10 * -0.002581), 3), round(exp(mean(log(c(0.961, 0.990)))), 3))
})

test_that("units: only ratios matter for bilirubin, ALP and albumin", {
  a <- globe_score(60, 17.1, 17.1, 240, 120, 38, 35, 200)
  b <- globe_score(60, 1, 1, 2, 1, 38 / 35, 1, 200)
  c <- globe_score(60, "1,0", "1,0", 2, 1, 38 / 35, 1, 200)
  expect_equal(a$globe_score, b$globe_score)
  expect_equal(c$globe_score, b$globe_score)
})

test_that("inputs are checked", {
  expect_error(globe_score(10, 1, 1, 1, 1, 1, 1, 200), "age")
  expect_error(globe_score(50, 0, 1, 1, 1, 1, 1, 200), "bilirubin")
  expect_error(globe_score(50, 1, 1, 1, 1, 1, 1, 0), "platelets")
  expect_error(model_run(list(age = 50)), "argument")
})

test_that("gateway returns full precision", {
  g <- jsonlite::fromJSON(gateway(model_input = get_default_input()))
  r <- do.call(globe_score, get_default_input())
  expect_equal(g$globe_score, r$globe_score, tolerance = 1e-13)
  expect_equal(g$transplant_free_survival$year_10, r$transplant_free_survival$year_10, tolerance = 1e-13)
})
