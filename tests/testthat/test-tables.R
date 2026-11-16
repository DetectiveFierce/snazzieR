test_that("model.summary.table returns a previewable LaTeX table", {
  m <- lm(mpg ~ wt + hp, data = mtcars)
  tbl <- model.summary.table(m, title = "Cars")
  expect_s3_class(tbl, "snazzieR_table")
  expect_s3_class(tbl, "knitr_kable")
  expect_equal(length(tbl), 1L)
  expect_match(tbl, "\\caption{", fixed = TRUE)

  withr::local_options(snazzieR.preview = "text")
  expect_output(print(tbl), "== Cars")

  withr::local_options(snazzieR.preview = "latex")
  expect_output(print(tbl), "\\begin{table}", fixed = TRUE)
})

test_that("transformed responses produce a single caption", {
  m <- lm(log(mpg) ~ wt + hp, data = mtcars)
  tbl <- model.summary.table(m, title = "Log model")
  expect_equal(lengths(regmatches(tbl, gregexpr("\\caption{", tbl, fixed = TRUE))), 1L)
  expect_match(tbl, "\\widehat{\\log\\left(\\text{mpg}\\right)}", fixed = TRUE)
  expect_output(model.equation(m, latex = FALSE), "log(mpg) = ", fixed = TRUE)
})

test_that("knit_print outside of knitting falls back to the preview", {
  m <- lm(mpg ~ wt, data = mtcars)
  withr::local_options(snazzieR.preview = "text")
  expect_output(knitr::knit_print(ANOVA.summary.table(m)), "ANOVA Summary")
})

test_that("HTML preview builds for multi-table summaries", {
  p <- pls.regression(mtcars[, c("wt", "hp")], mtcars[, "mpg", drop = FALSE], n.components = 2)
  html <- snazzieR:::snazzieR_preview_html(pls.summary(p, include.scores = FALSE))
  expect_match(as.character(html), "X Weights (W)", fixed = TRUE)
})

test_that("title is the caption and the equation sits on its own line", {
  m <- lm(mpg ~ wt + hp, data = mtcars)
  tbl <- model.summary.table(m, title = "Cars")
  expect_match(tbl, "\\caption{\\textbf{Cars}}", fixed = TRUE)
  eq.pos <- regexpr("$\\widehat{", tbl, fixed = TRUE)
  expect_true(eq.pos > regexpr("\\caption{", tbl, fixed = TRUE))
  expect_true(eq.pos < regexpr("\\begin{threeparttable}", tbl, fixed = TRUE))
})

test_that("the old `caption` argument still works as an alias for `title`", {
  m <- lm(mpg ~ wt, data = mtcars)
  expect_equal(
    unclass(model.summary.table(m, caption = "Old")),
    unclass(model.summary.table(m, title = "Old"))
  )
  expect_equal(
    unclass(ANOVA.summary.table(m, caption = "Old")),
    unclass(ANOVA.summary.table(m, title = "Old"))
  )
  cm <- cov(mtcars[, 1:2])
  expect_equal(unclass(eigen.summary(cm, caption = "Old")), unclass(eigen.summary(cm, title = "Old")))
})

test_that("ANOVA rows without a test get no significance code", {
  m <- lm(mpg ~ wt + hp, data = mtcars)
  out <- NULL
  expect_output(out <- ANOVA.summary.table(m, latex = FALSE))
  expect_equal(out$Signif.[out$Term == "Residuals"], "")
  expect_equal(out$Signif.[out$Term == "wt"], ":3")
})

test_that("console model summary has no padding rows", {
  m <- lm(mpg ~ wt, data = mtcars)
  txt <- capture.output(model.summary.table(m, latex = FALSE))
  coef.block <- txt[seq(grep("Coefficient Table", txt), grep("Model Statistics", txt))]
  expect_equal(sum(grepl("^(\\(Intercept\\)|wt) ", coef.block)), 2L)
  expect_false(any(grepl("^[0-9]+ +$", coef.block)))
})

test_that("significance footnote uses less-than signs", {
  m <- lm(mpg ~ wt, data = mtcars)
  expect_match(model.summary.table(m), "$<$0.001", fixed = TRUE)
  expect_match(ANOVA.summary.table(m), "$<$0.001", fixed = TRUE)
})
