# Partial Least Squares Regression via NIPALS (Internal)

This function is called internally by
[`pls.regression`](https://jesusbutforgaypeople.github.io/snazzieR/reference/pls.regression.md)
and is not intended to be used directly. Use
`pls.regression(..., calc.method = "NIPALS")` instead.

Performs Partial Least Squares (PLS) regression using the NIPALS
(Nonlinear Iterative Partial Least Squares) algorithm. This method
estimates the latent components (scores, loadings, weights) by
iteratively updating the X and Y score directions until convergence. It
is suitable for cases where the number of predictors is large or
predictors are highly collinear.

## Usage

``` r
NIPALS.pls(x, y, n.components = NULL)
```

## Arguments

- x:

  A numeric matrix or data frame of predictors (X). Should have
  dimensions n × p.

- y:

  A numeric matrix or data frame of response variables (Y). Should have
  dimensions n × q.

- n.components:

  Integer specifying the number of PLS components to extract. If NULL,
  it defaults to `qr(x)$rank`.

## Value

A list with the following elements:

- model.type:

  Character string indicating the model type ("PLS Regression").

- T:

  Matrix of X scores (n × H).

- U:

  Matrix of Y scores (n × H).

- W:

  Matrix of X weights (p × H).

- C:

  Matrix of normalized Y weights (q × H).

- P_loadings:

  Matrix of X loadings (p × H).

- Q_loadings:

  Matrix of Y loadings (q × H).

- B_vector:

  Vector of regression scalars (length H), one for each component.

- coefficients:

  Matrix of regression coefficients in original data scale (p × q).

- intercept:

  Vector of intercepts (length q). Always zero here due to centering.

- X_explained:

  Percent of total X variance explained by each component.

- Y_explained:

  Percent of total Y variance explained by each component.

- X_cum_explained:

  Cumulative X variance explained.

- Y_cum_explained:

  Cumulative Y variance explained.

## Details

The algorithm standardizes both `x` and `y` using z-score normalization.
It then performs the following for each of the `n.components` latent
variables:

1.  Initializes a random response score vector \\u\\.

2.  Iteratively:

    - Updates the X weight vector \\w = E^\top u\\, normalized.

    - Computes the X score \\t = E w\\, normalized.

    - Updates the Y loading \\q = F^\top t\\, normalized.

    - Updates the response score \\u = F q\\.

    - Repeats until \\t\\ converges below a tolerance threshold.

3.  Computes scalar regression coefficient \\b = t^\top u\\.

4.  Deflates residual matrices \\E\\ and \\F\\ to remove current
    component contribution.

After component extraction, the final regression coefficient matrix
\\B\_{original}\\ is computed and rescaled to the original data units.
Explained variance is also computed component-wise and cumulatively.

## References

Wold, H., & Lyttkens, E. (1969). Nonlinear iterative partial least
squares (NIPALS) estimation procedures. *Bulletin of the International
Statistical Institute*, 43, 29–51.

## Examples

``` r
if (FALSE) { # \dontrun{
X <- matrix(rnorm(100 * 10), 100, 10)
Y <- matrix(rnorm(100 * 2), 100, 2)
model <- pls.regression(X, Y, n.components = 3, calc.method = "NIPALS")
model$coefficients
} # }
```
