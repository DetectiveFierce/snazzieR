#' @title Ridge Regression with Automatic Lambda Selection
#'
#' @description
#' Performs ridge regression with automatic selection of the optimal regularization parameter `lambda`
#' by minimizing k-fold cross-validated mean squared error (CV-MSE) using Brent's method.
#' Supports both formula and matrix interfaces.
#'
#' @param formula A model formula like `y ~ x1 + x2`. Mutually exclusive with `x`/`y`.
#' @param data A data frame containing all variables used in the formula.
#' @param x A numeric matrix of predictor variables (n × p). Used when formula is not provided.
#' @param y A numeric vector of response variables (n × 1). Used when formula is not provided.
#' @param lambda.range A numeric vector of length 2 specifying the interval for lambda optimization.
#'        Default: `c(1e-4, 100)`.
#' @param folds An integer specifying the number of cross-validation folds. Default: `5`.
#' @param ... Additional arguments passed to internal methods.
#'
#' @details
#' This function implements ridge regression with automatic hyperparameter tuning. The algorithm:
#' \itemize{
#'   \item Standardizes predictor variables (centers and scales)
#'   \item Centers the response variable
#'   \item Uses k-fold cross-validation to find the optimal lambda
#'   \item Fits the final model with the optimal lambda
#'   \item Returns a structured object for prediction and analysis
#' }
#'
#' The ridge regression solution is computed using the closed-form formula:
#' \eqn{\hat{\beta} = (X^T X + \lambda I)^{-1} X^T y}
#'
#' @return A `ridge.model` object containing:
#' \describe{
#'   \item{coefficients}{Final ridge coefficients (no intercept)}
#'   \item{std_errors}{Standard errors of the coefficients}
#'   \item{intercept}{Intercept term (from y centering)}
#'   \item{optimal.lambda}{Best lambda minimizing CV-MSE}
#'   \item{cv.ms}{Minimum CV-MSE achieved}
#'   \item{cv.results}{Data frame with lambda and CV-MSE pairs}
#'   \item{x.scale}{Standardization info: mean and sd for each predictor}
#'   \item{y.center}{Centering constant for y}
#'   \item{fitted.values}{Final model predictions on training data}
#'   \item{residuals}{Training residuals (y - fitted)}
#'   \item{call}{Matched call (for debugging)}
#'   \item{method}{Always "ridge"}
#'   \item{folds}{Number of CV folds used}
#'   \item{formula}{Stored if formula interface used}
#'   \item{terms}{Stored if formula interface used}
#' }
#'
#' @seealso
#' \code{\link{predict.ridge.model}}
#'
#' @references
#' Hoerl, A. E., & Kennard, R. W. (1970). Ridge regression: Biased estimation for nonorthogonal problems.
#' \emph{Technometrics}, 12(1), 55-67.
#'
#' @examples
#' \dontrun{
#' # Formula interface
#' model1 <- ridge.regression(mpg ~ wt + hp + disp, data = mtcars)
#'
#' # Matrix interface
#' X <- as.matrix(mtcars[, c("wt", "hp", "disp")])
#' y <- mtcars$mpg
#' model2 <- ridge.regression(x = X, y = y)
#'
#' # Custom lambda range and folds
#' model3 <- ridge.regression(mpg ~ .,
#'     data = mtcars,
#'     lambda.range = c(0.1, 10), folds = 10
#' )
#' }
#'
#' @export
#' @importFrom stats model.frame model.matrix model.response terms optimize
ridge.regression <- function(formula = NULL, data = NULL, x = NULL, y = NULL,
                             lambda.range = c(1e-4, 100), folds = 5, ...) {
    # Store the call for debugging
    call <- match.call()

    # Step 1: Input handling and dispatch
    if (!is.null(formula)) {
        # Formula interface
        if (is.null(data)) {
            stop("data must be provided when using formula interface")
        }

        # Extract model frame and components
        mf <- model.frame(formula, data = data)
        x <- model.matrix(formula, data = mf)
        y <- model.response(mf)

        # Remove intercept column if present (we'll handle intercept separately)
        if (colnames(x)[1] == "(Intercept)") {
            x <- x[, -1, drop = FALSE]
        }

        # Store formula metadata
        formula_stored <- formula
        terms_stored <- terms(formula, data = data)
    } else {
        # Matrix interface
        if (is.null(x) || is.null(y)) {
            stop("x and y must be provided when not using formula interface")
        }

        # Validate inputs
        if (!is.matrix(x) && !is.data.frame(x)) {
            x <- as.matrix(x)
        }
        if (!is.vector(y) && !is.matrix(y)) {
            y <- as.vector(y)
        }

        # Check dimensions
        if (nrow(x) != length(y)) {
            stop("Number of rows in x must equal length of y")
        }

        formula_stored <- NULL
        terms_stored <- NULL
    }

    # Step 2: Data preprocessing
    # Standardize x
    x_means <- colMeans(x)
    x_sds <- apply(x, 2, sd)

    # Handle zero variance columns
    zero_var_cols <- x_sds == 0
    if (any(zero_var_cols)) {
        warning("Some predictors have zero variance and will be excluded")
        x <- x[, !zero_var_cols, drop = FALSE]
        x_means <- x_means[!zero_var_cols]
        x_sds <- x_sds[!zero_var_cols]
    }

    # Standardize x
    x_std <- scale(x, center = x_means, scale = x_sds)

    # Center y
    y_mean <- mean(y)
    y_centered <- y - y_mean

    # Store preprocessing artifacts
    x_scale <- list(mean = x_means, sd = x_sds)
    y_center <- y_mean

    # Step 3: Lambda optimization
    opt_result <- optimize.cv.lambda(x_std, y_centered, lambda.range, folds)
    optimal_lambda <- opt_result$minimum
    min_cv_mse <- opt_result$objective
    cv_results <- opt_result$trace

    # Step 4: Final ridge fit
    ridge_fit_result <- fit.ridge(x_std, y_centered, optimal_lambda)

    # Extract coefficients and standard errors
    coefficients <- ridge_fit_result$coefficients
    std_errors <- ridge_fit_result$std_errors

    # Add names to coefficients and standard errors
    if (!is.null(colnames(x))) {
        names(coefficients) <- colnames(x)
        names(std_errors) <- colnames(x)
    } else {
        names(coefficients) <- paste0("X", 1:length(coefficients))
        names(std_errors) <- paste0("X", 1:length(coefficients))
    }

    # Reconstruct fitted values and residuals
    fitted_values <- x_std %*% coefficients + y_center
    residuals <- y - fitted_values

    # Create ridge.model object
    ridge_model <- structure(
        list(
            coefficients = coefficients,
            std_errors = std_errors,
            intercept = y_center,
            optimal.lambda = optimal_lambda,
            cv.ms = min_cv_mse,
            cv.results = cv_results,
            x.scale = x_scale,
            y.center = y_center,
            fitted.values = fitted_values,
            residuals = residuals,
            call = call,
            method = "ridge",
            folds = folds,
            formula = formula_stored,
            terms = terms_stored
        ),
        class = "ridge.model"
    )

    return(ridge_model)
}

