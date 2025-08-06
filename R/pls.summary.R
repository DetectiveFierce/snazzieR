#' @title Format PLS Model Output as LaTeX Tables
#'
#' @description
#' Formats and displays Partial Least Squares (PLS) model output from \code{pls.regression()}
#' as LaTeX tables for PDF rendering.
#'
#' @param x A list returned by \code{\link{pls.regression}()} (class \code{"pls"}) containing PLS model components.
#' @param ... Further arguments passed to or from methods (unused).
#' @param include.scores Logical. Whether to include score matrices (T and U). Default is \code{TRUE}.
#'
#' @return Returns a \code{knitr::asis_output} object (LaTeX code) for PDF rendering.
#'
#' @export
#'
#' @examples
#' # Load example data
#' data(mtcars)
#'
#' # Prepare data for PLS regression
#' X <- mtcars[, c("wt", "hp", "disp")]
#' Y <- mtcars[, "mpg", drop = FALSE]
#'
#' # Fit PLS model with 2 components
#' pls.fit <- pls.regression(X, Y, n.components = 2)
#'
#' # Print a LaTeX-formatted summary
#' pls.summary(pls.fit, include.scores = FALSE)
pls.summary <- function(x, ..., include.scores = TRUE) {
  pls.result <- x # optional: alias for clarity

  if (is.null(pls.result$model.type) || pls.result$model.type != "PLS Regression") {
    stop("Error! Non-PLS model passed to PLS formatting function (pls.summary.R)", call. = FALSE)
  }

  # Load required packages
  if (!requireNamespace("knitr", quietly = TRUE)) {
    stop("knitr package is required", call. = FALSE)
  }
  if (!requireNamespace("kableExtra", quietly = TRUE)) {
    stop("kableExtra package is required", call. = FALSE)
  }
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("dplyr package is required", call. = FALSE)
  }

  kables <- list()

  # === Helper to wrap table in minipage ===
  wrap_minipage <- function(latex_table, width = "0.48\\linewidth") {
    paste0("\\begin{minipage}[t]{", width, "}\n", latex_table, "\n\\end{minipage}")
  }

  # === Build kables as before ===

  # 1. X Weights (W)
  if (!is.null(pls.result$W)) {
    w.df <- as.data.frame(pls.result$W)
    colnames(w.df) <- paste0("Comp ", seq_len(ncol(w.df)))
    kables$weights.x <- knitr::kable(w.df, format = "latex", caption = "X Weights (W)", booktabs = TRUE, align = "c") %>%
      kableExtra::kable_styling(bootstrap_options = "striped", latex_options = "HOLD_position", full_width = FALSE, position = "center") %>%
      kableExtra::column_spec(1, border_left = TRUE) %>%
      kableExtra::column_spec(ncol(w.df), border_right = TRUE)
  }

  # 2. X Loadings (P_loadings)
  if (!is.null(pls.result$P_loadings)) {
    p.df <- as.data.frame(pls.result$P_loadings)
    colnames(p.df) <- paste0("Comp ", seq_len(ncol(p.df)))
    kables$loadings.x <- knitr::kable(p.df, format = "latex", caption = "X Loadings (P)", booktabs = TRUE, align = "c", escape = FALSE) %>%
      kableExtra::kable_styling(bootstrap_options = "striped", full_width = FALSE, latex_options = "HOLD_position") %>%
      kableExtra::column_spec(1, border_left = TRUE) %>%
      kableExtra::column_spec(ncol(p.df), border_right = TRUE)
  }

  # 3. Y Weights (C)
  if (!is.null(pls.result$C)) {
    c.df <- as.data.frame(pls.result$C)
    colnames(c.df) <- paste0("Comp ", seq_len(ncol(c.df)))
    kables$weights.y <- knitr::kable(c.df, format = "latex", caption = "Y Weights (C)", booktabs = TRUE, align = "c") %>%
      kableExtra::kable_styling(bootstrap_options = "striped", full_width = FALSE, latex_options = "HOLD_position") %>%
      kableExtra::column_spec(1, border_left = TRUE) %>%
      kableExtra::column_spec(ncol(c.df), border_right = TRUE)
  }

  # 4. Y Loadings (Q_loadings)
  if (!is.null(pls.result$Q_loadings)) {
    q_load.df <- as.data.frame(pls.result$Q_loadings)
    colnames(q_load.df) <- paste0("Comp ", seq_len(ncol(q_load.df)))
    kables$loadings.y <- knitr::kable(q_load.df, format = "latex", caption = "Y Loadings (Q)", booktabs = TRUE, align = "c") %>%
      kableExtra::kable_styling(bootstrap_options = "striped", full_width = FALSE, latex_options = "HOLD_position") %>%
      kableExtra::column_spec(1, border_left = TRUE) %>%
      kableExtra::column_spec(ncol(q_load.df), border_right = TRUE)
  }

  # 5. Scalars b (per component)
  if (!is.null(pls.result$B_vector)) {
    b.df <- data.frame(
      `Component` = seq_along(pls.result$B_vector),
      `Estimate` = pls.result$B_vector
    )
    kables$b.vector <- knitr::kable(b.df, format = "latex", caption = "Regression Scalars (b)", booktabs = TRUE, align = "c") %>%
      kableExtra::kable_styling(bootstrap_options = "striped", full_width = FALSE, latex_options = "HOLD_position") %>%
      kableExtra::column_spec(1, border_left = TRUE) %>%
      kableExtra::column_spec(ncol(b.df), border_right = TRUE)
  }

  # 6. Regression coefficients
  if (!is.null(pls.result$coefficients)) {
    coef.df <- as.data.frame(pls.result$coefficients)
    if (ncol(coef.df) > 1) {
      colnames(coef.df) <- colnames(pls.result$coefficients)
      extra_cols <- 1
    } else {
      colnames(coef.df) <- "Estimate"
      extra_cols <- 0
    }

    kables$coefficients <- knitr::kable(coef.df, format = "latex", caption = "Regression Coefficients (Original Scale)", booktabs = TRUE, align = "c") %>%
      kableExtra::kable_styling(full_width = FALSE, latex_options = "HOLD_position") %>%
      kableExtra::column_spec(1, border_left = TRUE) %>%
      kableExtra::column_spec(ncol(coef.df) + extra_cols, border_right = TRUE)
  }

  # === Scores (conditionally) ===
  if (isTRUE(include.scores)) {
    if (!is.null(pls.result$T)) {
      t.scores.df <- as.data.frame(pls.result$T)
      colnames(t.scores.df) <- paste0("Comp ", seq_len(ncol(t.scores.df)))
      kables$t.scores <- knitr::kable(t.scores.df, format = "latex", caption = "X Scores (T)", booktabs = TRUE, align = "c") %>%
        kableExtra::kable_styling(full_width = FALSE, latex_options = "HOLD_position") %>%
        kableExtra::column_spec(1, border_left = TRUE) %>%
        kableExtra::column_spec(ncol(t.scores.df), border_right = TRUE)
    }

    if (!is.null(pls.result$U)) {
      u.scores.df <- as.data.frame(pls.result$U)
      colnames(u.scores.df) <- paste0("Comp ", seq_len(ncol(u.scores.df)))
      kables$u.scores <- knitr::kable(u.scores.df, format = "latex", caption = "Y Scores (U)", booktabs = TRUE, align = "c") %>%
        kableExtra::kable_styling(full_width = FALSE, latex_options = "HOLD_position") %>%
        kableExtra::column_spec(1, border_left = TRUE) %>%
        kableExtra::column_spec(ncol(u.scores.df), border_right = TRUE)
    }
  }

  # 9. Explained variance X
  if (!is.null(pls.result$X_explained)) {
    x.expl.df <- data.frame(
      `Latent Vector` = seq_along(pls.result$X_explained),
      `Explained Variance` = sprintf("%.4f\\%%", pls.result$X_explained),
      `Cumulative` = sprintf("%.4f\\%%", pls.result$X_cum_explained)
    )
    colnames(x.expl.df) <- gsub("\\.", " ", colnames(x.expl.df))
    kables$explained.variance.x <- knitr::kable(
      x.expl.df,
      format = "latex",
      caption = "Variance Explained by Components (X)",
      booktabs = TRUE,
      align = "c",
      escape = FALSE
    ) %>%
      kableExtra::kable_styling(full_width = FALSE, latex_options = c("HOLD_position", "scale_down")) %>%
      kableExtra::column_spec(1, width = "3cm", border_left = TRUE) %>%
      kableExtra::column_spec(ncol(x.expl.df), border_right = TRUE)
  }

  # 10. Explained variance Y
  if (!is.null(pls.result$Y_explained)) {
    y.expl.df <- data.frame(
      `Latent Vector` = seq_along(pls.result$Y_explained),
      `Explained Variance` = sprintf("%.4f\\%%", pls.result$Y_explained),
      `Cumulative` = sprintf("%.4f\\%%", pls.result$Y_cum_explained)
    )
    colnames(y.expl.df) <- gsub("\\.", " ", colnames(y.expl.df))
    kables$explained.variance.y <- knitr::kable(
      y.expl.df,
      format = "latex",
      caption = "Variance Explained by Components (Y)",
      booktabs = TRUE,
      align = "c",
      escape = FALSE
    ) %>%
      kableExtra::kable_styling(full_width = FALSE, latex_options = c("HOLD_position", "scale_down")) %>%
      kableExtra::column_spec(1, width = "3cm", border_left = TRUE) %>%
      kableExtra::column_spec(ncol(y.expl.df), border_right = TRUE)
  }

  # === Dynamic Output Assembly ===

  output <- c()

  # Group: Weights
  if (!is.null(kables$weights.x) && !is.null(kables$weights.y)) {
    output <- c(output, paste0(
      wrap_minipage(kables$weights.x),
      wrap_minipage(kables$weights.y)
    ))
  } else {
    if (!is.null(kables$weights.x)) output <- c(output, kables$weights.x)
    if (!is.null(kables$weights.y)) output <- c(output, kables$weights.y)
  }

  # Group: Loadings
  if (!is.null(kables$loadings.x) && !is.null(kables$loadings.y)) {
    output <- c(output, paste0(
      wrap_minipage(kables$loadings.x),
      wrap_minipage(kables$loadings.y)
    ))
  } else {
    if (!is.null(kables$loadings.x)) output <- c(output, kables$loadings.x)
    if (!is.null(kables$loadings.y)) output <- c(output, kables$loadings.y)
  }

  # Group: Scores
  if (isTRUE(include.scores)) {
    if (!is.null(kables$t.scores) && !is.null(kables$u.scores)) {
      output <- c(output, paste0(
        wrap_minipage(kables$t.scores),
        wrap_minipage(kables$u.scores)
      ))
    } else {
      if (!is.null(kables$t.scores)) output <- c(output, kables$t.scores)
      if (!is.null(kables$u.scores)) output <- c(output, kables$u.scores)
    }
  }

  # Singles
  if (!is.null(kables$b.vector)) output <- c(output, kables$b.vector)
  if (!is.null(kables$coefficients)) output <- c(output, kables$coefficients)
  if (!is.null(kables$explained.variance.x)) output <- c(output, kables$explained.variance.x)
  if (!is.null(kables$explained.variance.y)) output <- c(output, kables$explained.variance.y)

  return(knitr::asis_output(paste(output, collapse = "\n\n")))
}
