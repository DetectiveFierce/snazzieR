# Variance Inflation Factor Table

Computes variance inflation factors (VIFs) for the terms of a regression
to diagnose multicollinearity, and returns them as a LaTeX table (for
PDF reports) or plain text (for the console), like the other snazzieR
summary tables. car is not required.

## Usage

``` r
VIF.table(
  model,
  title = "Variance Inflation Factors",
  latex = TRUE,
  cols = "all",
  moderate = 5,
  severe = 10,
  digits = 4
)
```

## Arguments

- model:

  A fitted `lm` or `glm` object with at least two terms.

- title:

  Table title (its LaTeX caption). Defaults to
  `"Variance Inflation Factors"`.

- latex:

  Logical; if `TRUE` (default) returns a LaTeX table. If `FALSE`, prints
  a plain-text table and returns the underlying data frame invisibly.

- cols:

  Columns to show: `"all"` (default) or any combination of `"VIF"`,
  `"1/VIF"`, `"GVIF"` and `"adj. GVIF"`. `Term` and `Flag` are always
  included.

- moderate, severe:

  VIF cutoffs for flagging moderate and severe multicollinearity.
  Default 5 and 10.

- digits:

  Number of significant digits shown. Defaults to 4.

## Value

If `latex = TRUE`, a LaTeX table of class `"snazzieR_table"` (see
[`snazzieR_table`](https://detectivefierce.github.io/snazzieR/reference/snazzieR_table.md)
for interactive previews). If `latex = FALSE`, the table is printed and
a data frame of the shown columns, one row per term, is returned
invisibly.

## Details

VIFs are computed from the correlation matrix of the estimated
coefficients, exactly as `car::vif()` does, so they are valid for
weighted `lm` fits and for `glm` fits. For a numeric predictor,
\\\mathrm{VIF}\_j = 1/(1 - R^2_j)\\, where \\R^2_j\\ is from regressing
that predictor on all the others.

The available columns are:

- VIF:

  The variance inflation factor. Terms with more than one coefficient
  (factors, [`poly()`](https://rdrr.io/r/stats/poly.html), splines) have
  no ordinary VIF, so their VIF is reported as \\(\textrm{adj.
  GVIF})^2\\, which is on the same scale and equals the ordinary VIF for
  one-df terms.

- 1/VIF:

  The tolerance, \\1 - R^2_j\\.

- GVIF:

  The generalized VIF of Fox and Monette (1992); equal to the VIF for
  one-df terms.

- adj. GVIF:

  \\\mathrm{GVIF}^{1/(2\\\mathrm{Df})}\\, comparable across terms with
  different degrees of freedom. Each cell also shows the term's degrees
  of freedom, e.g. `1.547 (df = 2)`.

The `Term` and `Flag` columns are always shown. Terms are flagged
*moderate* when the VIF exceeds `moderate` (default 5) and *severe* when
it exceeds `severe` (default 10). Rows are sorted from the highest VIF
to the lowest. Aliased (perfectly collinear) coefficients are dropped
and listed in the notes under the table.

## References

Fox, J. and Monette, G. (1992). Generalized collinearity diagnostics.
*Journal of the American Statistical Association*, 87, 178–183.

## See also

[`unusual.points.table`](https://detectivefierce.github.io/snazzieR/reference/unusual.points.table.md),
[`model.summary.table`](https://detectivefierce.github.io/snazzieR/reference/model.summary.table.md)

## Examples

``` r
model <- lm(mpg ~ wt + hp + disp + qsec, data = mtcars)
VIF.table(model, latex = FALSE)
#> == Variance Inflation Factors ==
#> 
#> 
#> Term   VIF     1/VIF    GVIF    adj. GVIF        Flag     
#> -----  ------  -------  ------  ---------------  ---------
#> disp   7.985   0.1252   7.985   2.826 (df = 1)   moderate 
#> wt     6.917   0.1446   6.917   2.63 (df = 1)    moderate 
#> hp     5.167   0.1935   5.167   2.273 (df = 1)   moderate 
#> qsec   3.133   0.3192   3.133   1.77 (df = 1)             
#> 
#> Moderate: VIF > 5.  Severe: VIF > 10.  Mean VIF = 5.8.
#> adj. GVIF = GVIF^(1/(2 Df)).

# Factors get generalized VIFs
VIF.table(lm(mpg ~ wt + hp + factor(cyl), data = mtcars), latex = FALSE)
#> == Variance Inflation Factors ==
#> 
#> 
#> Term          VIF     1/VIF    GVIF    adj. GVIF        Flag 
#> ------------  ------  -------  ------  ---------------  -----
#> hp            3.496   0.286    3.496   1.87 (df = 1)         
#> wt            2.581   0.3875   2.581   1.607 (df = 1)        
#> factor(cyl)   2.26    0.4426   5.106   1.503 (df = 2)        
#> 
#> Moderate: VIF > 5.  Severe: VIF > 10.  Mean VIF = 2.78.
#> adj. GVIF = GVIF^(1/(2 Df)).  For multi-df terms, VIF = (adj. GVIF)^2.

# Only some columns
VIF.table(model, latex = FALSE, cols = c("VIF", "1/VIF"))
#> == Variance Inflation Factors ==
#> 
#> 
#> Term   VIF     1/VIF    Flag     
#> -----  ------  -------  ---------
#> disp   7.985   0.1252   moderate 
#> wt     6.917   0.1446   moderate 
#> hp     5.167   0.1935   moderate 
#> qsec   3.133   0.3192            
#> 
#> Moderate: VIF > 5.  Severe: VIF > 10.  Mean VIF = 5.8.

# LaTeX table for a PDF report
tbl <- VIF.table(model, title = "Collinearity Check")
```
