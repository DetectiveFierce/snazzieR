#' Summarize Eigenvalues and Eigenvectors of a Covariance Matrix
#'
#' This function computes the eigenvalues and eigenvectors of a given covariance matrix,
#' ensures sign consistency in the eigenvectors, and outputs a formatted LaTeX table
#' displaying the results.
#'
#' @param cov.matrix A square numeric matrix representing the covariance matrix.
#' @param caption A character string specifying the table caption (default: "Eigenvectors of Covariance Matrix").
#' @param space_after_caption A character string specifying the space after the caption in LaTeX (default: "5mm").
#'
#' @return A LaTeX formatted table displaying the eigenvectors and eigenvalues.
#' @export
#'
#' @importFrom knitr kable
#' @importFrom kableExtra kable_styling add_header_above footnote row_spec
#' @examples
#' cov_matrix <- matrix(c(4, 2, 2, 3), nrow = 2)
#' eigen.summary(cov_matrix)
eigen.summary <- function(cov.matrix, caption = "Eigenvectors of Covariance Matrix", space_after_caption = "5mm") {
  # Compute eigenvalues and eigenvectors
  eigen.data <- eigen(cov.matrix)
  eigenvalues <- eigen.data$values
  eigenvectors <- eigen.data$vectors

  # Ensure consistency in sign by making the largest absolute value in each column positive
  for (i in 1:ncol(eigenvectors)) {
    max_idx <- which.max(abs(eigenvectors[, i]))
    if (eigenvectors[max_idx, i] < 0) {
      eigenvectors[, i] <- -eigenvectors[, i]
    }
  }

  # Calculate total variance
  total_variance <- sum(eigenvalues)

  # Create column titles with LaTeX formatting
  col_titles <- paste0("$\\lambda_", 1:length(eigenvalues), " = ", round(eigenvalues, 4), "$")

  # Wrap each eigenvector in tall brackets using LaTeX
  eigenvectors_bracketed <- apply(eigenvectors, 2, function(x) {
    paste0("$\\begin{bmatrix}", paste(x, collapse = "\\\\"), "\\end{bmatrix}$")
  })

  # Convert to a data frame for kable
  eigenvectors_df <- data.frame(matrix(eigenvectors_bracketed, ncol = length(eigenvalues)))
  colnames(eigenvectors_df) <- col_titles

  # Create the table with kable
  kable_table <- kable(
    eigenvectors_df,
    caption = caption,
    align = "c",
    format = "latex",
    escape = FALSE,
    booktabs = TRUE
  )

  # Add additional formatting using kableExtra
  kable_table <- kable_table |>
    kable_styling(
      latex_options = c("hold_position"),
      full_width = FALSE
    ) |>
    add_header_above(c(" " = 1), escape = FALSE, line = FALSE) |>
    footnote(
      general = c(rep("", 2.5 * length(eigenvalues)), paste(" Total Variance =", round(total_variance, 4))),
      general_title = "",
      footnote_as_chunk = TRUE,
      escape = FALSE,
      threeparttable = TRUE
    ) |>
    row_spec(0, extra_latex_after = "\\arrayrulecolor{white}", hline_after = FALSE)

  kable_table <- sub("\\\\toprule", "", kable_table)

  return(kable_table)
}
