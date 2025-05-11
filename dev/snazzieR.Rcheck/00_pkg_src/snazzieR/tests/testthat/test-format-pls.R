test_that("format.pls produces clean console output for NIPALS and SVD", {
  data(iris)
  x <- as.matrix(iris[, c("Sepal.Length", "Sepal.Width")])
  y <- as.matrix(iris[, c("Petal.Length", "Petal.Width")])

  nipals.model <- NIPALS.pls(x, y, n.components = 3)
  svd.model    <- SVD.pls(x, y, n.components = 3)

  expect_invisible(format.pls(nipals.model, latex = FALSE))
  expect_invisible(format.pls(svd.model, latex = FALSE))
})
