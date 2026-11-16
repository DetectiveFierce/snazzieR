quiet <- function(expr) withr::with_output_sink(tempfile(), expr)

test_that("unusual.points.table flags exactly the points beyond the cutoffs", {
  m <- lm(mpg ~ wt + hp, data = mtcars)
  out <- withr::with_output_sink(tempfile(), unusual.points.table(m, latex = FALSE))
  n <- nobs(m)
  k <- length(coef(m))
  h <- hatvalues(m)
  r <- rstandard(m)
  d <- cooks.distance(m)
  expected <- names(which(h > 2 * k / n | abs(r) > 2 | d > 4 / (n - 2)))
  expect_setequal(out$Obs, expected)
  expect_equal(out$Obs, expected[order(-d[expected])]) # sorted by Cook's distance
  expect_equal(out$Leverage, unname(h[out$Obs]))
  expect_equal(out$`Std. Resid.`, unname(r[out$Obs]))
  expect_equal(out$`Cook's D`, unname(d[out$Obs]))
  expect_equal(attr(out, "cutoffs")[["leverage"]], 2 * k / n)

  expect_false(any(c("Stud. Resid.", "Most Extreme Predictor") %in% names(out)))
  expect_false("Bonf. p" %in% names(out))

  # Bad leverage = high leverage and outlier
  bad <- out$Obs[h[out$Obs] > 2 * k / n & abs(r[out$Obs]) > 2]
  expect_true(all(grepl("bad leverage", out$Flags[out$Obs %in% bad])))
})

test_that("cutoffs can be changed and the ID column is filled from data", {
  d <- data.frame(y = mtcars$mpg, x = mtcars$wt, who = rownames(mtcars))
  m <- lm(y ~ x, data = d)
  out <- withr::with_output_sink(tempfile(), unusual.points.table(
    m, latex = FALSE, id = "who", residual.cutoff = 1.5, cook.cutoff = 1, leverage.cutoff = 1
  ))
  expect_setequal(out$Obs, names(which(abs(rstandard(m)) > 1.5)))
  expect_equal(out$ID, d$who[as.integer(out$Obs)])
  expect_error(unusual.points.table(m, id = "nope", data = d), "Could not find column")
})

test_that("weighted, NA and glm fits are handled", {
  mw <- lm(mpg ~ wt + hp, data = mtcars, weights = rep(c(1, 2, 0, 1), 8))
  ow <- withr::with_output_sink(tempfile(), unusual.points.table(mw, latex = FALSE))
  expect_false(any(ow$Obs %in% rownames(mtcars)[weights(mw) == 0]))

  ma <- lm(Ozone ~ Wind + Temp, data = airquality, na.action = na.exclude)
  oa <- withr::with_output_sink(tempfile(), unusual.points.table(ma, latex = FALSE))
  expect_false(anyNA(oa$Leverage))

  mg <- glm(am ~ wt, data = mtcars, family = binomial)
  og <- withr::with_output_sink(tempfile(), unusual.points.table(mg, latex = FALSE))
  expect_true(nrow(og) > 0)
  expect_error(unusual.points.table(list()), "lm\\(\\) or glm\\(\\)")
})

test_that("LaTeX output is a previewable table with escaped labels", {
  d <- data.frame(y = mtcars$mpg, x_var = mtcars$wt, who = paste0(rownames(mtcars), " & co_"))
  tbl <- unusual.points.table(lm(y ~ x_var, data = d), id = "who")
  expect_s3_class(tbl, "snazzieR_table")
  expect_no_match(tbl, "$t_i$", fixed = TRUE)
  expect_no_match(tbl, "Most extreme", fixed = TRUE)
  expect_match(tbl, "\\& co\\_", fixed = TRUE)
  expect_match(tbl, "\\begin{minipage}{\\linewidth}\\centering", fixed = TRUE)
  expect_match(tbl, "\\textbf{Flags:}", fixed = TRUE)
  expect_match(tbl, "\\textbf{Outliers:}", fixed = TRUE)
  withr::local_options(snazzieR.preview = "text")
  expect_output(print(tbl), "Unusual Observations")
})

test_that("a model with no unusual points says so", {
  set.seed(1)
  d <- data.frame(x = 1:20)
  d$y <- d$x + rnorm(20, sd = 0.01)
  out <- withr::with_output_sink(tempfile(), unusual.points.table(
    lm(y ~ x, data = d), latex = FALSE, residual.cutoff = 10, leverage.cutoff = 1, cook.cutoff = 10
  ))
  expect_equal(nrow(out), 0)
  expect_output(unusual.points.table(lm(y ~ x, data = d), latex = FALSE, residual.cutoff = 10,
                                     leverage.cutoff = 1, cook.cutoff = 10), "No observations")
})

test_that("n.max limits the rows (default: no limit) and flag picks the criteria", {
  m <- lm(mpg ~ wt + hp, data = mtcars)
  all.rows <- quiet(unusual.points.table(m, latex = FALSE))
  expect_null(formals(unusual.points.table)$n.max)
  expect_equal(attr(all.rows, "n.flagged"), nrow(all.rows))

  top2 <- quiet(unusual.points.table(m, latex = FALSE, n.max = 2))
  expect_equal(top2$Obs, all.rows$Obs[1:2])
  expect_equal(attr(top2, "n.flagged"), nrow(all.rows))
  expect_output(unusual.points.table(m, latex = FALSE, n.max = 2), "Showing the 2 with the largest")
  expect_match(unusual.points.table(m, n.max = 2), "\\textbf{Shown:}", fixed = TRUE)
  expect_no_match(unusual.points.table(m), "\\textbf{Shown:}", fixed = TRUE)

  no.cook <- quiet(unusual.points.table(m, latex = FALSE, flag = c("leverage", "outlier")))
  h <- hatvalues(m)
  r <- rstandard(m)
  expect_setequal(no.cook$Obs, names(which(h > 2 * 3 / 32 | abs(r) > 2)))
  expect_false(any(grepl("influential", no.cook$Flags)))
  expect_error(unusual.points.table(m, flag = "nope"))
  expect_error(unusual.points.table(m, n.max = -1), "n.max")
})

test_that("the legend shows the default leverage cutoff's formula", {
  m <- lm(mpg ~ wt + hp, data = mtcars)
  expect_match(unusual.points.table(m), "0.188 = \\frac{2(3)}{32} = \\frac{2(p+1)}{n}", fixed = TRUE)
  expect_output(unusual.points.table(m, latex = FALSE), "h > 0.188 = 2(3)/32 = 2(p+1)/n", fixed = TRUE)
  expect_no_match(unusual.points.table(m, leverage.cutoff = 0.3), "frac{2(p+1)}{n}", fixed = TRUE)
})
