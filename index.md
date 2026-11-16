# snazzieR

Chic and sleek functions for beautiful statisticians.

snazzieR formats regression output for R Markdown reports. Its tables
come out as LaTeX for PDF documents or as plain text for the console,
and its plots share one ggplot2 theme and a palette of 35 named colors.

## Installation

``` r

# Released version, from CRAN
install.packages("snazzieR")

# Development version, from GitHub
# install.packages("remotes")
remotes::install_github("DetectiveFierce/snazzieR")
```

## Functions

| Task | Functions |
|----|----|
| Summarize a linear model | [`model.summary.table()`](https://detectivefierce.github.io/snazzieR/reference/model.summary.table.md), [`ANOVA.summary.table()`](https://detectivefierce.github.io/snazzieR/reference/ANOVA.summary.table.md), [`model.equation()`](https://detectivefierce.github.io/snazzieR/reference/model.equation.md) |
| Check a fitted model | [`diagnostics.plots()`](https://detectivefierce.github.io/snazzieR/reference/diagnostics.plots.md), [`marginal.model.plots()`](https://detectivefierce.github.io/snazzieR/reference/marginal.model.plots.md), [`unusual.points.table()`](https://detectivefierce.github.io/snazzieR/reference/unusual.points.table.md), [`VIF.table()`](https://detectivefierce.github.io/snazzieR/reference/VIF.table.md) |
| Partial least squares | [`pls.regression()`](https://detectivefierce.github.io/snazzieR/reference/pls.regression.md), [`SVD.pls()`](https://detectivefierce.github.io/snazzieR/reference/SVD.pls.md), [`NIPALS.pls()`](https://detectivefierce.github.io/snazzieR/reference/NIPALS.pls.md), [`pls.summary()`](https://detectivefierce.github.io/snazzieR/reference/pls.summary.md) |
| Ridge regression | [`ridge.regression()`](https://detectivefierce.github.io/snazzieR/reference/ridge.regression.md), [`ridge.summary()`](https://detectivefierce.github.io/snazzieR/reference/ridge.summary.md) |
| Eigenvalues of a correlation or covariance matrix | [`eigen.summary()`](https://detectivefierce.github.io/snazzieR/reference/eigen.summary.md) |
| Plot styling | [`snazzieR.theme()`](https://detectivefierce.github.io/snazzieR/reference/snazzieR.theme.md), [`color.ref()`](https://detectivefierce.github.io/snazzieR/reference/color.ref.md), and colors such as `Red` and `Dark.Blue` |

## Example

``` r

library(snazzieR)

model <- lm(mpg ~ wt + hp, data = mtcars)

# Coefficients, fit statistics and the fitted equation in one table.
# Returns LaTeX by default; latex = FALSE prints to the console.
model.summary.table(model, title = "Fuel Economy", latex = FALSE)

# The four plot(lm) panels as ggplots
diagnostics.plots(model)

# Observations worth a second look, labelled by car name
unusual.points.table(model, latex = FALSE, id = rownames(mtcars))

# Variance inflation factors
VIF.table(model, latex = FALSE)
```

![Residuals vs Fitted, Q-Q, Scale-Location and Residuals vs Leverage
panels drawn by
diagnostics.plots()](reference/figures/README-diagnostics.png)

## Table previews

A LaTeX table has nothing to show when you run a chunk with the “Run”
button, so snazzieR tables print an HTML preview in RStudio and Positron
and a plain-text preview in other interactive sessions. Knitting
produces the LaTeX. Set `options(snazzieR.preview = "html")`, `"text"`
or `"latex"` to pick one;
[`?snazzieR_table`](https://detectivefierce.github.io/snazzieR/reference/snazzieR_table.md)
has the details.

## Documentation

- Guide with rendered examples: <https://finitesample.space/snazzier>
- Function reference and articles:
  <https://detectivefierce.github.io/snazzieR/>
- Changes in each release:
  [NEWS.md](https://detectivefierce.github.io/snazzieR/NEWS.md)

Report bugs at <https://github.com/DetectiveFierce/snazzieR/issues>.

## License

MIT
