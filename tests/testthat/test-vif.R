quiet <- function(expr) withr::with_output_sink(tempfile(), expr)

test_that("VIF.table matches 1 / (1 - R^2_j) for numeric predictors", {
  m <- lm(mpg ~ wt + hp + disp + qsec, data = mtcars)
  out <- quiet(VIF.table(m, latex = FALSE))
  expect_named(out, c("Term", "VIF", "1/VIF", "GVIF", "adj. GVIF", "Flag"))
  preds <- c("wt", "hp", "disp", "qsec")
  manual <- vapply(preds, function(v) {
    r2 <- summary(lm(reformulate(setdiff(preds, v), v), data = mtcars))$r.squared
    1 / (1 - r2)
  }, numeric(1))
  manual <- sort(manual, decreasing = TRUE) # rows are ordered highest VIF first
  expect_equal(out$Term, names(manual))
  expect_equal(out$VIF, unname(manual))
  expect_equal(out$`1/VIF`, 1 / unname(manual))
  expect_equal(out$GVIF, unname(manual)) # one-df terms: GVIF = VIF
  expect_equal(out$`adj. GVIF`, sqrt(unname(manual)))
  expect_equal(out$Flag, ifelse(manual > 10, "severe", ifelse(manual > 5, "moderate", "")), ignore_attr = TRUE)
})

test_that("multi-df terms get generalized VIFs and VIF = adj. GVIF^2", {
  m <- lm(mpg ~ wt + factor(cyl) + qsec, data = mtcars)
  out <- quiet(VIF.table(m, latex = FALSE))
  expect_equal(out$VIF, out$`adj. GVIF`^2)
  expect_false(is.unsorted(rev(out$VIF)))
  cyl <- out$Term == "factor(cyl)"
  expect_equal(out$`adj. GVIF`[cyl], out$GVIF[cyl]^(1 / 4))
  wt.r2 <- summary(lm(model.matrix(m)[, "wt"] ~ model.matrix(m)[, -(1:2)]))$r.squared
  expect_equal(out$GVIF[out$Term == "wt"], 1 / (1 - wt.r2))
  expect_output(VIF.table(m, latex = FALSE), "For multi-df terms, VIF = (adj. GVIF)^2", fixed = TRUE)
  expect_output(VIF.table(m, latex = FALSE), "(df = 2)", fixed = TRUE)
  expect_match(VIF.table(m), "(df = 1)", fixed = TRUE)
  expect_type(out$`adj. GVIF`, "double") # returned values stay numeric
})

test_that("cols picks columns; Term and Flag are always shown", {
  m <- lm(mpg ~ wt + hp + disp, data = mtcars)
  out <- quiet(VIF.table(m, latex = FALSE, cols = c("1/VIF", "VIF")))
  expect_named(out, c("Term", "VIF", "1/VIF", "Flag"))
  expect_error(VIF.table(m, cols = "Most Correlated With"), "Unknown")
  expect_named(quiet(VIF.table(m, latex = FALSE, cols = "GVIF")), c("Term", "GVIF", "Flag"))
  tbl <- VIF.table(m, cols = c("VIF", "1/VIF"))
  expect_match(tbl, "1/VIF", fixed = TRUE)
  expect_no_match(tbl, "GVIF", fixed = TRUE)
  expect_error(VIF.table(m, cols = c("VIF", "Tolerance")), "Unknown: \"Tolerance\"")
})

test_that("aliased coefficients are dropped and reported; too few terms errors", {
  expect_output(
    out <- VIF.table(lm(mpg ~ wt + hp + I(2 * wt), data = mtcars), latex = FALSE),
    "Aliased .* I\\(2 \\* wt\\)"
  )
  expect_setequal(out$Term, c("wt", "hp"))
  expect_error(VIF.table(lm(mpg ~ wt, data = mtcars)), "at least two terms")
  expect_error(VIF.table(list()), "lm\\(\\) or glm\\(\\)")
})

test_that("VIF.table works for glm and returns a previewable LaTeX table", {
  g <- suppressWarnings(glm(am ~ wt + hp, data = mtcars, family = binomial))
  expect_equal(nrow(quiet(VIF.table(g, latex = FALSE))), 2)

  d <- data.frame(y = mtcars$mpg, wt_lbs = mtcars$wt, hp = mtcars$hp, disp = mtcars$disp)
  tbl <- VIF.table(lm(y ~ wt_lbs + hp + disp, data = d), title = "Collinearity")
  expect_s3_class(tbl, "snazzieR_table")
  expect_match(tbl, "wt\\_lbs", fixed = TRUE)
  expect_match(tbl, "\\textbf{Collinearity}", fixed = TRUE)

  # severe rows are flagged but their values are not bolded
  sev <- VIF.table(lm(mpg ~ wt + hp + disp + cyl, data = mtcars))
  expect_match(sev, "severe", fixed = TRUE)
  sev.lines <- grep("severe", strsplit(sev, "\n")[[1]], value = TRUE)
  n.bold <- lengths(regmatches(sev.lines, gregexpr("\\textbf", sev.lines, fixed = TRUE)))
  expect_true(all(n.bold == 1)) # only the term name is bold
  withr::local_options(snazzieR.preview = "text")
  expect_output(print(tbl), "Collinearity")
})

test_that("LaTeX notes do not rely on the font encoding for > signs", {
  tbl <- VIF.table(lm(mpg ~ wt + hp, data = mtcars))
  expect_match(tbl, "VIF \\textgreater{} 5", fixed = TRUE)
})
