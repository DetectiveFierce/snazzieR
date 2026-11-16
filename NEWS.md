# snazzieR 0.1.3

## Regression diagnostics

Four new functions cover the checks that follow fitting a model. They
reproduce output from base R and car, and car does not need to be installed.

* `diagnostics.plots()` draws the four `plot(lm)` panels (Residuals vs Fitted,
  Q-Q, Scale-Location, and Residuals vs Leverage with Cook's distance
  contours) as a 2 x 2 grid of ggplots in `snazzieR.theme()`. The most extreme
  observations in each panel are labelled with their observation numbers, and
  the labels are placed so they do not overlap each other or nearby points.
  Each panel is also available on its own through `$plots`.
* `marginal.model.plots()` draws the plots of `car::mmps()` as one faceted
  ggplot: the response against each numeric term and against the fitted
  values, with a loess smooth of the data and a loess smooth of the model's
  fitted values. `title` says which model the plots belong to.
* `unusual.points.table()` lists the observations of an `lm` or `glm` fit that
  are high-leverage points, outliers, influential points or bad leverage
  points. Each row gives the observed and fitted response, leverage,
  standardized residual and Cook's distance. `flag` chooses which criteria
  count, `n.max` keeps the rows with the largest Cook's distances, and `id`
  labels the observations.
* `VIF.table()` reports variance inflation factors sorted from highest to
  lowest, with 1/VIF, GVIF, adjusted GVIF (and its df) and a moderate or
  severe flag. Factors and other multi-df terms get generalized VIFs that
  match `car::vif()`. `cols` picks the columns.

Both tables return LaTeX by default and plain text with `latex = FALSE`, like
the other summary tables.

## Table previews in RStudio and Positron

* LaTeX tables from `model.summary.table()`, `ANOVA.summary.table()`,
  `eigen.summary()`, `pls.summary()`, `ridge.summary()`,
  `format.pls(latex = TRUE)`, `VIF.table()` and `unusual.points.table()` now
  show an HTML preview when an R Markdown chunk is run interactively, for
  example with the "Run" button. In 0.1.2 the viewer stayed blank. When a
  document is knitted, the table goes to knitr as before.
* The `snazzieR.preview` option switches the preview between HTML, plain text
  and the raw LaTeX source. See `?snazzieR_table`.

## Changes to existing tables

* The `caption` argument of `model.summary.table()`, `ANOVA.summary.table()`
  and `eigen.summary()` is now called `title`. `caption` still works as an
  alias, so existing documents run unchanged.
* `model.summary.table()` and `ANOVA.summary.table()` have default titles
  ("Model Summary" and "ANOVA Summary"), so `title` can be left out.
* `model.summary.table()` typesets the fitted equation in LaTeX math on its
  own centered line between the title and the table, for example
  `log(PrizeMoney) = 0.1943 - 0.00353 DrivingAccuracy + ...`. Negative
  coefficients are subtracted (0.1.2 printed `+ -0.004`), and coefficients
  show four significant digits. The title is a plain caption again, so it is
  centered over the whole table.

## Bug fixes

* `model.summary.table()` and `model.equation()` split the equation in two
  when the response was transformed, as in `log(y)`. One table then had two
  captions and LaTeX reported a "multiply defined" label.
* `ANOVA.summary.table()` gave the Residuals row a `:3` significance code
  although that row has no p-value.
* `model.summary.table(latex = FALSE)` printed blank padding rows and a
  duplicated column of row names in the coefficient table.
* The significance footnote under `model.summary.table()` and
  `ANOVA.summary.table()` read `>0.001` where it meant `<0.001`.
* Table titles printed as literal LaTeX source (`\textbf{...}`) under knitr
  1.52, which escapes special characters in captions. Titles are now set the
  same way under every knitr version.
* `color.ref()` restores the user's graphical parameters on exit.

## Dependencies

* dplyr is no longer imported. The package uses the native `|>` pipe.
* `graphics`, `grDevices`, `grid` and `htmltools` are now declared in
  `Imports`, and ggplot2 must be at least 3.5.0.
* `DESCRIPTION` gains a `BugReports` field.

# snazzieR 0.1.2

* Fixed vignette issues and added the package website.
