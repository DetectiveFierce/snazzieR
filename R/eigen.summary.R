#' Summarize Eigenvalues and Eigenvectors of a Covariance Matrix
#'
#' This function computes the eigenvalues and eigenvectors of a given covariance matrix,
#' ensures sign consistency in the eigenvectors, and outputs either a LaTeX table or
#' plaintext summary displaying the results.
#'
#' @param cov.matrix A square numeric matrix representing the covariance matrix.
#' @param title A character string used as the table's title (default: "Eigenvectors of Covariance Matrix").
#' @param caption Deprecated alias for \code{title}, kept so existing code keeps working.
#' @param latex A logical indicating whether to output LaTeX table (default: TRUE). If FALSE, prints as plain text.
#'
#' @return A LaTeX formatted table of class \code{"snazzieR_table"} (if latex = TRUE; see
#'   \code{\link{snazzieR_table}} for interactive previews) or plaintext console output (if latex = FALSE).
#' @export
#'
#' @importFrom knitr kable
#' @importFrom kableExtra kable_styling add_header_above footnote row_spec
#' @examples
#' cov_matrix <- matrix(c(4, 2, 2, 3), nrow = 2)
#' eigen.summary(cov_matrix, title = "Eigenvalues and Eigenvectors", latex = FALSE)
eigen.summary <- function(cov.matrix,
                          title = "Eigenvectors of Covariance Matrix",
                          latex = TRUE,
                          caption) {
  if (!missing(caption)) title <- caption
  eigen.data <- eigen(cov.matrix)
  eigenvalues <- eigen.data$values
  eigenvectors <- eigen.data$vectors

  # Ensure consistent sign: make max absolute value in each eigenvector column positive
  for (i in seq_len(ncol(eigenvectors))) {
    max_idx <- which.max(abs(eigenvectors[, i]))
    if (eigenvectors[max_idx, i] < 0) {
      eigenvectors[, i] <- -eigenvectors[, i]
    }
  }

  total_variance <- sum(eigenvalues)

  if (latex) {
    col_titles <- paste0("$\\lambda_", seq_along(eigenvalues), " = ", round(eigenvalues, 4), "$")
    eigenvectors_bracketed <- apply(eigenvectors, 2, function(x) {
      paste0("$\\begin{bmatrix}", paste(round(x, 5), collapse = "\\\\"), "\\end{bmatrix}$")
    })
    eigenvectors_df <- data.frame(matrix(eigenvectors_bracketed, ncol = length(eigenvalues)))
    colnames(eigenvectors_df) <- col_titles

    kable_table <- kable(
      eigenvectors_df,
      caption = title,
      align = "c",
      format = "latex",
      escape = FALSE,
      booktabs = TRUE
    ) |>
      kableExtra::kable_styling(
        latex_options = c("hold_position"),
        full_width = FALSE
      ) |>
      kableExtra::add_header_above(c(" " = 1), escape = FALSE, line = FALSE) |>
      kableExtra::footnote(
        general = paste("Total Variance =", round(total_variance, 4)),
        general_title = "",
        footnote_as_chunk = TRUE,
        escape = FALSE,
        threeparttable = TRUE
      ) |>
      kableExtra::row_spec(0, extra_latex_after = "\\arrayrulecolor{white}", hline_after = FALSE)

    kable_table <- sub("\\\\toprule", "", kable_table)
    preview.df <- as.data.frame(round(eigenvectors, 5))
    colnames(preview.df) <- paste0("\u03bb", seq_along(eigenvalues), " = ", round(eigenvalues, 4))
    return(snazzieR_wrap(kable_table, list(preview_table(
      preview.df,
      caption = title,
      notes = paste("Total Variance =", round(total_variance, 4))
    ))))
  } else {
    cat("==", title, "==\n\n")
    cat("Eigenvalues:\n")
    print(round(eigenvalues, 5))
    cat("\nEigenvectors (columns correspond to eigenvalues):")
    eigenvectors_rounded <- round(eigenvectors, 5)
    colnames(eigenvectors_rounded) <- paste0("lambda", seq_along(eigenvalues))
    print(knitr::kable(eigenvectors_rounded, format = "simple"))
    cat("\nTotal Variance:", round(total_variance, 5), "\n")
    invisible(list(values = eigenvalues, vectors = eigenvectors))
  }
}
