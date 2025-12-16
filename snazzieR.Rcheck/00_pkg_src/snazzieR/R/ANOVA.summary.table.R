#' Generate a Summary Table for ANOVA Results
#'
#' This function creates a summary table for ANOVA results, including degrees of freedom,
#' sum of squares, mean squares, F-values, and p-values. The table can be output as either
#' LaTeX (for PDF reports) or plain text (for console viewing).
#'
#' @param model A model object for which ANOVA results are computed (e.g., output from `lm()` or `aov()`).
#' @param caption A character string to be used as the caption for the table.
#' @param latex Logical; if `TRUE`, returns a LaTeX-formatted table using `kableExtra`. If `FALSE`, prints a plain-text version to the console.
#'
#' @return If `latex = TRUE`, a LaTeX-formatted table object. If `latex = FALSE`, prints the summary table and returns it (invisibly).
#'
#' @importFrom stats anova
#' @importFrom knitr kable
#' @importFrom kableExtra kable row_spec column_spec footnote kable_styling
#' @export
#'
#' @examples
#' # Fit a linear model
#' model <- lm(mpg ~ wt + hp, data = mtcars)
#'
#' # Generate a plain-text ANOVA summary table
#' ANOVA.summary.table(model, caption = "ANOVA Summary", latex = FALSE)
#'
ANOVA.summary.table <- function(model, caption, latex = TRUE) {
  # Compute ANOVA summary
  anova.summary <- anova(model)
  rounding.precision <- 5

  # Create ANOVA table
  anova.table <- data.frame(
    Term = rownames(anova.summary),
    Df = anova.summary$Df,
    Sum.Sq = round(anova.summary$"Sum Sq", rounding.precision),
    Mean.Sq = round(anova.summary$"Mean Sq", rounding.precision),
    F.Value = round(anova.summary$"F value", rounding.precision),
    P.Value = round(anova.summary$"Pr(>F)", rounding.precision)
  )

  # Replace NA values with empty strings
  anova.table[is.na(anova.table)] <- ""

  # Add significance codes
  anova.table$Signif. <- ifelse(anova.table$P.Value < 0.001, ":3",
    ifelse(anova.table$P.Value < 0.01, ":)",
      ifelse(anova.table$P.Value < 0.05, ":/",
        ifelse(anova.table$P.Value < 0.1, "", "")
      )
    )
  )

  if (latex) {
    return(
      anova.table |>
        kableExtra::kable(
          format = "latex",
          caption = paste0("\\textbf{", caption, "}"),
          digits = rounding.precision,
          row.names = FALSE
        ) |>
        kableExtra::row_spec(0, bold = TRUE) |>
        kableExtra::column_spec(1, border_left = TRUE, border_right = FALSE, bold = TRUE) |>
        kableExtra::column_spec(7, border_left = FALSE, border_right = TRUE) |>
        kableExtra::footnote(
          general = c("", "", "", "significance codes -  :3 -  >0.001 ", ":) - >0.01", ":/ - >0.05 ", ""),
          general_title = "",
          footnote_as_chunk = TRUE,
          threeparttable = TRUE
        ) |>
        kableExtra::kable_styling(latex_options = "HOLD_position")
    )
  } else {
    print(anova.table)
    invisible(anova.table)
  }
}
