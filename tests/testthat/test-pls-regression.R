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

test_that("pls.regression mathematical consistency between algorithms", {
  set.seed(123)
  X <- matrix(rnorm(50 * 4), 50, 4)
  Y <- matrix(rnorm(50 * 2), 50, 2)

  svd.model <- pls.regression(X, Y, n.components = 3, calc.method = "SVD")
  nipals.model <- pls.regression(X, Y, n.components = 3, calc.method = "NIPALS")

  # Both algorithms should produce the same number of components
  expect_equal(ncol(svd.model$T), ncol(nipals.model$T))
  expect_equal(ncol(svd.model$W), ncol(nipals.model$W))
  expect_equal(ncol(svd.model$C), ncol(nipals.model$C))

  # Both should have the same dimensions for all matrices
  expect_equal(dim(svd.model$T), dim(nipals.model$T))
  expect_equal(dim(svd.model$U), dim(nipals.model$U))
  expect_equal(dim(svd.model$W), dim(nipals.model$W))
  expect_equal(dim(svd.model$C), dim(nipals.model$C))
  expect_equal(dim(svd.model$coefficients), dim(nipals.model$coefficients))

  # Both should have the same number of explained variance components
  expect_equal(length(svd.model$X_explained), length(nipals.model$X_explained))
  expect_equal(length(svd.model$Y_explained), length(nipals.model$Y_explained))

  # Both should have the same number of B_vector elements
  expect_equal(length(svd.model$B_vector), length(nipals.model$B_vector))
})

test_that("pls.regression algorithm comparison on structured data", {
  set.seed(456)
  n <- 40
  p <- 3
  q <- 2

  # Create structured data with known relationships
  X <- matrix(rnorm(n * p), n, p)
  Y <- matrix(0, n, q)

  # Create a linear relationship
  Y[, 1] <- 2 * X[, 1] + 0.5 * X[, 2] + rnorm(n, 0, 0.1)
  Y[, 2] <- -1 * X[, 1] + 1.5 * X[, 3] + rnorm(n, 0, 0.1)

  svd.model <- pls.regression(X, Y, n.components = 2, calc.method = "SVD")
  nipals.model <- pls.regression(X, Y, n.components = 2, calc.method = "NIPALS")

  # Both algorithms should capture similar variance
  expect_true(abs(sum(svd.model$X_explained) - sum(nipals.model$X_explained)) < 5)
  expect_true(abs(sum(svd.model$Y_explained) - sum(nipals.model$Y_explained)) < 5)

  # Both should have similar coefficient magnitudes
  expect_true(all(abs(svd.model$coefficients) > 0))
  expect_true(all(abs(nipals.model$coefficients) > 0))

  # Both should have non-zero B_vector values
  expect_true(all(svd.model$B_vector != 0))
  expect_true(all(nipals.model$B_vector != 0))
})

test_that("pls.regression handles different component specifications", {
  set.seed(789)
  X <- matrix(rnorm(30 * 3), 30, 3)
  Y <- matrix(rnorm(30 * 2), 30, 2)

  # Test with explicit number of components
  model1 <- pls.regression(X, Y, n.components = 2, calc.method = "SVD")
  model2 <- pls.regression(X, Y, n.components = 2, calc.method = "NIPALS")

  expect_equal(ncol(model1$T), 2)
  expect_equal(ncol(model2$T), 2)

  # Test with NULL components (should use rank)
  model3 <- pls.regression(X, Y, n.components = NULL, calc.method = "SVD")
  model4 <- pls.regression(X, Y, n.components = NULL, calc.method = "NIPALS")

  rank_X <- qr(X)$rank
  expect_equal(ncol(model3$T), rank_X)
  expect_equal(ncol(model4$T), rank_X)

  # Test with more components than rank
  model5 <- pls.regression(X, Y, n.components = 5, calc.method = "SVD")
  model6 <- pls.regression(X, Y, n.components = 5, calc.method = "NIPALS")

  expect_equal(ncol(model5$T), rank_X)
  expect_equal(ncol(model6$T), rank_X)
})

test_that("pls.regression mathematical properties are preserved", {
  set.seed(321)
  X <- matrix(rnorm(25 * 4), 25, 4)
  Y <- matrix(rnorm(25 * 2), 25, 2)

  svd.model <- pls.regression(X, Y, n.components = 3, calc.method = "SVD")
  nipals.model <- pls.regression(X, Y, n.components = 3, calc.method = "NIPALS")

  # Check that both algorithms produce orthogonal scores
  for (model in list(svd.model, nipals.model)) {
    T_cross <- crossprod(model$T)
    expect_true(all(abs(T_cross[upper.tri(T_cross)]) < 1e-10))
    expect_true(all(abs(T_cross[lower.tri(T_cross)]) < 1e-10))

    # Check that weights are normalized
    for (h in seq_len(ncol(model$W))) {
      expect_equal(sum(model$W[, h]^2), 1, tolerance = 1e-10)
    }

    for (h in seq_len(ncol(model$C))) {
      expect_equal(sum(model$C[, h]^2), 1, tolerance = 1e-10)
    }

    # Check that scores are normalized
    for (h in seq_len(ncol(model$T))) {
      expect_equal(sum(model$T[, h]^2), 1, tolerance = 1e-10)
    }
  }
})

test_that("pls.regression prediction consistency", {
  set.seed(654)
  X <- matrix(rnorm(35 * 3), 35, 3)
  Y <- matrix(rnorm(35 * 2), 35, 2)

  svd.model <- pls.regression(X, Y, n.components = 2, calc.method = "SVD")
  nipals.model <- pls.regression(X, Y, n.components = 2, calc.method = "NIPALS")

  # Both models should produce predictions with correct dimensions
  X_scaled <- scale(X, center = TRUE, scale = TRUE)

  y_pred_svd <- X_scaled %*% svd.model$coefficients
  y_pred_nipals <- X_scaled %*% nipals.model$coefficients

  expect_equal(dim(y_pred_svd), dim(Y))
  expect_equal(dim(y_pred_nipals), dim(Y))

  # Both should have finite predictions
  expect_true(all(is.finite(y_pred_svd)))
  expect_true(all(is.finite(y_pred_nipals)))

  # Both should have zero intercepts
  expect_true(all(svd.model$intercept == 0))
  expect_true(all(nipals.model$intercept == 0))
})

test_that("pls.regression variance explanation properties", {
  set.seed(987)
  X <- matrix(rnorm(45 * 4), 45, 4)
  Y <- matrix(rnorm(45 * 2), 45, 2)

  svd.model <- pls.regression(X, Y, n.components = 3, calc.method = "SVD")
  nipals.model <- pls.regression(X, Y, n.components = 3, calc.method = "NIPALS")

  for (model in list(svd.model, nipals.model)) {
    # Check that explained variance is non-negative
    expect_true(all(model$X_explained >= 0))
    expect_true(all(model$Y_explained >= 0))

    # Check that cumulative explained variance is non-decreasing
    expect_true(all(diff(model$X_cum_explained) >= 0))
    expect_true(all(diff(model$Y_cum_explained) >= 0))

    # Check that cumulative explained variance doesn't exceed 100%
    expect_true(all(model$X_cum_explained <= 100))
    expect_true(all(model$Y_cum_explained <= 100))

    # Check that the last cumulative value equals the sum of individual values
    expect_equal(model$X_cum_explained[length(model$X_cum_explained)],
      sum(model$X_explained),
      tolerance = 1e-10
    )
    expect_equal(model$Y_cum_explained[length(model$Y_cum_explained)],
      sum(model$Y_explained),
      tolerance = 1e-10
    )
  }
})
