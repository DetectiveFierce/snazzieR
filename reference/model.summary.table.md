# Generate a Summary Table for a Linear Model

This function creates a summary table for a linear model, including
estimated coefficients, standard errors, p-values with significance
codes, and model statistics such as MSE and R-squared. The table can be
output as either LaTeX (for PDF reports) or plain text (for console
viewing).

## Usage

``` r
model.summary.table(model, caption, latex = TRUE)
```

## Arguments

- model:

  A linear model object (typically the result of \`lm()\`).

- caption:

  A character string to be used as the caption for the table.

- latex:

  Logical; if \`TRUE\` (default), returns a LaTeX-formatted table using
  \`kableExtra\`. If \`FALSE\`, prints plain-text summary tables to the
  console.

## Value

If \`latex = TRUE\`, returns a LaTeX-formatted \`kableExtra\` table
object. If \`latex = FALSE\`, prints formatted summary tables to the
console and returns the underlying data frame.

## Examples

``` r
# Fit a linear model
model <- lm(mpg ~ wt + hp, data = mtcars)

# Print a plain-text version to the console
model.summary.table(model, caption = "Linear Model Summary", latex = FALSE)
#> == Linear Model Summary ==
#> Equation: mpg = 37.227 + -3.878*wt + -0.032*hp
#> 
#> Coefficient Table:
#> 
#> 
#>               Term          Estimate   Std.Error   P.Value   Signif. 
#> ------------  ------------  ---------  ----------  --------  --------
#> (Intercept)   (Intercept)   37.22727   1.59879     0         :3      
#> wt            wt            -3.87783   0.63273     0         :3      
#> hp            hp            -0.03177   0.00903     0.00145   :)      
#> 1                                                                    
#> 5                                                                    
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
