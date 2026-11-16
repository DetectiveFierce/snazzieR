# Interactive Previews for snazzieR Tables

The LaTeX tables returned by
[`model.summary.table`](https://detectivefierce.github.io/snazzieR/reference/model.summary.table.md),
[`ANOVA.summary.table`](https://detectivefierce.github.io/snazzieR/reference/ANOVA.summary.table.md),
[`eigen.summary`](https://detectivefierce.github.io/snazzieR/reference/eigen.summary.md),
[`pls.summary`](https://detectivefierce.github.io/snazzieR/reference/pls.summary.md),
[`ridge.summary`](https://detectivefierce.github.io/snazzieR/reference/ridge.summary.md)
and
[`format.pls`](https://detectivefierce.github.io/snazzieR/reference/format.pls.md)
carry the class `"snazzieR_table"`. This lets them show a readable
preview when a chunk is run interactively (for example with the play
button in the RStudio or Positron editor), while knitting produces
exactly the same LaTeX as before.

## Usage

``` r
# S3 method for class 'snazzieR_table'
print(x, ...)

# S3 method for class 'snazzieR_table'
knit_print(x, options = list(), ...)
```

## Arguments

- x:

  A `"snazzieR_table"` object.

- ...:

  Further arguments passed to the underlying print method.

- options:

  Chunk options, passed on by knitr.

## Value

`x`, invisibly.

## Details

When a document is being knitted, printing is handed straight to the
underlying knitr/kableExtra method, so compiled output does not change.
Outside of knitting, the preview style is controlled by the option
`snazzieR.preview`:

- `"auto"`:

  (default) An HTML preview in RStudio or Positron, a plain-text preview
  in other interactive sessions, and the raw LaTeX in non-interactive
  sessions.

- `"html"`:

  Always render an HTML preview.

- `"text"`:

  Always print a plain-text preview.

- `"latex"`:

  Always print the raw LaTeX source.

## Examples

``` r
model <- lm(mpg ~ wt + hp, data = mtcars)
tbl <- model.summary.table(model, title = "Fuel Economy")

# Force a plain-text preview
old <- options(snazzieR.preview = "text")
print(tbl)
#> == Fuel Economy — mpg = 37.23 - 3.878*wt - 0.03177*hp ==
#> 
#> 
#> Term          Estimate   Std.Error   P.Value   Signif.   Statistic            Value
#> ------------  ---------  ----------  --------  --------  ---------------  ---------
#> (Intercept)   37.22727   1.59879     0         :3        MSE                6.09524
#> wt            -3.87783   0.63273     0         :3        MSE adj.           6.72578
#> hp            -0.03177   0.00903     0.00145   :)        df                29.00000
#>                                                          R-squared          0.82679
#>                                                          R-squared adj.     0.81484
#> significance codes:  :3 < 0.001,  :) < 0.01,  :/ < 0.05
#> 
options(old)
```
