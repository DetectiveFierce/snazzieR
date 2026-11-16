# Table of Unusual Observations in a Regression

Identifies the observations of a fitted regression that should be
investigated – high-leverage points, outliers, influential points and
bad leverage points – and returns them in a table, as LaTeX (for PDF
reports) or plain text (for the console), like the other snazzieR
summary tables.

## Usage

``` r
unusual.points.table(
  model,
  title = "Unusual Observations",
  latex = TRUE,
  id = NULL,
  data = NULL,
  leverage.cutoff = NULL,
  residual.cutoff = 2,
  cook.cutoff = NULL,
  flag = c("leverage", "outlier", "influential"),
  n.max = NULL,
  digits = 4
)
```

## Arguments

- model:

  A fitted `lm` or `glm` object.

- title:

  Table title (its LaTeX caption). Defaults to `"Unusual Observations"`.

- latex:

  Logical; if `TRUE` (default) returns a LaTeX table. If `FALSE`, prints
  a plain-text table and returns the underlying data frame invisibly.

- id:

  Optional labels to identify observations: either the name of a column
  in `data` (e.g. `"Name"`) or a vector with one label per row of the
  data the model was fitted to.

- data:

  The data frame the model was fitted to. Only needed when `id` is a
  column name and the data cannot be recovered from the model's call.

- leverage.cutoff:

  Leverage threshold. Defaults to \\2(p+1)/n\\.

- residual.cutoff:

  Threshold for \\\|\\standardized residual\\\|\\. Defaults to 2.

- cook.cutoff:

  Cook's distance threshold. Defaults to \\4/(n-2)\\.

- flag:

  Which criteria make an observation unusual: any of `"leverage"`,
  `"outlier"` and `"influential"` (default: all three). For example,
  `flag = c("leverage", "outlier")` leaves out points that are only
  flagged by Cook's distance.

- n.max:

  Maximum number of observations to list (default `NULL`, no limit).
  When more are flagged, the `n.max` with the largest Cook's distance
  are kept and the legend says how many were left out.

- digits:

  Number of significant digits shown. Defaults to 4.

## Value

If `latex = TRUE`, a LaTeX table of class `"snazzieR_table"` (see
[`snazzieR_table`](https://detectivefierce.github.io/snazzieR/reference/snazzieR_table.md)
for interactive previews). If `latex = FALSE`, the table is printed and
a data frame with one row per flagged observation (sorted by Cook's
distance) is returned invisibly. Its `"cutoffs"` attribute holds the
thresholds used.

## Details

Diagnostics are computed with
[`hatvalues`](https://rdrr.io/r/stats/influence.measures.html),
[`rstandard`](https://rdrr.io/r/stats/influence.measures.html) and
[`cooks.distance`](https://rdrr.io/r/stats/influence.measures.html), so
the function works for any `lm` fit (including weighted fits, factors,
transformed variables and missing values) and for `glm` fits (using
deviance residuals). Observations with zero weight are excluded, as in
`plot.lm`.

An observation is listed if it meets at least one of these criteria
(defaults follow Sheather, *A Modern Approach to Regression with R*):

- High leverage:

  \\h\_{ii} \> 2(p+1)/n\\, twice the average leverage, where \\p+1\\ is
  the number of estimated coefficients.

- Outlier:

  \\\|r_i\| \> 2\\, where \\r_i\\ is the standardized residual. (For
  large data sets a cutoff of 4 may be more appropriate.)

- Influential:

  Cook's distance \\D_i \> 4/(n-2)\\.

- Bad leverage:

  both high leverage and an outlier.

For each flagged point the table reports its observed and fitted
response, leverage, standardized residual, Cook's distance and flags. A
legend under the table explains the flags and compares the number of
outliers with the number expected by chance.

## See also

[`diagnostics.plots`](https://detectivefierce.github.io/snazzieR/reference/diagnostics.plots.md),
[`model.summary.table`](https://detectivefierce.github.io/snazzieR/reference/model.summary.table.md)

## Examples

``` r
model <- lm(mpg ~ wt + hp, data = mtcars)

# Plain-text table, labelling cars by name
unusual.points.table(model, latex = FALSE, id = rownames(mtcars))
#> == Unusual Observations ==
#> 
#> 
#> Obs                   Observed   Fitted   Leverage   Std. Resid.   Cook's D   Flags                      
#> --------------------  ---------  -------  ---------  ------------  ---------  ---------------------------
#> Chrysler Imperial     14.7       9.192    0.1865     2.355         0.4236     outlier, influential       
#> Maserati Bora         15         12.74    0.3942     1.12          0.272      high leverage, influential 
#> Toyota Corolla        33.9       28.05    0.0995     2.379         0.2084     outlier, influential       
#> Fiat 128              32.4       26.6     0.07991    2.332         0.1574     outlier, influential       
#> Lincoln Continental   10.4       9.363    0.209      0.4497        0.01781    high leverage              
#> Ford Pantera L        15.8       16.55    0.2044     -0.3227       0.00892    high leverage              
#> 
#> Flags: high leverage = h > 0.188 = 2(3)/32 = 2(p+1)/n;  outlier = |std. resid.| > 2;  influential = Cook's D > 0.133;  bad leverage = both.
#> Outliers: 3 of 32 observations have |std. resid.| > 2; about 1.5 would be expected by chance.

# Only the 3 most influential, ignoring points flagged by Cook's D alone
unusual.points.table(model, latex = FALSE, id = rownames(mtcars),
                     flag = c("leverage", "outlier"), n.max = 3)
#> == Unusual Observations ==
#> 
#> 
#> Obs                 Observed   Fitted   Leverage   Std. Resid.   Cook's D   Flags         
#> ------------------  ---------  -------  ---------  ------------  ---------  --------------
#> Chrysler Imperial   14.7       9.192    0.1865     2.355         0.4236     outlier       
#> Maserati Bora       15         12.74    0.3942     1.12          0.272      high leverage 
#> Toyota Corolla      33.9       28.05    0.0995     2.379         0.2084     outlier       
#> 
#> Flags: high leverage = h > 0.188 = 2(3)/32 = 2(p+1)/n;  outlier = |std. resid.| > 2;  bad leverage = both.
#> Outliers: 3 of 32 observations have |std. resid.| > 2; about 1.5 would be expected by chance.
#> Showing the 3 with the largest Cook's D of 6 flagged observations.

# LaTeX table for a PDF report
tbl <- unusual.points.table(model, title = "Cars to Investigate")
```
