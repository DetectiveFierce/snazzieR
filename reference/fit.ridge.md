# Fit Ridge Regression with Closed-Form Solution

Computes ridge regression coefficients and standard errors using the
closed-form solution: \\\hat{\beta} = (X^T X + \lambda I)^{-1} X^T y\\

## Usage

``` r
fit.ridge(x, y, lambda)
```

## Arguments

- x:

  A standardized design matrix (n × p)

- y:

  A centered response vector (n × 1)

- lambda:

  A non-negative regularization scalar

## Value

A list containing:

- coefficients:

  Ridge regression coefficients (length p)

- std_errors:

  Standard errors of the coefficients (length p)
