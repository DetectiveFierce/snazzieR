# ==== VALIDATION CHECKS FOR CUSTOM K-FOLD CROSS VALIDATION ====

# Create output capture list
validation_results <- list()

# Load required packages
suppressMessages({
  if (!requireNamespace("caret", quietly = TRUE)) install.packages("caret")
  library(caret)
  if (!requireNamespace("testthat", quietly = TRUE)) install.packages("testthat")
  library(testthat)
})

# 1. Check if all rows are used exactly once in the folds
folds <- create_kfold_splits(mtcars, k = 5, seed = 123)
all_indices <- unlist(folds)
test1 <- list(
  test_name = "Each row is assigned exactly once",
  passed = length(all_indices) == nrow(mtcars) &&
    length(unique(all_indices)) == nrow(mtcars),
  detail = paste("Assigned:", length(all_indices),
                 "Unique:", length(unique(all_indices)),
                 "Total rows:", nrow(mtcars))
)

# 2. Compare custom CV vs caret on small synthetic dataset
df <- data.frame(x = 1:10, y = 2 * (1:10) + 1)
custom_small <- kfold_cross_validation(df, y ~ x, lm, k = 5, seed = 42)
caret_small <- train(
  y ~ x,
  data = df,
  method = "lm",
  trControl = trainControl(method = "cv", number = 5),
  metric = "RMSE"
)
custom_mse_small <- custom_small$mean_metric
caret_mse_small <- caret_small$results$RMSE^2
test2 <- list(
  test_name = "Compare on perfect linear data",
  passed = abs(custom_mse_small - caret_mse_small) < 1e-6,
  detail = paste("Custom MSE:", round(custom_mse_small, 8),
                 "Caret MSE:", round(caret_mse_small, 8))
)

# 3. Check predictions vs actual output for one fold
one_fold <- custom_small$fold_results[[1]]
test3 <- list(
  test_name = "Fold prediction sanity check",
  passed = length(one_fold$actual) == length(one_fold$predictions),
  detail = paste("Length(actual):", length(one_fold$actual),
                 "Length(predictions):", length(one_fold$predictions))
)

# 4. Check k = n (Leave-One-Out CV)
loo_result <- kfold_cross_validation(df, y ~ x, lm, k = nrow(df), seed = 1)
test4 <- list(
  test_name = "Leave-One-Out CV produces one test obs per fold",
  passed = all(sapply(loo_result$fold_results, function(x) x$test_size) == 1),
  detail = paste("Test sizes:", paste(sapply(loo_result$fold_results, function(x) x$test_size), collapse = ", "))
)

# 5. Test fold sizes are roughly even
sizes <- sapply(folds, length)
test5 <- list(
  test_name = "Folds are balanced in size",
  passed = max(sizes) - min(sizes) <= 1,
  detail = paste("Fold sizes:", paste(sizes, collapse = ", "))
)

# Combine all test results
validation_results <- list(test1, test2, test3, test4, test5)

# 6. Compare on non-linear (realistic) data
set.seed(123)
df_noisy <- data.frame(
  x = 1:100,
  y = 3 * (1:100) + rnorm(100, mean = 0, sd = 20)  # Linear + noise
)

custom_noisy <- kfold_cross_validation(df_noisy, y ~ x, lm, k = 5, seed = 123)
caret_noisy <- train(
  y ~ x,
  data = df_noisy,
  method = "lm",
  trControl = trainControl(method = "cv", number = 5),
  metric = "RMSE"
)

mse_custom <- custom_noisy$mean_metric
mse_caret <- caret_noisy$results$RMSE^2

test6 <- list(
  test_name = "Compare on noisy (realistic) data",
  passed = abs(mse_custom - mse_caret) / mse_caret < 0.10,  # Allow 10% tolerance
  detail = paste("Custom MSE:", round(mse_custom, 4),
                 "Caret MSE:", round(mse_caret, 4),
                 "Difference:", round(abs(mse_custom - mse_caret), 4))
)

# Add to validation results
validation_results <- c(validation_results, list(test6))

# ==== REPORT ====
cat("\n\n========= CUSTOM K-FOLD VALIDATION SUMMARY =========\n\n")
for (result in validation_results) {
  status <- if (result$passed) "[PASS]" else "[FAIL]"
  cat(status, result$test_name, "\n")
  cat("   →", result$detail, "\n\n")
}