#' @title Fit Ridge Regression with Closed-Form Solution
#'
#' @description
#' Computes ridge regression coefficients and standard errors using the closed-form solution:
#' \eqn{\hat{\beta} = (X^T X + \lambda I)^{-1} X^T y}
#'
#' @param x A standardized design matrix (n × p)
#' @param y A centered response vector (n × 1)
#' @param lambda A non-negative regularization scalar
#'
#' @return A list containing:
#' \describe{
#'   \item{coefficients}{Ridge regression coefficients (length p)}
#'   \item{std_errors}{Standard errors of the coefficients (length p)}
#' }
#'
#' @keywords internal
#' @importFrom stats optimize
fit.ridge <- function(x, y, lambda) {
    p <- ncol(x)
    n <- nrow(x)

    # Ridge regression closed-form solution
    # beta = (X'X + lambda*I)^(-1) * X'y
    xtx <- t(x) %*% x
    xty <- t(x) %*% y
    ridge_matrix <- xtx + lambda * diag(p)

    # Solve the system
    coefficients <- solve(ridge_matrix, xty)

    # Calculate residuals and MSE
    fitted_values <- x %*% coefficients
    residuals <- y - fitted_values
    mse <- sum(residuals^2) / (n - p)

    # Calculate standard errors
    # For ridge regression: SE = sqrt(mse * diag((X'X + lambda*I)^(-1) * X'X * (X'X + lambda*I)^(-1)))
    ridge_inv <- solve(ridge_matrix)
    var_cov_matrix <- mse * ridge_inv %*% xtx %*% ridge_inv
    std_errors <- sqrt(diag(var_cov_matrix))

    return(list(
        coefficients = coefficients,
        std_errors = std_errors
    ))
}

