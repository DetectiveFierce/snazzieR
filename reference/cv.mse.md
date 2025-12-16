# Compute Cross-Validated Mean Squared Error

Computes mean squared error via k-fold cross-validation for a fixed
lambda value.

## Usage

``` r
cv.mse(x, y, lambda, folds = 5, fold_indices = NULL)
```

## Arguments

- x:

  A standardized design matrix (n × p)

- y:

  A centered response vector (n × 1)

- lambda:

  A non-negative regularization scalar

- folds:

  Number of cross-validation folds (default: 5)

## Value

A numeric scalar representing the CV-MSE
