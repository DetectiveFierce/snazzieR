# Generate a Model Equation from a Linear Model

This function extracts and formats the equation from a linear model
object. It includes an option to return the equation as a
LaTeX-formatted string or print it to the console.

## Usage

``` r
model.equation(model, latex = TRUE)
```

## Arguments

- model:

  A linear model object (e.g., output from \`lm()\`).

- latex:

  A logical value indicating whether to return a LaTeX-formatted
  equation (default: TRUE). If FALSE, the equation is printed to the
  console.

## Value

If \`latex\` is TRUE, the equation is returned as LaTeX code using
\`knitr::asis_output()\`. If FALSE, the equation is printed to the
console.

## Examples

``` r
# Fit a linear model
model <- lm(mpg ~ wt + hp, data = mtcars)

# Get LaTeX equation
model.equation(model)
#> [1] "\\[\\text{mpg} = 37.227 - 3.878 (\\text{wt}) - 0.032 (\\text{hp})\\]"
#> attr(,"class")
#> [1] "knit_asis"
#> attr(,"knit_cacheable")
#> [1] NA

# Print equation to console
model.equation(model, latex = FALSE)
#> mpg = 37.227 - 3.878 (wt) - 0.032 (hp) 
```
