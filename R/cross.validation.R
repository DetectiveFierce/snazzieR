# Custom K-Fold Cross Validation Implementation in R
# Original implementation for educational and practical use

#' Create K-Fold Cross Validation Splits
#'
#' @param data A data frame containing the dataset
#' @param k Number of folds (default: 5)
#' @param seed Random seed for reproducibility (optional)
#' @return A list containing fold assignments for each observation
create_kfold_splits <- function(data, k = 5, seed = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }

  n <- nrow(data)

  # Create shuffled indices
  shuffled_indices <- sample(1:n)

  # Calculate fold sizes
  fold_size <- n %/% k
  remainder <- n %% k

  # Create fold assignments
  fold_assignments <- vector("list", k)
  start_idx <- 1

  for (i in 1:k) {
    # Add one extra element to first 'remainder' folds
    current_fold_size <- fold_size + (i <= remainder)
    end_idx <- start_idx + current_fold_size - 1

    fold_assignments[[i]] <- shuffled_indices[start_idx:end_idx]
    start_idx <- end_idx + 1
  }

  return(fold_assignments)
}

#' Perform K-Fold Cross Validation
#'
#' @param data A data frame containing the dataset
#' @param formula A formula specifying the model (e.g., y ~ x1 + x2)
#' @param model_function Function to fit the model (e.g., lm, glm)
#' @param predict_function Function to make predictions (default: predict)
#' @param metric_function Function to calculate performance metric
#' @param k Number of folds (default: 5)
#' @param seed Random seed for reproducibility (optional)
#' @param ... Additional arguments passed to model_function
#' @return A list containing fold results and summary statistics
kfold_cross_validation <- function(data, formula, model_function,
                                   predict_function = predict,
                                   metric_function = NULL,
                                   k = 5, seed = NULL, ...) {

  # Set default metric function for regression
  if (is.null(metric_function)) {
    metric_function <- function(actual, predicted) {
      mean((actual - predicted)^2)  # MSE
    }
  }

  # Create fold splits
  fold_splits <- create_kfold_splits(data, k, seed)

  # Initialize results storage
  fold_results <- vector("list", k)
  fold_metrics <- numeric(k)

  # Extract response variable name from formula
  response_var <- as.character(formula)[2]

  # Perform cross validation
  for (i in 1:k) {
    cat("Processing fold", i, "of", k, "\n")

    # Split data into training and testing sets
    test_indices <- fold_splits[[i]]
    train_indices <- setdiff(1:nrow(data), test_indices)

    train_data <- data[train_indices, ]
    test_data <- data[test_indices, ]

    # Fit model on training data
    model <- model_function(formula, data = train_data, ...)

    # Make predictions on test data
    predictions <- predict_function(model, newdata = test_data)

    # Extract actual values
    actual_values <- test_data[[response_var]]

    # Calculate metric
    fold_metric <- metric_function(actual_values, predictions)

    # Store results
    fold_results[[i]] <- list(
      fold = i,
      train_size = nrow(train_data),
      test_size = nrow(test_data),
      predictions = predictions,
      actual = actual_values,
      metric = fold_metric,
      model = model
    )

    fold_metrics[i] <- fold_metric
  }

  # Calculate summary statistics
  mean_metric <- mean(fold_metrics)
  sd_metric <- sd(fold_metrics)

  # Return comprehensive results
  return(list(
    fold_results = fold_results,
    fold_metrics = fold_metrics,
    mean_metric = mean_metric,
    sd_metric = sd_metric,
    k = k,
    formula = formula,
    summary = data.frame(
      fold = 1:k,
      metric = fold_metrics,
      train_size = sapply(fold_results, function(x) x$train_size),
      test_size = sapply(fold_results, function(x) x$test_size)
    )
  ))
}

