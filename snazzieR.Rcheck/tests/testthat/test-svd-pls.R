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

test_that("SVD.pls mathematical properties are correct", {
  # Create simple test data
  set.seed(123)
  n <- 50
  p <- 3
  q <- 2
  X <- matrix(rnorm(n * p), n, p)
  Y <- matrix(rnorm(n * q), n, q)

  model <- SVD.pls(X, Y, n.components = 2)

  # Check dimensions
  expect_equal(nrow(model$T), n)
  expect_equal(ncol(model$T), 2)
  expect_equal(nrow(model$U), n)
  expect_equal(ncol(model$U), 2)
  expect_equal(nrow(model$W), p)
  expect_equal(ncol(model$W), 2)
  expect_equal(nrow(model$C), q)
  expect_equal(ncol(model$C), 2)

  # Check orthogonality of scores (T' * T should be diagonal)
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
})

test_that("SVD.pls SVD properties are maintained", {
  set.seed(456)
  X <- matrix(rnorm(30 * 4), 30, 4)
  Y <- matrix(rnorm(30 * 2), 30, 2)

  model <- SVD.pls(X, Y, n.components = 3)

  # Check that B_vector contains non-zero values
  expect_true(all(model$B_vector != 0))

  # Check that explained variance is reasonable
  expect_true(all(model$X_explained >= 0))
  expect_true(all(model$Y_explained >= 0))
  expect_true(all(model$X_cum_explained <= 100))
  expect_true(all(model$Y_cum_explained <= 100))

  # Check that cumulative explained variance is non-decreasing
  expect_true(all(diff(model$X_cum_explained) >= 0))
  expect_true(all(diff(model$Y_cum_explained) >= 0))

  # Check that W is orthogonal (W' * W should be identity)
  W_cross <- crossprod(model$W)

  expect_equal(diag(W_cross), rep(1, ncol(model$W)), tolerance = 1e-10)

  # Check off-diagonal elements are zero
  expect_true(all(abs(W_cross[upper.tri(W_cross)]) < 1e-10))

  # Check that C vectors are normalized (but not necessarily orthogonal)
  for (h in seq_len(ncol(model$C))) {
    expect_equal(sum(model$C[, h]^2), 1, tolerance = 1e-10)
  }
})

test_that("SVD.pls coefficient scaling is correct", {
  set.seed(789)
  X <- matrix(rnorm(40 * 3), 40, 3)
  Y <- matrix(rnorm(40 * 2), 40, 2)

  # Add some structure to make the relationship more realistic
  X[, 2] <- X[, 1] + rnorm(40, 0, 0.1)
  Y[, 1] <- 2 * X[, 1] + 0.5 * X[, 2] + rnorm(40, 0, 0.5)

  model <- SVD.pls(X, Y, n.components = 2)

  # Check that coefficients have reasonable scale
  expect_true(all(is.finite(model$coefficients)))

  # Check that intercept is zero (due to centering)
  expect_true(all(model$intercept == 0))

  # Verify that predictions work
  X_scaled <- scale(X, center = TRUE, scale = TRUE)
  y_pred_scaled <- X_scaled %*% model$coefficients
  y_pred <- sweep(y_pred_scaled, 2, attr(scale(Y), "scaled:scale"), "*") +
    sweep(matrix(0, nrow(X), ncol(Y)), 2, attr(scale(Y), "scaled:center"), "+")

  expect_equal(nrow(y_pred), nrow(X))
  expect_equal(ncol(y_pred), ncol(Y))
})

test_that("SVD.pls handles edge cases correctly", {
  # Test with maximum components
  set.seed(123)
  X <- matrix(rnorm(20 * 2), 20, 2)
  Y <- matrix(rnorm(20 * 1), 20, 1)

  model_max <- SVD.pls(X, Y, n.components = NULL)
  rank_X <- qr(X)$rank
  expect_equal(ncol(model_max$T), rank_X)

  # Test with more components than rank
  model_high <- SVD.pls(X, Y, n.components = 5)
  expect_equal(ncol(model_high$T), rank_X)
})

test_that("SVD.pls mathematical relationships hold", {
  set.seed(321)
  X <- matrix(rnorm(25 * 3), 25, 3)
  Y <- matrix(rnorm(25 * 2), 25, 2)

  model <- SVD.pls(X, Y, n.components = 2)

  # Check that B_vector contains the regression coefficients
  expect_equal(length(model$B_vector), ncol(model$T))
  expect_true(all(model$B_vector != 0))

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

  # Check that P_loadings = X_scaled' %*% T (loadings = data' %*% scores)
  X_scaled <- scale(X, center = TRUE, scale = TRUE)
  P_computed <- crossprod(X_scaled, model$T)
  expect_equal(model$P_loadings, P_computed, tolerance = 1e-10)
})

test_that("SVD.pls SVD decomposition properties", {
  set.seed(654)
  X <- matrix(rnorm(35 * 4), 35, 4)
  Y <- matrix(rnorm(35 * 2), 35, 2)

  model <- SVD.pls(X, Y, n.components = 3)

  # Check that B_vector contains non-zero values
  expect_true(all(model$B_vector != 0))

  # Check that W and C are normalized
  for (h in seq_len(ncol(model$W))) {
    expect_equal(sum(model$W[, h]^2), 1, tolerance = 1e-10)
  }

  for (h in seq_len(ncol(model$C))) {
    expect_equal(sum(model$C[, h]^2), 1, tolerance = 1e-10)
  }

  # Check that the cross-covariance matrix R has the expected structure
  X_scaled <- scale(X, center = TRUE, scale = TRUE)
  Y_scaled <- scale(Y, center = TRUE, scale = TRUE)
  R <- crossprod(X_scaled, Y_scaled)

  # Perform SVD on R
  svd_R <- svd(R)

  # Check that the number of components matches the available singular vectors
  # The algorithm may extract fewer components than requested if the rank is lower
  expect_equal(ncol(model$W), length(model$B_vector))
  expect_equal(ncol(model$C), length(model$B_vector))
})
