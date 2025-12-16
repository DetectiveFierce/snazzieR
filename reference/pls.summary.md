# Format PLS Model Output as LaTeX Tables

Formats and displays Partial Least Squares (PLS) model output from
[`pls.regression()`](https://jesusbutforgaypeople.github.io/snazzieR/reference/pls.regression.md)
as LaTeX tables for PDF rendering.

## Usage

``` r
pls.summary(x, ..., include.scores = TRUE)
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

## Value

Returns a
[`knitr::asis_output`](https://rdrr.io/pkg/knitr/man/asis_output.html)
object (LaTeX code) for PDF rendering.

## Examples

``` r
# Load example data
data(mtcars)

# Prepare data for PLS regression
X <- mtcars[, c("wt", "hp", "disp")]
Y <- mtcars[, "mpg", drop = FALSE]

# Fit PLS model with 2 components
pls.fit <- pls.regression(X, Y, n.components = 2)

# Print a LaTeX-formatted summary
pls.summary(pls.fit, include.scores = FALSE)
#> [1] "\\begin{minipage}[t]{0.48\\linewidth}\n\\begin{table}[H]\n\\centering\n\\caption{X Weights (W)}\n\\centering\n\\begin{tabular}[t]{|>{}c>{}c|}\n\\toprule\nComp 1 & Comp 2\\\\\n\\midrule\n-0.6025393 & -0.7867505\\\\\n-0.5390041 & 0.2772819\\\\\n-0.5885754 & 0.5514875\\\\\n\\bottomrule\n\\end{tabular}\n\\end{table}\n\\end{minipage}\\begin{minipage}[t]{0.48\\linewidth}\n\\begin{table}[H]\n\\centering\n\\caption{Y Weights (C)}\n\\centering\n\\begin{tabular}[t]{>{}c|}\n\\toprule\nComp 1\\\\\n\\midrule\n1\\\\\n1\\\\\n\\bottomrule\n\\end{tabular}\n\\end{table}\n\\end{minipage}\n\n\\begin{minipage}[t]{0.48\\linewidth}\n\\begin{table}[H]\n\\centering\n\\caption{X Loadings (P)}\n\\centering\n\\begin{tabular}[t]{|>{}c>{}c|}\n\\toprule\nComp 1 & Comp 2\\\\\n\\midrule\n-5.151497 & -2.0903138\\\\\n-4.877289 & 1.9874167\\\\\n-5.394037 & 0.3198749\\\\\n\\bottomrule\n\\end{tabular}\n\\end{table}\n\\end{minipage}\\begin{minipage}[t]{0.48\\linewidth}\n\\begin{table}[H]\n\\centering\n\\caption{Y Loadings (Q)}\n\\centering\n\\begin{tabular}[t]{|>{}c>{}c|}\n\\toprule\nComp 1 & Comp 2\\\\\n\\midrule\n1 & 1\\\\\n\\bottomrule\n\\end{tabular}\n\\end{table}\n\\end{minipage}\n\n\\begin{table}[H]\n\\centering\n\\caption{Regression Scalars (b)}\n\\centering\n\\begin{tabular}[t]{|>{}c>{}c|}\n\\toprule\nComponent & Estimate\\\\\n\\midrule\n1 & 5.0114360\\\\\n2 & 0.5792758\\\\\n\\bottomrule\n\\end{tabular}\n\\end{table}\n\n\\begin{table}[H]\n\\centering\n\\caption{Regression Coefficients (Original Scale)}\n\\centering\n\\begin{tabular}[t]{>{}l|c}\n\\toprule\n  & Estimate\\\\\n\\midrule\nwt & -2.9703661\\\\\nhp & -0.0144352\\\\\ndisp & -0.0155630\\\\\n\\bottomrule\n\\end{tabular}\n\\end{table}\n\n\\begin{table}[H]\n\\centering\n\\caption{Variance Explained by Components (X)}\n\\centering\n\\resizebox{\\ifdim\\width>\\linewidth\\linewidth\\else\\width\\fi}{!}{\n\\begin{tabular}[t]{|>{\\centering\\arraybackslash}p{3cm}c>{}c|}\n\\toprule\nLatent Vector & Explained Variance & Cumulative\\\\\n\\midrule\n1 & 85.3995\\% & 85.3995\\%\\\\\n2 & 9.0554\\% & 94.4549\\%\\\\\n\\bottomrule\n\\end{tabular}}\n\\end{table}\n\n\\begin{table}[H]\n\\centering\n\\caption{Variance Explained by Components (Y)}\n\\centering\n\\resizebox{\\ifdim\\width>\\linewidth\\linewidth\\else\\width\\fi}{!}{\n\\begin{tabular}[t]{|>{\\centering\\arraybackslash}p{3cm}c>{}c|}\n\\toprule\nLatent Vector & Explained Variance & Cumulative\\\\\n\\midrule\n1 & 81.0145\\% & 81.0145\\%\\\\\n2 & 1.0825\\% & 82.0969\\%\\\\\n\\bottomrule\n\\end{tabular}}\n\\end{table}"
#> attr(,"class")
#> [1] "knit_asis"
#> attr(,"knit_cacheable")
#> [1] NA
```
