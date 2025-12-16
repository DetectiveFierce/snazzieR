# Optimize Lambda Using Cross-Validation

Searches the lambda range to minimize CV-MSE using Brent's method via
\`optimize()\`.

## Usage

``` r
optimize.cv.lambda(x, y, lambda.range, folds)
```

## Arguments

- x:

  A standardized design matrix (n × p)

- y:

  A centered response vector (n × 1)

- lambda.range:

  A numeric vector of length 2 specifying the search interval

- folds:

  Number of cross-validation folds

## Value

A list containing:

- minimum:

  Optimal lambda value

- objective:

  Minimum CV-MSE achieved

- trace:

  Data frame with lambda and CV-MSE pairs
