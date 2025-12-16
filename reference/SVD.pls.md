# Partial Least Squares Regression via SVD (Internal)

This function is called internally by
[`pls.regression`](https://jesusbutforgaypeople.github.io/snazzieR/reference/pls.regression.md)
and is not intended to be used directly. Use
`pls.regression(..., calc.method = "SVD")` instead.

Performs Partial Least Squares (PLS) regression using the Singular Value
Decomposition (SVD) of the cross-covariance matrix. This method
estimates the latent components by identifying directions in the
predictor and response spaces that maximize their covariance, using the
leading singular vectors of the matrix \\R = X^\top Y\\.

## Usage

``` r
SVD.pls(x, y, n.components = NULL)
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
  defaults to `qr(x)$rank`.

## Value

A list containing:

- model.type:

  Character string indicating the model type ("PLS Regression").

- T:

  Matrix of predictor scores (n × H).

- U:

  Matrix of response scores (n × H).

- W:

  Matrix of predictor weights (p × H).

- C:

  Matrix of normalized response weights (q × H).

- P_loadings:

  Matrix of predictor loadings (p × H).

- Q_loadings:

  Matrix of response loadings (q × H).

- B_vector:

  Vector of scalar regression weights (length H).

- coefficients:

  Matrix of final regression coefficients in the original scale (p × q).

- intercept:

  Vector of intercepts (length q). All zeros due to centering.

- X_explained:

  Percent of total X variance explained by each component.

- Y_explained:

  Percent of total Y variance explained by each component.

- X_cum_explained:

  Cumulative X variance explained.

- Y_cum_explained:

  Cumulative Y variance explained.

## Details

The algorithm begins by z-scoring both `x` and `y` (centering and
scaling to unit variance). The initial residual matrices are set to the
scaled values: `E = X_scaled`, `F = Y_scaled`.

For each component h = 1, ..., H:

1.  Compute the cross-covariance matrix \\R = E^\top F\\.

2.  Perform SVD on \\R = U D V^\top\\.

3.  Extract the first singular vectors: \\w = U\[,1\]\\, \\q =
    V\[,1\]\\.

4.  Compute scores: \\t = E w\\ (normalized), \\u = F q\\.

5.  Compute loadings: \\p = E^\top t\\, regression scalar \\b = t^\top
    u\\.

6.  Deflate residuals: \\E \gets E - t p^\top\\, \\F \gets F - b t
    q^\top\\.

After all components are extracted, a post-processing step removes
components with zero regression weight. The scaled regression
coefficients are computed using the Moore–Penrose pseudoinverse of the
loading matrix \\P\\, and then rescaled to the original variable units.

## References

Abdi, H., & Williams, L. J. (2013). Partial least squares methods:
Partial least squares correlation and partial least square regression.
*Methods in Molecular Biology (Clifton, N.J.)*, 930, 549–579.
[doi:10.1007/978-1-62703-059-5_23](https://doi.org/10.1007/978-1-62703-059-5_23)

de Jong, S. (1993). SIMPLS: An alternative approach to partial least
squares regression. *Chemometrics and Intelligent Laboratory Systems*,
18(3), 251–263.
[doi:10.1016/0169-7439(93)85002-X](https://doi.org/10.1016/0169-7439%2893%2985002-X)

## Examples

``` r
if (FALSE) { # \dontrun{
X <- matrix(rnorm(100 * 10), 100, 10)
Y <- matrix(rnorm(100 * 2), 100, 2)
model <- pls.regression(X, Y, n.components = 3, calc.method = "SVD")
model$coefficients
} # }
```
