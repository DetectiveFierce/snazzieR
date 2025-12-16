# Format Ridge Model Output as LaTeX Tables

Formats and displays ridge regression model output from
[`ridge.regression()`](https://jesusbutforgaypeople.github.io/snazzieR/reference/ridge.regression.md)
as LaTeX tables for PDF rendering or plain text for console viewing.

## Usage

``` r
ridge.summary(x, ..., include.cv.trace = TRUE, latex = TRUE)
```

## Arguments

- x:

  A ridge model object returned by
  [`ridge.regression()`](https://jesusbutforgaypeople.github.io/snazzieR/reference/ridge.regression.md)
  (class `"ridge.model"`).

- ...:

  Further arguments passed to or from methods (unused).

- include.cv.trace:

  Logical. Whether to include cross-validation trace information.
  Default is `TRUE`.

- latex:

  Logical; if `TRUE` (default), returns LaTeX-formatted tables using
  `kableExtra`. If `FALSE`, prints plain-text summary tables to the
  console.

## Value

If `latex = TRUE`, returns a
[`knitr::asis_output`](https://rdrr.io/pkg/knitr/man/asis_output.html)
object (LaTeX code) for PDF rendering. If `latex = FALSE`, prints
formatted summary tables to the console and returns the underlying data
frames.

## Examples

``` r
# Load example data
data(mtcars)

# Fit ridge regression model
ridge.fit <- ridge.regression(mpg ~ wt + hp + disp, data = mtcars)

# Print a LaTeX-formatted summary
ridge.summary(ridge.fit, include.cv.trace = FALSE)
#> [1] "\\begin{minipage}[t]{0.48\\linewidth}\n\\begin{table}[H]\n\\centering\n\\caption{Ridge Model Information}\n\\centering\n\\begin{tabular}[t]{|>{}l>{}l|}\n\\toprule\nParameter & Value\\\\\n\\midrule\n\\textbf{Optimal Lambda} & 6.195699\\\\\n\\textbf{CV-MSE} & 7.555243\\\\\n\\textbf{Training MSE} & 6.525974\\\\\n\\textbf{Number of Predictors} & 3\\\\\n\\textbf{CV Folds} & 5\\\\\n\\textbf{Intercept} & 20.090625\\\\\n\\bottomrule\n\\end{tabular}\n\\end{table}\n\\end{minipage}\\begin{minipage}[t]{0.48\\linewidth}\n\\begin{table}[H]\n\\centering\n\\caption{Ridge Regression Coefficients}\n\\centering\n\\begin{tabular}[t]{|>{}ll>{}l|}\n\\toprule\nPredictor & Coefficient & Std.~Error\\\\\n\\midrule\n\\textbf{wt} & -2.444446 & 0.444444\\\\\n\\textbf{hp} & -1.667335 & 0.457401\\\\\n\\textbf{disp} & -1.349117 & 0.428700\\\\\n\\bottomrule\n\\end{tabular}\n\\end{table}\n\\end{minipage}\n\n\\begin{table}[H]\n\\centering\n\\caption{Variable Standardization Information}\n\\centering\n\\begin{tabular}[t]{|>{}ll>{}l|}\n\\toprule\nVariable & Mean & Std..Dev.\\\\\n\\midrule\n\\textbf{wt} & 3.21725 & 0.978457\\\\\n\\textbf{hp} & 146.68750 & 68.562868\\\\\n\\textbf{disp} & 230.72188 & 123.938694\\\\\n\\textbf{Response (y)} & 20.09062 & N/A\\\\\n\\bottomrule\n\\end{tabular}\n\\end{table}"
#> attr(,"class")
#> [1] "knit_asis"
#> attr(,"knit_cacheable")
#> [1] NA

# Print a plain-text summary
ridge.summary(ridge.fit, include.cv.trace = FALSE, latex = FALSE)
#> === Ridge Model Information ===
#> 
#> 
#> Parameter              Value     
#> ---------------------  ----------
#> Optimal Lambda         6.195699  
#> CV-MSE                 7.555243  
#> Training MSE           6.525974  
#> Number of Predictors   3         
#> CV Folds               5         
#> Intercept              20.090625 
#> 
#> === Ridge Regression Coefficients ===
#> 
#> 
#> Predictor    Coefficient   Std.Error
#> ----------  ------------  ----------
#> wt             -2.444446    0.444444
#> hp             -1.667335    0.457401
#> disp           -1.349117    0.428700
#> 
#> === Variable Standardization Information ===
#> 
#> 
#> Variable             Mean  Std.Dev.   
#> -------------  ----------  -----------
#> wt                3.21725  0.978457   
#> hp              146.68750  68.562868  
#> disp            230.72188  123.938694 
#> Response (y)     20.09062  N/A        
#> 
```
