pkgname <- "snazzieR"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
base::assign(".ExTimings", "snazzieR-Ex.timings", pos = 'CheckExEnv')
base::cat("name\tuser\tsystem\telapsed\n", file=base::get(".ExTimings", pos = 'CheckExEnv'))
base::assign(".format_ptime",
function(x) {
  if(!is.na(x[4L])) x[1L] <- x[1L] + x[4L]
  if(!is.na(x[5L])) x[2L] <- x[2L] + x[5L]
  options(OutDec = '.')
  format(x[1L:3L], digits = 7L)
},
pos = 'CheckExEnv')

### * </HEADER>
library('snazzieR')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("ANOVA.summary.table")
### * ANOVA.summary.table

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: ANOVA.summary.table
### Title: Generate a Summary Table for ANOVA Results
### Aliases: ANOVA.summary.table

### ** Examples

# Fit a linear model
model <- lm(mpg ~ wt + hp, data = mtcars)

# Generate the ANOVA summary table
ANOVA.summary.table(model, caption = "ANOVA Summary")



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("ANOVA.summary.table", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("NIPALS.pls")
### * NIPALS.pls

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: NIPALS.pls
### Title: Partial Least Squares Regression via NIPALS (Internal)
### Aliases: NIPALS.pls
### Keywords: internal

### ** Examples

## Not run: 
##D X <- matrix(rnorm(100 * 10), 100, 10)
##D Y <- matrix(rnorm(100 * 2), 100, 2)
##D model <- pls.regression(X, Y, n.components = 3, calc.method = "NIPALS")
##D model$coefficients
## End(Not run)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("NIPALS.pls", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("SVD.pls")
### * SVD.pls

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: SVD.pls
### Title: Partial Least Squares Regression via SVD (Internal)
### Aliases: SVD.pls
### Keywords: internal

### ** Examples

## Not run: 
##D X <- matrix(rnorm(100 * 10), 100, 10)
##D Y <- matrix(rnorm(100 * 2), 100, 2)
##D model <- pls.regression(X, Y, n.components = 3, calc.method = "SVD")
##D model$coefficients
## End(Not run)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("SVD.pls", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("color.ref")
### * color.ref

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: color.ref
### Title: Display a Color Reference Palette
### Aliases: color.ref

### ** Examples

color.ref()



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("color.ref", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("eigen.summary")
### * eigen.summary

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: eigen.summary
### Title: Summarize Eigenvalues and Eigenvectors of a Covariance Matrix
### Aliases: eigen.summary

### ** Examples

cov_matrix <- matrix(c(4, 2, 2, 3), nrow = 2)
eigen.summary(cov_matrix)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("eigen.summary", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("model.equation")
### * model.equation

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: model.equation
### Title: Generate a Model Equation from a Linear Model
### Aliases: model.equation

### ** Examples

# Fit a linear model
model <- lm(mpg ~ wt + hp, data = mtcars)

# Get LaTeX equation
model.equation(model)

# Print equation to console
model.equation(model, latex = FALSE)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("model.equation", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("model.summary.table")
### * model.summary.table

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: model.summary.table
### Title: Generate a Summary Table for a Linear Model
### Aliases: model.summary.table

### ** Examples

# Fit a linear model
model <- lm(mpg ~ wt + hp, data = mtcars)

# Generate the summary table
model.summary.table(model, caption = "Linear Model Summary")



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("model.summary.table", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("pls.regression")
### * pls.regression

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: pls.regression
### Title: Partial Least Squares (PLS) Regression Interface
### Aliases: pls.regression

### ** Examples

## Not run: 
##D X <- matrix(rnorm(100 * 10), 100, 10)
##D Y <- matrix(rnorm(100 * 2), 100, 2)
##D 
##D # Using SVD (default)
##D model1 <- pls.regression(X, Y, n.components = 3)
##D 
##D # Using NIPALS
##D model2 <- pls.regression(X, Y, n.components = 3, calc.method = "NIPALS")
## End(Not run)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("pls.regression", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("snazzieR.theme")
### * snazzieR.theme

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: snazzieR.theme
### Title: A Custom ggplot2 Theme for Publication-Ready Plots
### Aliases: snazzieR.theme

### ** Examples

library(ggplot2)
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  snazzieR.theme()



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("snazzieR.theme", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
