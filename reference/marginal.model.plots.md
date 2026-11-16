# Snazzy Marginal Model Plots

Draws marginal model plots for a linear model, the same plots as
`car::mmps(model)`, as a single faceted ggplot2 plot styled with
[`snazzieR.theme()`](https://detectivefierce.github.io/snazzieR/reference/snazzieR.theme.md).
Only ggplot2 is required; car is not needed.

## Usage

``` r
marginal.model.plots(model, fitted = TRUE, ncol = NULL, title = NULL)
```

## Arguments

- model:

  A fitted `lm` object.

- fitted:

  Logical; include the panel against the fitted values (default `TRUE`).

- ncol:

  Number of panel columns. Defaults to car's layout.

- title:

  Plot title. Defaults to `"Marginal Model Plots"` (or
  `"Marginal Model Plot"` for a single panel), as in car.

## Value

A `ggplot` object. Its title is drawn as the legend title, so the
Data/Model key sits to the right of it.

## Details

For each eligible term in the model, and for the fitted values, the
response is plotted against that variable together with two smooths:

- Data:

  (solid) a loess smooth of the response on the variable;

- Model:

  (dashed) a loess smooth of the model's fitted values on the variable.

If the model is adequate the two smooths should agree. The smooths match
those drawn by car: [`loess`](https://rdrr.io/r/stats/loess.html) with
`span = 2/3`, `degree = 1`, `family = "symmetric"` and four robustness
iterations, evaluated at 50 equally spaced points.

As in `car::mmps()`, factors and interaction terms are skipped, and
matrix terms such as [`poly()`](https://rdrr.io/r/stats/poly.html) or
spline bases are replaced by their fitted linear combination
(`predict(model, type = "terms")`). The panel layout follows car's
defaults (e.g. 3 x 3 for 7 to 9 panels).

## See also

[`diagnostics.plots`](https://detectivefierce.github.io/snazzieR/reference/diagnostics.plots.md)

## Examples

``` r
model <- lm(mpg ~ wt + hp + qsec, data = mtcars)
marginal.model.plots(model)


# Label which model the plots belong to
marginal.model.plots(model, title = "Marginal Model Plots: Fuel Economy")
```
