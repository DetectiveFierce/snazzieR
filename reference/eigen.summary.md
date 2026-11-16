# Summarize Eigenvalues and Eigenvectors of a Covariance Matrix

This function computes the eigenvalues and eigenvectors of a given
covariance matrix, ensures sign consistency in the eigenvectors, and
outputs either a LaTeX table or plaintext summary displaying the
results.

## Usage

``` r
eigen.summary(
  cov.matrix,
  title = "Eigenvectors of Covariance Matrix",
  latex = TRUE,
  caption
)
```

## Arguments

- cov.matrix:

  A square numeric matrix representing the covariance matrix.

- title:

  A character string used as the table's title (default: "Eigenvectors
  of Covariance Matrix").

- latex:

  A logical indicating whether to output LaTeX table (default: TRUE). If
  FALSE, prints as plain text.

- caption:

  Deprecated alias for `title`, kept so existing code keeps working.

## Value

A LaTeX formatted table of class `"snazzieR_table"` (if latex = TRUE;
see
[`snazzieR_table`](https://detectivefierce.github.io/snazzieR/reference/snazzieR_table.md)
for interactive previews) or plaintext console output (if latex =
FALSE).

## Examples

``` r
cov_matrix <- matrix(c(4, 2, 2, 3), nrow = 2)
eigen.summary(cov_matrix, title = "Eigenvalues and Eigenvectors", latex = FALSE)
#> == Eigenvalues and Eigenvectors ==
#> 
#> Eigenvalues:
#> [1] 5.56155 1.43845
#> 
#> Eigenvectors (columns correspond to eigenvalues):
#> 
#>  lambda1    lambda2
#> --------  ---------
#>  0.78821   -0.61541
#>  0.61541    0.78821
#> 
#> Total Variance: 7 
```
