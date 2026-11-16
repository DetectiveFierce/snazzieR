# Snazzy Regression Diagnostic Plots

Draws the four standard diagnostic plots for a linear model (the same
panels as `plot(model)` for an `lm` fit) as a 2 x 2 grid of ggplot2
plots styled with
[`snazzieR.theme()`](https://detectivefierce.github.io/snazzieR/reference/snazzieR.theme.md).

## Usage

``` r
diagnostics.plots(model, id.n = 3, cook.levels = c(0.5, 1))

# S3 method for class 'snazzieR_plot_grid'
print(x, ...)
```

## Arguments

- model:

  A fitted `lm` object.

- id.n:

  Number of extreme points to label in each panel (default 3).

- cook.levels:

  Cook's distance levels drawn as contours in the leverage panel
  (default `c(0.5, 1)`).

- x:

  A `"snazzieR_plot_grid"` object.

- ...:

  Unused.

## Value

An object of class `"snazzieR_plot_grid"`: a list whose `plots` element
holds the four `ggplot` objects (named `residuals.fitted`, `qq`,
`scale.location` and `residuals.leverage`). Printing it draws the 2 x 2
grid; individual panels can be printed or modified on their own.

## Details

The panels reproduce [`plot.lm`](https://rdrr.io/r/stats/plot.lm.html)
with its default `which = c(1, 2, 3, 5)`:

1.  **Residuals vs Fitted**: residuals against fitted values with a
    [`lowess`](https://rdrr.io/r/stats/lowess.html) smooth (`f = 2/3`,
    `iter = 3`) and a reference line at zero.

2.  **Q-Q Residuals**: standardized residuals against theoretical normal
    quantiles ([`ppoints`](https://rdrr.io/r/stats/ppoints.html)) with
    the line through the first and third quartiles, as drawn by
    [`qqline`](https://rdrr.io/r/stats/qqnorm.html).

3.  **Scale-Location**: \\\sqrt{\|\textrm{standardized residuals}\|}\\
    against fitted values with a lowess smooth.

4.  **Residuals vs Leverage**: standardized residuals against leverage
    (hat values), with Cook's distance contours at `cook.levels`.

As in `plot.lm`, the `id.n` most extreme observations in each panel are
labelled with their observation numbers (placed so that labels do not
overlap), observations with zero weight are dropped, and observations
with leverage one are omitted from the standardized-residual panels.

## See also

[`plot.lm`](https://rdrr.io/r/stats/plot.lm.html),
[`marginal.model.plots`](https://detectivefierce.github.io/snazzieR/reference/marginal.model.plots.md)

## Examples

``` r
model <- lm(mpg ~ wt + hp, data = mtcars)
diagnostics.plots(model)


# A single panel
diagnostics.plots(model)$plots$qq
```
