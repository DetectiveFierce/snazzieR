#' Generate a Model Equation from a Linear Model
#'
#' This function extracts and formats the equation from a linear model object.
#' It includes an option to return the equation as a LaTeX-formatted string or print it to the console.
#'
#' @param model A linear model object (e.g., output from `lm()`).
#' @param latex A logical value indicating whether to return a LaTeX-formatted equation (default: TRUE). If FALSE, the equation is printed to the console.
#'
#' @return If `latex` is TRUE, the equation is returned as LaTeX code using `knitr::asis_output()`. If FALSE, the equation is printed to the console.
#'
#' @examples
#' # Fit a linear model
#' model <- lm(mpg ~ wt + hp, data = mtcars)
#'
#' # Get LaTeX equation
#' model.equation(model)
#'
#' # Print equation to console
#' model.equation(model, latex = FALSE)
#'
#' @export
model.equation <- function(model, latex = TRUE) {
  eq <- equation_strings(model, max.terms = 10)
  if (is.null(eq$plain)) {
    eq$plain <- "Equation too long to display."
    eq$latex <- "\\text{Equation too long to display.}"
  }
  if (latex) {
    knitr::asis_output(paste0("\\[", eq$latex, "\\]"))
  } else {
    cat(eq$plain, "\n")
  }
}

# ---- internal helpers --------------------------------------------------------

# Build plain-text and LaTeX versions of a fitted linear model's equation.
# Returns list(plain = NULL, latex = NULL) when there are more than
# `max.terms` predictors.
equation_strings <- function(model, max.terms = 10) {
  b <- stats::coef(model)
  b <- b[!is.na(b)]
  has.intercept <- names(b)[1] == "(Intercept)"
  slopes <- if (has.intercept) b[-1] else b
  if (length(slopes) > max.terms) {
    return(list(plain = NULL, latex = NULL))
  }

  response <- deparse1(stats::formula(model)[[2]])
  num <- function(x) formatC(x, format = "fg", digits = 4)
  sign <- function(x, first) {
    if (x < 0) {
      if (first) "-" else " - "
    } else {
      if (first) "" else " + "
    }
  }

  plain <- paste0(response, " = ")
  latex <- paste0("\\widehat{", latex_response(response), "} = ")
  first <- TRUE
  if (has.intercept) {
    plain <- paste0(plain, sign(b[[1]], TRUE), num(abs(b[[1]])))
    latex <- paste0(latex, sign(b[[1]], TRUE), num(abs(b[[1]])))
    first <- FALSE
  }
  for (i in seq_along(slopes)) {
    value <- slopes[[i]]
    plain <- paste0(plain, sign(value, first), num(abs(value)), "*", names(slopes)[i])
    latex <- paste0(latex, sign(value, first), num(abs(value)), "\\,", latex_term(names(slopes)[i]))
    first <- FALSE
  }
  list(plain = plain, latex = latex)
}

latex_text <- function(x) {
  x <- gsub("\\", "\\textbackslash{}", x, fixed = TRUE)
  x <- gsub("([{}_%&#$])", "\\\\\\1", x)
  x <- gsub("^", "\\textasciicircum{}", x, fixed = TRUE)
  x <- gsub("~", "\\textasciitilde{}", x, fixed = TRUE)
  paste0("\\text{", x, "}")
}

latex_term <- function(x) {
  paste(vapply(strsplit(x, ":", fixed = TRUE)[[1]], latex_text, character(1)), collapse = " \\times ")
}

latex_response <- function(x) {
  inner <- sub("^[a-z0-9]+\\((.*)\\)$", "\\1", x)
  if (grepl("^log\\(", x)) return(paste0("\\log\\left(", latex_text(inner), "\\right)"))
  if (grepl("^log10\\(", x)) return(paste0("\\log_{10}\\left(", latex_text(inner), "\\right)"))
  if (grepl("^log2\\(", x)) return(paste0("\\log_{2}\\left(", latex_text(inner), "\\right)"))
  if (grepl("^sqrt\\(", x)) return(paste0("\\sqrt{", latex_text(inner), "}"))
  if (grepl("^exp\\(", x)) return(paste0("\\exp\\left(", latex_text(inner), "\\right)"))
  latex_text(x)
}
