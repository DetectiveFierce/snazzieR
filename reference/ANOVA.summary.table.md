# Generate a Summary Table for ANOVA Results

This function creates a summary table for ANOVA results, including
degrees of freedom, sum of squares, mean squares, F-values, and
p-values. The table can be output as either LaTeX (for PDF reports) or
plain text (for console viewing).

## Usage

``` r
ANOVA.summary.table(model, caption, latex = TRUE)
```

## Arguments

- model:

  A model object for which ANOVA results are computed (e.g., output from
  \`lm()\` or \`aov()\`).

- caption:

  A character string to be used as the caption for the table.

- latex:

  Logical; if \`TRUE\`, returns a LaTeX-formatted table using
  \`kableExtra\`. If \`FALSE\`, prints a plain-text version to the
  console.

## Value

If \`latex = TRUE\`, a LaTeX-formatted table object. If \`latex =
FALSE\`, prints the summary table and returns it (invisibly).

## Examples

``` r
# Fit a linear model
model <- lm(mpg ~ wt + hp, data = mtcars)

# Generate a plain-text ANOVA summary table
ANOVA.summary.table(model, caption = "ANOVA Summary", latex = FALSE)
#>        Term Df    Sum.Sq   Mean.Sq   F.Value P.Value Signif.
#> 1        wt  1 847.72525 847.72525 126.04109       0      :3
#> 2        hp  1  83.27418  83.27418  12.38133 0.00145      :)
#> 3 Residuals 29 195.04775   6.72578                        :3
```
