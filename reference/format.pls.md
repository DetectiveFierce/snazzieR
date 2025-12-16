# Format PLS Model Output as LaTeX or Console Tables

Formats and displays Partial Least Squares (PLS) model output from
[`pls.regression()`](https://jesusbutforgaypeople.github.io/snazzieR/reference/pls.regression.md)
as either LaTeX tables (for PDF rendering) or console-friendly output.

## Usage

``` r
# S3 method for class 'pls'
format(x, ..., include.scores = TRUE, latex = FALSE)
```

## Arguments

- x:

  A list returned by
  [`pls.regression()`](https://jesusbutforgaypeople.github.io/snazzieR/reference/pls.regression.md)
  (class `"pls"`) containing PLS model components.

- ...:

  Further arguments passed to or from methods (unused).

- include.scores:

  Logical. Whether to include score matrices (T and U). Default is
  `TRUE`.

- latex:

  Logical. If `TRUE`, produces LaTeX output (for PDF rendering). If
  `FALSE`, prints to console. Default is `FALSE`.

## Value

When `latex = TRUE`, returns a
[`knitr::asis_output`](https://rdrr.io/pkg/knitr/man/asis_output.html)
object (LaTeX code). When `FALSE`, prints formatted tables to console.
