# Generate a Summary Table for ANOVA Results

This function creates a summary table for ANOVA results, including
degrees of freedom, sum of squares, mean squares, F-values, and
p-values. The table can be output as either LaTeX (for PDF reports) or
plain text (for console viewing).

## Usage

``` r
ANOVA.summary.table(model, title = "ANOVA Summary", latex = TRUE, caption)
```

## Arguments

- model:

  A model object for which ANOVA results are computed (e.g., output from
  \`lm()\` or \`aov()\`).

- title:

  A character string used as the table's title (its LaTeX caption).
  Defaults to `"ANOVA Summary"`.

- latex:

  Logical; if \`TRUE\`, returns a LaTeX-formatted table using
  \`kableExtra\`. If \`FALSE\`, prints a plain-text version to the
  console.

- caption:

  Deprecated alias for `title`, kept so existing code keeps working.

## Value

If \`latex = TRUE\`, a LaTeX-formatted table object (of class
`"snazzieR_table"`, which also previews when a chunk is run
interactively; see
[`snazzieR_table`](https://detectivefierce.github.io/snazzieR/reference/snazzieR_table.md)).
If \`latex = FALSE\`, prints the summary table and returns it
(invisibly).

## Examples

``` r
# Fit a linear model
model <- lm(mpg ~ wt + hp, data = mtcars)

# Generate a plain-text ANOVA summary table
ANOVA.summary.table(model, title = "ANOVA Summary", latex = FALSE)
#>        Term Df    Sum.Sq   Mean.Sq   F.Value P.Value Signif.
#> 1        wt  1 847.72525 847.72525 126.04109       0      :3
#> 2        hp  1  83.27418  83.27418  12.38133 0.00145      :)
#> 3 Residuals 29 195.04775   6.72578                          
```
