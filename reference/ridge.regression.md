# Ridge Regression with Automatic Lambda Selection

Performs ridge regression with automatic selection of the optimal
regularization parameter \`lambda\` by minimizing k-fold cross-validated
mean squared error (CV-MSE) using Brent's method. Supports both formula
and matrix interfaces.

## Usage

``` r
ridge.regression(
  formula = NULL,
  data = NULL,
  x = NULL,
  y = NULL,
  lambda.range = c(1e-04, 100),
  folds = 5,
  ...
)
```

## Arguments

- formula:

  A model formula like \`y ~ x1 + x2\`. Mutually exclusive with
  \`x\`/\`y\`.

- data:

  A data frame containing all variables used in the formula.

- x:

  A numeric matrix of predictor variables (n × p). Used when formula is
  not provided.

- y:

  A numeric vector of response variables (n × 1). Used when formula is
  not provided.

- lambda.range:

  A numeric vector of length 2 specifying the interval for lambda
  optimization. Default: \`c(1e-4, 100)\`.

- folds:

  An integer specifying the number of cross-validation folds. Default:
  \`5\`.

- ...:

  Additional arguments passed to internal methods.

## Value

A \`ridge.model\` object containing:

- coefficients:

  Final ridge coefficients (no intercept)

- std_errors:

  Standard errors of the coefficients

- intercept:

  Intercept term (from y centering)

- optimal.lambda:

  Best lambda minimizing CV-MSE

- cv.ms:

  Minimum CV-MSE achieved

- cv.results:

  Data frame with lambda and CV-MSE pairs

- x.scale:

  Standardization info: mean and sd for each predictor

- y.center:

  Centering constant for y

- fitted.values:

  Final model predictions on training data

- residuals:

  Training residuals (y - fitted)

- call:

  Matched call (for debugging)

- method:

  Always "ridge"

- folds:

  Number of CV folds used

- formula:

  Stored if formula interface used

- terms:

  Stored if formula interface used

## Details

This function implements ridge regression with automatic hyperparameter
tuning. The algorithm:

- Standardizes predictor variables (centers and scales)

- Centers the response variable

- Uses k-fold cross-validation to find the optimal lambda

- Fits the final model with the optimal lambda

- Returns a structured object for prediction and analysis

The ridge regression solution is computed using the closed-form formula:
\\\hat{\beta} = (X^T X + \lambda I)^{-1} X^T y\\

## References

Hoerl, A. E., & Kennard, R. W. (1970). Ridge regression: Biased
estimation for nonorthogonal problems. *Technometrics*, 12(1), 55-67.

## See also

[`predict.ridge.model`](https://jesusbutforgaypeople.github.io/snazzieR/reference/predict.ridge.model.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Formula interface
model1 <- ridge.regression(mpg ~ wt + hp + disp, data = mtcars)

# Matrix interface
X <- as.matrix(mtcars[, c("wt", "hp", "disp")])
y <- mtcars$mpg
model2 <- ridge.regression(x = X, y = y)

# Custom lambda range and folds
model3 <- ridge.regression(mpg ~ .,
    data = mtcars,
    lambda.range = c(0.1, 10), folds = 10
)
} # }
```
