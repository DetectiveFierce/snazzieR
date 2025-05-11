test_that("SVD.pls produces valid output on iris data", {
  data(iris)
  x <- as.matrix(iris[, c("Sepal.Length", "Sepal.Width")])
  y <- as.matrix(iris[, c("Petal.Length", "Petal.Width")])

  model <- SVD.pls(x, y, n.components = 2)

  expect_type(model, "list")
  expect_equal(model$model.type, "PLS Regression")
  expect_equal(ncol(model$T), 2)
  expect_equal(ncol(model$coefficients), 2)
  expect_equal(nrow(model$coefficients), 2)
  expect_true(all(model$X_explained > 0))
  expect_true(all(model$Y_explained >= 0))
})
