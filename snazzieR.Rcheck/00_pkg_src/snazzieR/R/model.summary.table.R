#' Generate a Summary Table for a Linear Model
#'
#' This function creates a summary table for a linear model, including estimated
#' coefficients, standard errors, p-values with significance codes, and model
#' statistics such as MSE and R-squared. The table can be output as either
#' LaTeX (for PDF reports) or plain text (for console viewing).
#'
#' @param model A linear model object (typically the result of `lm()`).
#' @param caption A character string to be used as the caption for the table.
#' @param latex Logical; if `TRUE` (default), returns a LaTeX-formatted table using `kableExtra`.
#'        If `FALSE`, prints plain-text summary tables to the console.
#'
#' @return If `latex = TRUE`, returns a LaTeX-formatted `kableExtra` table object.
#'         If `latex = FALSE`, prints formatted summary tables to the console and returns the underlying data frame.
#'
#' @importFrom stats coef
#' @importFrom knitr kable
#' @importFrom kableExtra kable_styling row_spec column_spec footnote
#' @export
#'
#' @examples
#' # Fit a linear model
#' model <- lm(mpg ~ wt + hp, data = mtcars)
#'
#' # Print a plain-text version to the console
#' model.summary.table(model, caption = "Linear Model Summary", latex = FALSE)
#'
model.summary.table <- function(model, caption, latex = TRUE) {
  # Extract coefficient summary
  coef.summary <- summary(model)$coefficients
  model.summary <- summary(model)
  rounding.precision <- 5

  # Create coefficient table
  coef.table <- data.frame(
    Term = rownames(coef.summary),
    Estimate = round(coef.summary[, "Estimate"], rounding.precision),
    Std.Error = round(coef.summary[, "Std. Error"], rounding.precision),
    P.Value = round(coef.summary[, "Pr(>|t|)"], rounding.precision)
  )

  # Add significance codes
  coef.table$Signif. <- ifelse(coef.table$P.Value < 0.001, ":3",
    ifelse(coef.table$P.Value < 0.01, ":)",
      ifelse(coef.table$P.Value < 0.05, ":/", "")
    )
  )

  # Calculate model statistics
  mse <- mean(model.summary$residuals^2)
  mse.adj <- mse * (length(model$fitted.values) / (length(model$fitted.values) - length(coef(model))))
  df <- model.summary$df[2]
  r.squared <- model.summary$r.squared
  adj.r.squared <- model.summary$adj.r.squared

  # Create model equation
  variable.names <- names(coef(model))[-1]
  coefficients <- round(coef(model), 3)
  equation <- paste(model$terms[[2]], "=", coefficients[1])
  if (length(variable.names) > 10) {
    equation <- "too long :("
  } else {
    for (i in seq_along(variable.names)) {
      equation <- paste(equation, " + ", coefficients[i + 1], "*", variable.names[i], sep = "")
    }
  }

  # Create model statistics table
  model.stats.table <- data.frame(
    Statistic = c("MSE", "MSE adj.", "df", "R-squared", "R-squared adj."),
    Value = c(
      round(mse, rounding.precision),
      round(mse.adj, rounding.precision),
      df,
      round(r.squared, rounding.precision),
      round(adj.r.squared, rounding.precision)
    )
  )

  # Align rows
  if (nrow(coef.table) > nrow(model.stats.table)) {
    empty_rows <- data.frame(
      Statistic = rep("", nrow(coef.table) - nrow(model.stats.table)),
      Value = rep("", nrow(coef.table) - nrow(model.stats.table))
    )
    model.stats.table.aligned <- rbind(model.stats.table, empty_rows)
  } else {
    if (nrow(coef.table) < nrow(model.stats.table)) {
      diff <- nrow(model.stats.table) - nrow(coef.table)
      for (i in 1:diff) {
        coef.table[nrow(coef.table) + 1, ] <- data.frame(Term = "", Estimate = "", Std.Error = "", P.Value = "", Signif. = "")
      }
    }
    model.stats.table.aligned <- model.stats.table
  }

  final_table <- cbind(coef.table, model.stats.table.aligned)

  if (latex) {
    final_table[, ] |>
      kableExtra::kable(
        format = "latex",
        caption = paste("\\textbf{", caption, "} \\newline \\textbf{", equation, "}"),
        digits = rounding.precision,
        row.names = FALSE
      ) |>
      kableExtra::row_spec(0, bold = TRUE) |>
      kableExtra::column_spec(1, border_left = TRUE, border_right = FALSE, bold = TRUE) |>
      kableExtra::column_spec(6, border_left = TRUE, border_right = FALSE, bold = TRUE) |>
      kableExtra::column_spec(7, border_left = FALSE, border_right = TRUE) |>
      kableExtra::footnote(
        general = c("", "", "", "significance codes -  :3 -  >0.001 ", ":) - >0.01", ":/ - >0.05 ", ""),
        general_title = "",
        footnote_as_chunk = TRUE,
        threeparttable = TRUE
      ) |>
      kableExtra::kable_styling(
        latex_options = c("HOLD_position", "scale_down"),
      )
  } else {
    cat(paste0("== ", caption, " ==\n"))
    cat(paste0("Equation: ", equation, "\n\n"))
    cat("Coefficient Table:\n")
    print(knitr::kable(coef.table, format = "simple", digits = rounding.precision))
    cat("\nModel Statistics:\n")
    print(knitr::kable(model.stats.table, format = "simple", digits = rounding.precision))
    invisible(final_table)
  }
}


#
