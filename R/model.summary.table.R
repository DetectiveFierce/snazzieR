#' Generate a Summary Table for a Linear Model
#'
#' This function creates a summary table for a linear model, including estimated
#' coefficients, standard errors, p-values with significance codes, and model
#' statistics such as MSE and R-squared. The table can be output as either
#' LaTeX (for PDF reports) or plain text (for console viewing).
#'
#' @param model A linear model object (typically the result of `lm()`).
#' @param title A character string used as the table's title (its LaTeX
#'        caption). Defaults to \code{"Model Summary"}. The fitted model
#'        equation is typeset on its own centered line between the title and
#'        the table.
#' @param caption Deprecated alias for \code{title}, kept so existing code
#'        keeps working.
#' @param latex Logical; if `TRUE` (default), returns a LaTeX-formatted table using `kableExtra`.
#'        If `FALSE`, prints plain-text summary tables to the console.
#'
#' @return If `latex = TRUE`, returns a LaTeX-formatted `kableExtra` table object
#'         (of class \code{"snazzieR_table"}, which also previews nicely when a
#'         chunk is run interactively; see \code{\link{snazzieR_table}}).
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
#' model.summary.table(model, title = "Linear Model Summary", latex = FALSE)
#'
model.summary.table <- function(model, title = "Model Summary", latex = TRUE, caption) {
  if (!missing(caption)) title <- caption
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

  # Unpadded copy for the console (padding rows are added below for LaTeX)
  coef.table.console <- coef.table

  # Create model equation (plain text for the console, LaTeX for the PDF)
  eq <- equation_strings(model, max.terms = 10)
  equation <- if (is.null(eq$plain)) "too long :(" else eq$plain
  latex.equation <- if (is.null(eq$latex)) "\\text{too long :(}" else eq$latex

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
    latex.table <- final_table[, ] |>
      kableExtra::kable(
        format = "latex",
        caption = paste0("\\textbf{", title, "}"),
        digits = rounding.precision,
        row.names = FALSE
      ) |>
      kableExtra::row_spec(0, bold = TRUE) |>
      kableExtra::column_spec(1, border_left = TRUE, border_right = FALSE, bold = TRUE) |>
      kableExtra::column_spec(6, border_left = TRUE, border_right = FALSE, bold = TRUE) |>
      kableExtra::column_spec(7, border_left = FALSE, border_right = TRUE) |>
      kableExtra::footnote(
        general = c("", "", "", "significance codes -  :3 -  $<$0.001 ", ":) - $<$0.01", ":/ - $<$0.05 ", ""),
        general_title = "",
        footnote_as_chunk = TRUE,
        escape = FALSE,
        threeparttable = TRUE
      ) |>
      kableExtra::kable_styling(
        latex_options = c("HOLD_position", "scale_down"),
      )
    latex.table <- insert_before_table(latex.table, paste0("$", latex.equation, "$\\par\\smallskip"))
    snazzieR_wrap(latex.table, list(preview_table(
      final_table,
      caption = paste0(title, " \u2014 ", equation),
      notes = "significance codes:  :3 < 0.001,  :) < 0.01,  :/ < 0.05",
      row.names = FALSE
    )))
  } else {
    cat(paste0("== ", title, " ==\n"))
    cat(paste0("Equation: ", equation, "\n\n"))
    cat("Coefficient Table:\n")
    print(knitr::kable(coef.table.console, format = "simple", digits = rounding.precision, row.names = FALSE))
    cat("\nModel Statistics:\n")
    print(knitr::kable(model.stats.table, format = "simple", digits = rounding.precision))
    invisible(final_table)
  }
}


#
