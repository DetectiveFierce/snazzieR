test_that("pls.regression correctly dispatches to SVD and NIPALS", {
  data(iris)
  x <- as.matrix(iris[, c("Sepal.Length", "Sepal.Width")])
  y <- as.matrix(iris[, c("Petal.Length", "Petal.Width")])

  svd.model <- pls.regression(x, y, n.components = 2, calc.method = "SVD")
  nipals.model <- pls.regression(x, y, n.components = 2, calc.method = "NIPALS")

  expect_type(svd.model, "list")
  expect_type(nipals.model, "list")

  expect_equal(svd.model$model.type, "PLS Regression")
  expect_equal(nipals.model$model.type, "PLS Regression")

  expect_equal(ncol(svd.model$T), 2)
  expect_equal(ncol(nipals.model$T), 2)
})
