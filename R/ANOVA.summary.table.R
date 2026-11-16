#' Generate a Summary Table for ANOVA Results
#'
#' This function creates a summary table for ANOVA results, including degrees of freedom,
#' sum of squares, mean squares, F-values, and p-values. The table can be output as either
#' LaTeX (for PDF reports) or plain text (for console viewing).
#'
#' @param model A model object for which ANOVA results are computed (e.g., output from `lm()` or `aov()`).
#' @param title A character string used as the table's title (its LaTeX
#'        caption). Defaults to \code{"ANOVA Summary"}.
#' @param caption Deprecated alias for \code{title}, kept so existing code
#'        keeps working.
#' @param latex Logical; if `TRUE`, returns a LaTeX-formatted table using `kableExtra`. If `FALSE`, prints a plain-text version to the console.
#'
#' @return If `latex = TRUE`, a LaTeX-formatted table object (of class
#'   \code{"snazzieR_table"}, which also previews when a chunk is run
#'   interactively; see \code{\link{snazzieR_table}}). If `latex = FALSE`, prints the summary table and returns it (invisibly).
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
#' ANOVA.summary.table(model, title = "ANOVA Summary", latex = FALSE)
#'
ANOVA.summary.table <- function(model, title = "ANOVA Summary", latex = TRUE, caption) {
  if (!missing(caption)) title <- caption
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

  # Significance codes, from the numeric p-values (rows without a test, such
  # as Residuals, get none)
  p.value <- anova.summary$"Pr(>F)"
  signif.codes <- ifelse(is.na(p.value), "",
    ifelse(p.value < 0.001, ":3",
      ifelse(p.value < 0.01, ":)",
        ifelse(p.value < 0.05, ":/", "")
      )
    )
  )

  # Replace NA values with empty strings
  anova.table[is.na(anova.table)] <- ""
  anova.table$Signif. <- signif.codes

  if (latex) {
    latex.table <- anova.table |>
        kableExtra::kable(
          format = "latex",
          caption = caption_placeholder,
          digits = rounding.precision,
          row.names = FALSE
        ) |>
        kableExtra::row_spec(0, bold = TRUE) |>
        kableExtra::column_spec(1, border_left = TRUE, border_right = FALSE, bold = TRUE) |>
        kableExtra::column_spec(7, border_left = FALSE, border_right = TRUE) |>
        kableExtra::footnote(
          general = c("", "", "", "significance codes -  :3 -  $<$0.001 ", ":) - $<$0.01", ":/ - $<$0.05 ", ""),
          general_title = "",
          footnote_as_chunk = TRUE,
          escape = FALSE,
          threeparttable = TRUE
        ) |>
        kableExtra::kable_styling(latex_options = "HOLD_position")
    latex.table <- set_latex_caption(latex.table, paste0("\\textbf{", title, "}"))
    snazzieR_wrap(latex.table, list(preview_table(
      anova.table,
      caption = title,
      notes = "significance codes:  :3 < 0.001,  :) < 0.01,  :/ < 0.05",
      row.names = FALSE
    )))
  } else {
    print(anova.table)
    invisible(anova.table)
  }
}
