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
  # Extract coefficients
  coefficients <- round(coef(model), 3)
  variable.names <- names(coefficients)[-1]  # Exclude intercept

  # Construct equation string
  equation <- paste0(model$terms[[2]], " = ", coefficients[1])  # Start with intercept

  if (length(variable.names) > 10) {
    equation <- "Equation too long to display."
  } else {
    for (i in seq_along(variable.names)) {
      equation <- paste0(equation, ifelse(coefficients[i + 1] < 0, " - ", " + "), abs(coefficients[i + 1]), " (", variable.names[i], ")")
    }
  }

  # Format for LaTeX if needed
  if (latex) {
    latex_equation <- equation
    latex_equation <- gsub("([a-zA-Z_][a-zA-Z0-9_.]*)", "\\\\text{\\1}", latex_equation)  # Wrap full variable names in \text{()}
    latex_equation <- gsub(" ", " ", latex_equation)  # Ensure spaces are LaTeX-compatible
    latex_equation <- gsub("\\*", " \\times ", latex_equation)  # Replace * with \times for LaTeX formatting
    latex_equation <- paste0("\\[", latex_equation, "\\]")  # Wrap in display math mode
    return(knitr::asis_output(latex_equation))
  } else {
    cat(equation, "\n")
  }
}
