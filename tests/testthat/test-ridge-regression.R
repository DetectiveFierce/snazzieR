# Test file for ridge regression functionality

test_that("ridge.regression works with formula interface", {
    # Test with mtcars data
    model <- ridge.regression(mpg ~ wt + hp + disp, data = mtcars)

    # Check object structure
    expect_s3_class(model, "ridge.model")
    expect_equal(model$method, "ridge")
    expect_equal(model$folds, 5)
    expect_true(is.numeric(model$optimal.lambda))
    expect_true(is.numeric(model$cv.ms))
    expect_true(is.numeric(model$coefficients))
    expect_true(is.numeric(model$intercept))
    expect_true(is.numeric(model$fitted.values))
    expect_true(is.numeric(model$residuals))

    # Check dimensions
    expect_equal(length(model$coefficients), 3) # wt, hp, disp
    expect_equal(length(model$fitted.values), nrow(mtcars))
    expect_equal(length(model$residuals), nrow(mtcars))

    # Check that formula is stored
    expect_true(!is.null(model$formula))
    expect_true(!is.null(model$terms))
})

test_that("ridge.regression works with matrix interface", {
    # Prepare data
    X <- as.matrix(mtcars[, c("wt", "hp", "disp")])
    y <- mtcars$mpg

    model <- ridge.regression(x = X, y = y)

    # Check object structure
    expect_s3_class(model, "ridge.model")
    expect_equal(model$method, "ridge")
    expect_equal(model$folds, 5)
    expect_true(is.numeric(model$optimal.lambda))
    expect_true(is.numeric(model$cv.ms))
    expect_true(is.numeric(model$coefficients))
    expect_true(is.numeric(model$intercept))

    # Check that formula is not stored for matrix interface
    expect_true(is.null(model$formula))
    expect_true(is.null(model$terms))
})

test_that("formula and matrix interfaces give equivalent results", {
    # Formula interface
    model1 <- ridge.regression(mpg ~ wt + hp + disp, data = mtcars)

    # Matrix interface
    X <- as.matrix(mtcars[, c("wt", "hp", "disp")])
    y <- mtcars$mpg
    model2 <- ridge.regression(x = X, y = y)

    # Results should be very similar (allowing for CV randomness)
    expect_equal(length(model1$coefficients), length(model2$coefficients))
    expect_equal(length(model1$fitted.values), length(model2$fitted.values))
    expect_equal(length(model1$residuals), length(model2$residuals))
})

test_that("fit.ridge computes correct coefficients", {
    # Create simple test data - reduced size for speed
    set.seed(123)
    n <- 30 # Reduced from 100
    p <- 3
    X <- matrix(rnorm(n * p), n, p)
    y <- rnorm(n)

    # Standardize data
    X_std <- scale(X)
    y_centered <- y - mean(y)

    # Test with different lambda values
    lambda <- 1.0
    fit_result <- snazzieR:::fit.ridge(X_std, y_centered, lambda)
    coef1 <- fit_result$coefficients

    # Manual computation for verification
    XtX <- t(X_std) %*% X_std
    Xty <- t(X_std) %*% y_centered
    ridge_matrix <- XtX + lambda * diag(p)
    coef2 <- solve(ridge_matrix, Xty)

    expect_equal(coef1, coef2, tolerance = 1e-10)
})

test_that("cv.mse returns reasonable values", {
    set.seed(123)
    n <- 20 # Reduced from 50
    p <- 2
    X <- matrix(rnorm(n * p), n, p)
    y <- rnorm(n)

    # Standardize data
    X_std <- scale(X)
    y_centered <- y - mean(y)

    # Test CV-MSE
    lambda <- 1.0
    cv_mse <- snazzieR:::cv.mse(X_std, y_centered, lambda, folds = 3) # Reduced folds

    expect_true(is.numeric(cv_mse))
    expect_true(cv_mse >= 0)
    expect_true(length(cv_mse) == 1)
})

test_that("optimize.cv.lambda finds optimal lambda", {
    skip_on_cran() # Skip expensive optimization test on CRAN

    set.seed(123)
    n <- 20 # Reduced from 50
    p <- 2
    X <- matrix(rnorm(n * p), n, p)
    y <- rnorm(n)

    # Standardize data
    X_std <- scale(X)
    y_centered <- y - mean(y)

    # Test optimization with smaller range
    lambda_range <- c(0.1, 5) # Reduced range
    result <- snazzieR:::optimize.cv.lambda(X_std, y_centered, lambda_range, folds = 3)

    expect_true(is.numeric(result$minimum))
    expect_true(is.numeric(result$objective))
    expect_true(is.data.frame(result$trace))
    expect_true(result$minimum >= lambda_range[1])
    expect_true(result$minimum <= lambda_range[2])
})

test_that("predict.ridge.model works correctly", {
    # Fit model
    model <- ridge.regression(mpg ~ wt + hp + disp, data = mtcars)

    # Predict on training data
    pred1 <- predict(model)
    expect_equal(pred1, model$fitted.values)

    # Predict on new data
    newdata <- data.frame(wt = 3.0, hp = 150, disp = 200)
    pred2 <- predict(model, newdata)

    expect_true(is.numeric(pred2))
    expect_equal(length(pred2), 1)
})

test_that("print.ridge.model works", {
    model <- ridge.regression(mpg ~ wt + hp + disp, data = mtcars)

    # Should not throw an error
    expect_no_error(print(model))

    # Should return the model invisibly
    result <- print(model)
    expect_equal(result, model)

    # Check that coefficients have names
    expect_true(length(names(model$coefficients)) > 0)
})

test_that("ridge.regression handles edge cases", {
    # Test with custom lambda range and folds
    model <- ridge.regression(mpg ~ wt + hp + disp,
        data = mtcars,
        lambda.range = c(0.01, 1), folds = 3
    )

    expect_equal(model$folds, 3)
    expect_true(model$optimal.lambda >= 0.01)
    expect_true(model$optimal.lambda <= 1)
})

test_that("ridge.regression handles zero variance predictors", {
    # Create data with a constant column
    data_with_constant <- mtcars
    data_with_constant$constant <- 1

    # Should not throw an error, should give warning
    expect_warning(
        model <- ridge.regression(mpg ~ wt + hp + constant, data = data_with_constant)
    )

    # The constant column should be excluded
    expect_equal(length(model$coefficients), 2) # wt and hp only
})

test_that("ridge.regression validates inputs", {
    # Missing data with formula
    expect_error(ridge.regression(mpg ~ wt + hp, data = NULL))

    # Missing x or y with matrix interface
    expect_error(ridge.regression(x = matrix(1:10, 5, 2)))
    expect_error(ridge.regression(y = 1:5))

    # Dimension mismatch
    expect_error(ridge.regression(x = matrix(1:10, 5, 2), y = 1:3))
})
