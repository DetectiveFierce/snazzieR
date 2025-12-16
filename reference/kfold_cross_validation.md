# Perform K-Fold Cross Validation

Perform K-Fold Cross Validation

## Usage

``` r
kfold_cross_validation(
  data,
  formula,
  model_function,
  predict_function = predict,
  metric_function = NULL,
  k = 5,
  seed = NULL,
  ...
)
```

## Arguments

- data:

  A data frame containing the dataset

- formula:

  A formula specifying the model (e.g., y ~ x1 + x2)

- model_function:

  Function to fit the model (e.g., lm, glm)

- predict_function:

  Function to make predictions (default: predict)

- metric_function:

  Function to calculate performance metric

- k:

  Number of folds (default: 5)

- seed:

  Random seed for reproducibility (optional)

- ...:

  Additional arguments passed to model_function

## Value

A list containing fold results and summary statistics