#' @title Compute Cross-Validated Mean Squared Error
#'
#' @description
#' Computes mean squared error via k-fold cross-validation for a fixed lambda value.
#'
#' @param x A standardized design matrix (n × p)
#' @param y A centered response vector (n × 1)
#' @param lambda A non-negative regularization scalar
#' @param folds Number of cross-validation folds (default: 5)
#'
#' @return A numeric scalar representing the CV-MSE
#'
#' @keywords internal
cv.mse <- function(x, y, lambda, folds = 5, fold_indices = NULL) {
    n <- nrow(x)

    # Create fold indices if not provided
    if (is.null(fold_indices)) {
        fold_indices <- sample(rep(1:folds, length.out = n))
    }

    cv_errors <- numeric(folds)

    for (fold in 1:folds) {
        # Split data
        test_indices <- which(fold_indices == fold)
        train_indices <- which(fold_indices != fold)

        x_train <- x[train_indices, , drop = FALSE]
        y_train <- y[train_indices]
        x_test <- x[test_indices, , drop = FALSE]
        y_test <- y[test_indices]

        # Fit ridge regression on training data
        ridge_fit_train <- fit.ridge(x_train, y_train, lambda)
        beta_train <- ridge_fit_train$coefficients

        # Predict on test data
        y_pred <- x_test %*% beta_train

        # Compute MSE for this fold
        cv_errors[fold] <- mean((y_test - y_pred)^2)
    }

    # Return mean CV-MSE
    return(mean(cv_errors))
}

#' @title Optimize Lambda Using Cross-Validation
#'
#' @description
#' Searches the lambda range to minimize CV-MSE using Brent's method via `optimize()`.
#'
#' @param x A standardized design matrix (n × p)
#' @param y A centered response vector (n × 1)
#' @param lambda.range A numeric vector of length 2 specifying the search interval
#' @param folds Number of cross-validation folds
#'
#' @return A list containing:
#' \describe{
#'   \item{minimum}{Optimal lambda value}
#'   \item{objective}{Minimum CV-MSE achieved}
#'   \item{trace}{Data frame with lambda and CV-MSE pairs}
#' }
#'
#' @keywords internal
optimize.cv.lambda <- function(x, y, lambda.range, folds) {
    n <- nrow(x)

    # Create consistent fold indices for all CV calculations
    fold_indices <- sample(rep(1:folds, length.out = n))

    # Use optimize() with Brent's method
    opt_result <- optimize(
        f = function(lambda) cv.mse(x, y, lambda, folds, fold_indices),
        interval = lambda.range,
        tol = 1e-6
    )

    # Create trace for plotting/debugging
    # Sample some lambda values for the trace
    lambda_seq <- exp(seq(log(lambda.range[1]), log(lambda.range[2]), length.out = 20))
    cv_mse_seq <- sapply(lambda_seq, function(lambda) cv.mse(x, y, lambda, folds, fold_indices))

    trace <- data.frame(
        lambda = lambda_seq,
        cv.mse = cv_mse_seq
    )

    return(list(
        minimum = opt_result$minimum,
        objective = opt_result$objective,
        trace = trace
    ))
}

#' @title Predict Method for Ridge Model Objects
#'
#' @description
#' Predicts response values for new data using a fitted ridge model.
#'
#' @param object A `ridge.model` object
#' @param newdata A data frame or matrix containing new predictor values
#' @param ... Additional arguments (not used)
#'
#' @return A numeric vector of predicted values
#'
#' @method predict ridge.model
#' @export
predict.ridge.model <- function(object, newdata = NULL, ...) {
    if (is.null(newdata)) {
        return(object$fitted.values)
    }

    # Convert to matrix if needed
    if (!is.matrix(newdata) && !is.data.frame(newdata)) {
        newdata <- as.matrix(newdata)
    }

    # Apply the same preprocessing as training data
    x_new <- scale(newdata, center = object$x.scale$mean, scale = object$x.scale$sd)

    # Predict using coefficients
    predictions <- x_new %*% object$coefficients + object$intercept

    return(as.vector(predictions))
}

#' @title Print Method for Ridge Model Objects
#'
#' @description
#' Prints a summary of the ridge model fit.
#'
#' @param x A `ridge.model` object
#' @param ... Additional arguments (not used)
#'
#' @method print ridge.model
#' @export
print.ridge.model <- function(x, ...) {
    cat("Ridge Regression Model\n")
    cat("=====================\n\n")

    cat("Call:\n")
    print(x$call)
    cat("\n")

    cat("Optimal lambda:", round(x$optimal.lambda, 6), "\n")
    cat("CV-MSE:", round(x$cv.ms, 6), "\n")
    cat("Number of CV folds:", x$folds, "\n")
    cat("Number of predictors:", length(x$coefficients), "\n")
    cat("Training MSE:", round(mean(x$residuals^2), 6), "\n\n")

    cat("Coefficients:\n")
    if (length(x$coefficients) > 0) {
        coef_df <- data.frame(
            Predictor = names(x$coefficients),
            Coefficient = round(x$coefficients, 6)
        )
        print(coef_df, row.names = FALSE)
    } else {
        cat("No coefficients available\n")
    }

    invisible(x)
}
