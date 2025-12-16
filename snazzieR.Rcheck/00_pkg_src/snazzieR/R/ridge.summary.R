#' @title Format Ridge Model Output as LaTeX Tables
#'
#' @description
#' Formats and displays ridge regression model output from \code{ridge.regression()}
#' as LaTeX tables for PDF rendering or plain text for console viewing.
#'
#' @param x A ridge model object returned by \code{\link{ridge.regression}()} (class \code{"ridge.model"}).
#' @param ... Further arguments passed to or from methods (unused).
#' @param include.cv.trace Logical. Whether to include cross-validation trace information. Default is \code{TRUE}.
#' @param latex Logical; if \code{TRUE} (default), returns LaTeX-formatted tables using \code{kableExtra}.
#'        If \code{FALSE}, prints plain-text summary tables to the console.
#'
#' @return If \code{latex = TRUE}, returns a \code{knitr::asis_output} object (LaTeX code) for PDF rendering.
#'         If \code{latex = FALSE}, prints formatted summary tables to the console and returns the underlying data frames.
#'
#' @export
#'
#' @examples
#' # Load example data
#' data(mtcars)
#'
#' # Fit ridge regression model
#' ridge.fit <- ridge.regression(mpg ~ wt + hp + disp, data = mtcars)
#'
#' # Print a LaTeX-formatted summary
#' ridge.summary(ridge.fit, include.cv.trace = FALSE)
#'
#' # Print a plain-text summary
#' ridge.summary(ridge.fit, include.cv.trace = FALSE, latex = FALSE)
ridge.summary <- function(x, ..., include.cv.trace = TRUE, latex = TRUE) {
    ridge.result <- x # optional: alias for clarity

    if (is.null(ridge.result$method) || ridge.result$method != "ridge") {
        stop("Error! Non-ridge model passed to ridge formatting function (ridge.summary.R)", call. = FALSE)
    }

    # Load required packages
    if (!requireNamespace("knitr", quietly = TRUE)) {
        stop("knitr package is required", call. = FALSE)
    }
    if (latex) {
        if (!requireNamespace("kableExtra", quietly = TRUE)) {
            stop("kableExtra package is required for LaTeX output", call. = FALSE)
        }
        if (!requireNamespace("dplyr", quietly = TRUE)) {
            stop("dplyr package is required for LaTeX output", call. = FALSE)
        }
        `%>%` <- dplyr::`%>%`
    }

    if (latex) {
        kables <- list()

        # === Helper to wrap table in minipage ===
        wrap_minipage <- function(latex_table, width = "0.48\\linewidth") {
            paste0("\\begin{minipage}[t]{", width, "}\n", latex_table, "\n\\end{minipage}")
        }

        # === Build kables ===

        # 1. Model Information (including intercept)
        model.info.df <- data.frame(
            `Parameter` = c("Optimal Lambda", "CV-MSE", "Training MSE", "Number of Predictors", "CV Folds", "Intercept"),
            `Value` = c(
                sprintf("%.6f", ridge.result$optimal.lambda),
                sprintf("%.6f", ridge.result$cv.ms),
                sprintf("%.6f", mean(ridge.result$residuals^2)),
                as.character(length(ridge.result$coefficients)),
                as.character(ridge.result$folds),
                sprintf("%.6f", ridge.result$intercept)
            )
        )

        kables$model.info <- knitr::kable(
            model.info.df,
            format = "latex",
            caption = "Ridge Model Information",
            booktabs = TRUE,
            align = "l",
            escape = FALSE,
            linesep = ""
        ) %>%
            kableExtra::kable_styling(
                bootstrap_options = "striped",
                latex_options = "HOLD_position",
                full_width = FALSE,
                position = "center"
            ) %>%
            kableExtra::column_spec(1, border_left = TRUE, bold = TRUE) %>%
            kableExtra::column_spec(2, border_right = TRUE)

        # 2. Coefficients
        if (!is.null(ridge.result$coefficients) && length(ridge.result$coefficients) > 0) {
            # Use LaTeX code for the column name to ensure the space is preserved in the rendered table.
            coef.df <- data.frame(
                `Predictor` = names(ridge.result$coefficients),
                `Coefficient` = round(ridge.result$coefficients, 6),
                `Std. Error` = round(ridge.result$std_errors, 6),
                check.names = FALSE
            )
            # Rename the column to use LaTeX code for a non-breaking space
            colnames(coef.df)[colnames(coef.df) == "Std. Error"] <- "Std.~Error"

            kables$coefficients <- knitr::kable(
                coef.df,
                format = "latex",
                caption = "Ridge Regression Coefficients",
                booktabs = TRUE,
                align = "l",
                escape = FALSE,
                row.names = FALSE
            ) %>%
                kableExtra::kable_styling(
                    bootstrap_options = "striped",
                    latex_options = "HOLD_position",
                    full_width = FALSE,
                    position = "center"
                ) %>%
                kableExtra::column_spec(1, border_left = TRUE, bold = TRUE) %>%
                kableExtra::column_spec(3, border_right = TRUE)
        }

        # 4. Cross-validation trace (conditionally)
        if (isTRUE(include.cv.trace) && !is.null(ridge.result$cv.results)) {
            cv.df <- ridge.result$cv.results
            colnames(cv.df) <- c("Lambda", "CV-MSE")
            cv.df$Lambda <- round(cv.df$Lambda, 6)
            cv.df$`CV-MSE` <- round(cv.df$`CV-MSE`, 6)

            kables$cv.trace <- knitr::kable(
                cv.df,
                format = "latex",
                caption = "Cross-Validation Results",
                booktabs = TRUE,
                align = "c",
                escape = FALSE
            ) %>%
                kableExtra::kable_styling(
                    bootstrap_options = "striped",
                    latex_options = c("HOLD_position", "scale_down"),
                    full_width = FALSE,
                    position = "center"
                ) %>%
                kableExtra::column_spec(1, border_left = TRUE) %>%
                kableExtra::column_spec(2, border_right = TRUE)
        }

        # 5. Scaling information (including response centering)
        if (!is.null(ridge.result$x.scale)) {
            # Create predictor standardization data
            pred.scale.df <- data.frame(
                `Variable` = names(ridge.result$x.scale$mean),
                `Mean` = round(ridge.result$x.scale$mean, 6),
                `Std. Dev.` = round(ridge.result$x.scale$sd, 6)
            )

            # Add response centering information
            if (!is.null(ridge.result$y.center)) {
                resp.center.df <- data.frame(
                    `Variable` = "Response (y)",
                    `Mean` = round(ridge.result$y.center, 6),
                    `Std. Dev.` = "N/A"
                )
                scale.df <- rbind(pred.scale.df, resp.center.df)
            } else {
                scale.df <- pred.scale.df
            }

            kables$scaling <- knitr::kable(
                scale.df,
                format = "latex",
                caption = "Variable Standardization Information",
                booktabs = TRUE,
                align = "l",
                escape = FALSE,
                row.names = FALSE
            ) %>%
                kableExtra::kable_styling(
                    bootstrap_options = "striped",
                    latex_options = "HOLD_position",
                    full_width = FALSE,
                    position = "center"
                ) %>%
                kableExtra::column_spec(1, border_left = TRUE, bold = TRUE) %>%
                kableExtra::column_spec(3, border_right = TRUE)
        }

        # === Dynamic Output Assembly ===

        output <- c()

        # Group: Model information and coefficients
        if (!is.null(kables$model.info) && !is.null(kables$coefficients)) {
            output <- c(output, paste0(
                wrap_minipage(kables$model.info),
                wrap_minipage(kables$coefficients)
            ))
        } else {
            if (!is.null(kables$model.info)) output <- c(output, kables$model.info)
            if (!is.null(kables$coefficients)) output <- c(output, kables$coefficients)
        }

        # Group: Scaling and CV trace
        if (!is.null(kables$scaling) && !is.null(kables$cv.trace)) {
            output <- c(output, paste0(
                wrap_minipage(kables$scaling),
                wrap_minipage(kables$cv.trace)
            ))
        } else {
            if (!is.null(kables$scaling)) output <- c(output, kables$scaling)
            if (!is.null(kables$cv.trace)) output <- c(output, kables$cv.trace)
        }

        # Singles (if not already included in groups)
        if (is.null(kables$model.info) && is.null(kables$coefficients) &&
            is.null(kables$scaling) && is.null(kables$cv.trace)) {
            # If no tables were created, return empty output
            return(knitr::asis_output(""))
        }

        return(knitr::asis_output(paste(output, collapse = "\n\n")))
    } else {
        # === Plain Text Output ===

        # 1. Model Information
        cat("=== Ridge Model Information ===\n")
        model.info.df <- data.frame(
            Parameter = c("Optimal Lambda", "CV-MSE", "Training MSE", "Number of Predictors", "CV Folds", "Intercept"),
            Value = c(
                sprintf("%.6f", ridge.result$optimal.lambda),
                sprintf("%.6f", ridge.result$cv.ms),
                sprintf("%.6f", mean(ridge.result$residuals^2)),
                as.character(length(ridge.result$coefficients)),
                as.character(ridge.result$folds),
                sprintf("%.6f", ridge.result$intercept)
            )
        )
        print(knitr::kable(model.info.df, format = "simple", row.names = FALSE))
        cat("\n")

        # 2. Coefficients
        if (!is.null(ridge.result$coefficients) && length(ridge.result$coefficients) > 0) {
            cat("=== Ridge Regression Coefficients ===\n")
            coef.df <- data.frame(
                Predictor = names(ridge.result$coefficients),
                Coefficient = round(ridge.result$coefficients, 6),
                `Std.Error` = round(ridge.result$std_errors, 6)
            )
            print(knitr::kable(coef.df, format = "simple", row.names = FALSE))
            cat("\n")
        }

        # 3. Cross-validation trace (conditionally)
        if (isTRUE(include.cv.trace) && !is.null(ridge.result$cv.results)) {
            cat("=== Cross-Validation Results ===\n")
            cv.df <- ridge.result$cv.results
            colnames(cv.df) <- c("Lambda", "CV-MSE")
            cv.df$Lambda <- round(cv.df$Lambda, 6)
            cv.df$`CV-MSE` <- round(cv.df$`CV-MSE`, 6)
            print(knitr::kable(cv.df, format = "simple", row.names = FALSE))
            cat("\n")
        }

        # 4. Scaling information
        if (!is.null(ridge.result$x.scale)) {
            cat("=== Variable Standardization Information ===\n")
            # Create predictor standardization data
            pred.scale.df <- data.frame(
                Variable = names(ridge.result$x.scale$mean),
                Mean = round(ridge.result$x.scale$mean, 6),
                `Std.Dev.` = round(ridge.result$x.scale$sd, 6)
            )

            # Add response centering information
            if (!is.null(ridge.result$y.center)) {
                resp.center.df <- data.frame(
                    Variable = "Response (y)",
                    Mean = round(ridge.result$y.center, 6),
                    `Std.Dev.` = "N/A"
                )
                scale.df <- rbind(pred.scale.df, resp.center.df)
            } else {
                scale.df <- pred.scale.df
            }
            print(knitr::kable(scale.df, format = "simple", row.names = FALSE))
            cat("\n")
        }

        # Return the data frames invisibly for potential further use
        invisible(list(
            model.info = model.info.df,
            coefficients = if (!is.null(ridge.result$coefficients) && length(ridge.result$coefficients) > 0) coef.df else NULL,
            cv.trace = if (isTRUE(include.cv.trace) && !is.null(ridge.result$cv.results)) cv.df else NULL,
            scaling = if (!is.null(ridge.result$x.scale)) scale.df else NULL
        ))
    }
}
