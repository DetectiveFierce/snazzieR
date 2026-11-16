# Generate a Summary Table for a Linear Model

This function creates a summary table for a linear model, including
estimated coefficients, standard errors, p-values with significance
codes, and model statistics such as MSE and R-squared. The table can be
output as either LaTeX (for PDF reports) or plain text (for console
viewing).

## Usage

``` r
model.summary.table(model, title = "Model Summary", latex = TRUE, caption)
```

## Arguments

- model:

  A linear model object (typically the result of \`lm()\`).

- title:

  A character string used as the table's title (its LaTeX caption).
  Defaults to `"Model Summary"`. The fitted model equation is typeset on
  its own centered line between the title and the table.

- latex:

  Logical; if \`TRUE\` (default), returns a LaTeX-formatted table using
  \`kableExtra\`. If \`FALSE\`, prints plain-text summary tables to the
  console.

- caption:

  Deprecated alias for `title`, kept so existing code keeps working.

## Value

If \`latex = TRUE\`, returns a LaTeX-formatted \`kableExtra\` table
object (of class `"snazzieR_table"`, which also previews nicely when a
chunk is run interactively; see
[`snazzieR_table`](https://detectivefierce.github.io/snazzieR/reference/snazzieR_table.md)).
If \`latex = FALSE\`, prints formatted summary tables to the console and
returns the underlying data frame.

## Examples

``` r
# Fit a linear model
model <- lm(mpg ~ wt + hp, data = mtcars)

# Print a plain-text version to the console
model.summary.table(model, title = "Linear Model Summary", latex = FALSE)
#> == Linear Model Summary ==
#> Equation: mpg = 37.23 - 3.878*wt - 0.03177*hp
#> 
#> Coefficient Table:
#> 
#> 
#> Term           Estimate   Std.Error   P.Value  Signif. 
#> ------------  ---------  ----------  --------  --------
#> (Intercept)    37.22727     1.59879   0.00000  :3      
#> wt             -3.87783     0.63273   0.00000  :3      
#> hp             -0.03177     0.00903   0.00145  :)      
#> 
#> Model Statistics:
#> 
#> 
#> Statistic            Value
#> ---------------  ---------
#> MSE                6.09524
#> MSE adj.           6.72578
#> df                29.00000
#> R-squared          0.82679
#> R-squared adj.     0.81484
```
