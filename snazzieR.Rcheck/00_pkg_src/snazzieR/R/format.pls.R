#' @title Format PLS Model Output as LaTeX or Console Tables
#' @description
#' Formats and displays Partial Least Squares (PLS) model output from \code{pls.regression()}
#' as either LaTeX tables (for PDF rendering) or console-friendly output.
#'
#' @param x A list returned by \code{\link{pls.regression}()} (class \code{"pls"}) containing PLS model components.
#' @param ... Further arguments passed to or from methods (unused).
#' @param include.scores Logical. Whether to include score matrices (T and U). Default is \code{TRUE}.
#' @param latex Logical. If \code{TRUE}, produces LaTeX output (for PDF rendering). If \code{FALSE}, prints to console. Default is \code{FALSE}.
#'
#' @return When \code{latex = TRUE}, returns a \code{knitr::asis_output} object (LaTeX code). When \code{FALSE}, prints formatted tables to console.
#'
#' @method format pls
#' @export
format.pls <- function(x, ..., include.scores = TRUE, latex = FALSE) {
    pls.result <- x # optional: alias for clarity

    if (is.null(pls.result$model.type) || pls.result$model.type != "PLS Regression") {
        stop("Error! Non-PLS model passed to PLS formatting function (format.pls.R)", call. = FALSE)
    }

    `%>%` <- dplyr::`%>%`
    kables <- list()

    make_table <- function(df, caption, escape = TRUE) {
        if (latex) {
            knitr::kable(df, format = "latex", caption = caption, booktabs = TRUE, align = "c", escape = escape) %>%
                kableExtra::kable_styling(latex_options = "HOLD_position", full_width = FALSE) %>%
                kableExtra::column_spec(1, border_left = TRUE) %>%
                kableExtra::column_spec(ncol(df), border_right = TRUE)
        } else {
            print(knitr::kable(df, format = "simple", caption = caption, digits = 4))
            NULL
        }
    }

    wrap_minipage <- function(latex_table, width = "0.48\\linewidth") {
        paste0("\\begin{minipage}[t]{", width, "}\n", latex_table, "\n\\end{minipage}")
    }

    add_table <- function(name, df, caption, escape = TRUE) {
        if (!is.null(df)) {
            kables[[name]] <<- make_table(df, caption, escape = escape)
        }
    }

    # Component 1–6: weights/loadings/scores/coefficients
    add_table("weights.x", pls.result$W, "X Weights (W)")
    add_table("loadings.x", pls.result$P_loadings, "X Loadings (P)")
    add_table("weights.y", pls.result$C, "Y Weights (C)")
    add_table("loadings.y", pls.result$Q_loadings, "Y Loadings (Q)")

    if (!is.null(pls.result$B_vector)) {
        b.df <- data.frame(
            Component = seq_along(pls.result$B_vector),
            Estimate = pls.result$B_vector
        )
        add_table("b.vector", b.df, "Regression Scalars (b)")
    }

    if (!is.null(pls.result$coefficients)) {
        coef.df <- as.data.frame(pls.result$coefficients)
        colnames(coef.df) <- if (ncol(coef.df) > 1) colnames(pls.result$coefficients) else "Estimate"
        add_table("coefficients", coef.df, "Regression Coefficients (Original Scale)")
    }

    # Scores
    if (include.scores) {
        add_table("t.scores", pls.result$T, "X Scores (T)")
        add_table("u.scores", pls.result$U, "Y Scores (U)")
    }

    # Explained Variance (X and Y)
    if (!is.null(pls.result$X_explained)) {
        x.expl <- data.frame(
            `Latent Vector` = seq_along(pls.result$X_explained),
            `Explained Variance` = sprintf("%.4f%%", pls.result$X_explained),
            `Cumulative` = sprintf("%.4f%%", pls.result$X_cum_explained)
        )
        add_table("explained.x", x.expl, "Variance Explained by Components (X)", escape = FALSE)
    }

    if (!is.null(pls.result$Y_explained)) {
        y.expl <- data.frame(
            `Latent Vector` = seq_along(pls.result$Y_explained),
            `Explained Variance` = sprintf("%.4f%%", pls.result$Y_explained),
            `Cumulative` = sprintf("%.4f%%", pls.result$Y_cum_explained)
        )
        add_table("explained.y", y.expl, "Variance Explained by Components (Y)", escape = FALSE)
    }

    if (!latex) {
        return(invisible(NULL))
    } # Console mode ends here

    # === LaTeX output assembly ===

    output <- c()

    join_pair <- function(x, y) paste0(wrap_minipage(x), wrap_minipage(y))

    if (!is.null(kables$weights.x) && !is.null(kables$weights.y)) {
        output <- c(output, join_pair(kables$weights.x, kables$weights.y))
    } else {
        output <- c(output, kables$weights.x, kables$weights.y)
    }

    if (!is.null(kables$loadings.x) && !is.null(kables$loadings.y)) {
        output <- c(output, join_pair(kables$loadings.x, kables$loadings.y))
    } else {
        output <- c(output, kables$loadings.x, kables$loadings.y)
    }

    if (include.scores && !is.null(kables$t.scores) && !is.null(kables$u.scores)) {
        output <- c(output, join_pair(kables$t.scores, kables$u.scores))
    } else {
        output <- c(output, kables$t.scores, kables$u.scores)
    }

    output <- c(output, kables$b.vector, kables$coefficients, kables$explained.x, kables$explained.y)

    return(knitr::asis_output(paste(output, collapse = "\n\n")))
}
