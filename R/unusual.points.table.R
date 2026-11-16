#' Table of Unusual Observations in a Regression
#'
#' Identifies the observations of a fitted regression that should be
#' investigated -- high-leverage points, outliers, influential points and bad
#' leverage points -- and returns them in a table, as LaTeX (for PDF reports)
#' or plain text (for the console), like the other snazzieR summary tables.
#'
#' @details
#' Diagnostics are computed with \code{\link[stats]{hatvalues}},
#' \code{\link[stats]{rstandard}} and \code{\link[stats]{cooks.distance}}, so the function works for any
#' \code{lm} fit (including weighted fits, factors, transformed variables and
#' missing values) and for \code{glm} fits (using deviance residuals).
#' Observations with zero weight are excluded, as in \code{plot.lm}.
#'
#' An observation is listed if it meets at least one of these criteria
#' (defaults follow Sheather, \emph{A Modern Approach to Regression with R}):
#' \describe{
#'   \item{High leverage}{\eqn{h_{ii} > 2(p+1)/n}, twice the average leverage,
#'     where \eqn{p+1} is the number of estimated coefficients.}
#'   \item{Outlier}{\eqn{|r_i| > 2}, where \eqn{r_i} is the standardized
#'     residual. (For large data sets a cutoff of 4 may be more appropriate.)}
#'   \item{Influential}{Cook's distance \eqn{D_i > 4/(n-2)}.}
#'   \item{Bad leverage}{both high leverage and an outlier.}
#' }
#' For each flagged point the table reports its observed and fitted
#' response, leverage, standardized residual, Cook's distance and flags. A
#' legend under the table explains the flags and compares the number of
#' outliers with the number expected by chance.
#'
#' @param model A fitted \code{lm} or \code{glm} object.
#' @param title Table title (its LaTeX caption). Defaults to
#'   \code{"Unusual Observations"}.
#' @param latex Logical; if \code{TRUE} (default) returns a LaTeX table. If
#'   \code{FALSE}, prints a plain-text table and returns the underlying data
#'   frame invisibly.
#' @param id Optional labels to identify observations: either the name of a
#'   column in \code{data} (e.g. \code{"Name"}) or a vector with one label per
#'   row of the data the model was fitted to.
#' @param data The data frame the model was fitted to. Only needed when
#'   \code{id} is a column name and the data cannot be recovered from the
#'   model's call.
#' @param leverage.cutoff Leverage threshold. Defaults to \eqn{2(p+1)/n}.
#' @param residual.cutoff Threshold for \eqn{|}standardized residual\eqn{|}.
#'   Defaults to 2.
#' @param cook.cutoff Cook's distance threshold. Defaults to \eqn{4/(n-2)}.
#' @param flag Which criteria make an observation unusual: any of
#'   \code{"leverage"}, \code{"outlier"} and \code{"influential"} (default:
#'   all three). For example, \code{flag = c("leverage", "outlier")} leaves out
#'   points that are only flagged by Cook's distance.
#' @param n.max Maximum number of observations to list (default \code{NULL},
#'   no limit). When more are flagged, the \code{n.max} with the largest
#'   Cook's distance are kept and the legend says how many were left out.
#' @param digits Number of significant digits shown. Defaults to 4.
#'
#' @return If \code{latex = TRUE}, a LaTeX table of class
#'   \code{"snazzieR_table"} (see \code{\link{snazzieR_table}} for interactive
#'   previews). If \code{latex = FALSE}, the table is printed and a data frame
#'   with one row per flagged observation (sorted by Cook's distance) is
#'   returned invisibly. Its \code{"cutoffs"} attribute holds the thresholds
#'   used.
#'
#' @seealso \code{\link{diagnostics.plots}}, \code{\link{model.summary.table}}
#' @export
#'
#' @examples
#' model <- lm(mpg ~ wt + hp, data = mtcars)
#'
#' # Plain-text table, labelling cars by name
#' unusual.points.table(model, latex = FALSE, id = rownames(mtcars))
#'
#' # Only the 3 most influential, ignoring points flagged by Cook's D alone
#' unusual.points.table(model, latex = FALSE, id = rownames(mtcars),
#'                      flag = c("leverage", "outlier"), n.max = 3)
#'
#' # LaTeX table for a PDF report
#' tbl <- unusual.points.table(model, title = "Cars to Investigate")
unusual.points.table <- function(model,
                                 title = "Unusual Observations",
                                 latex = TRUE,
                                 id = NULL,
                                 data = NULL,
                                 leverage.cutoff = NULL,
                                 residual.cutoff = 2,
                                 cook.cutoff = NULL,
                                 flag = c("leverage", "outlier", "influential"),
                                 n.max = NULL,
                                 digits = 4) {
  if (!inherits(model, "lm")) {
    stop("`model` must be a regression fitted with lm() or glm().", call. = FALSE)
  }
  flag <- match.arg(flag, several.ok = TRUE)
  if (!is.null(n.max) && (!is.numeric(n.max) || length(n.max) != 1L || n.max < 0)) {
    stop("`n.max` must be a single non-negative number.", call. = FALSE)
  }

  # ---- diagnostics (zero-weight cases are dropped by the influence functions)
  h <- stats::hatvalues(model)
  obs <- names(h)
  r <- stats::rstandard(model)[obs]
  cook <- stats::cooks.distance(model)[obs]
  y <- stats::model.response(stats::model.frame(model))
  if (is.matrix(y)) y <- y[, 1L] / rowSums(y) # binomial cbind(successes, failures)
  names(y) <- rownames(stats::model.frame(model))
  y <- y[obs]
  fit <- stats::fitted(model)[obs]

  n <- length(h)
  k <- sum(!is.na(stats::coef(model))) # p + 1 estimated coefficients
  lev.default <- is.null(leverage.cutoff)
  if (lev.default) leverage.cutoff <- 2 * k / n
  if (is.null(cook.cutoff)) cook.cutoff <- 4 / (n - 2)

  # Only the chosen criteria count (and are shown as flags).
  high.lev <- if ("leverage" %in% flag) h > leverage.cutoff else rep(FALSE, n)
  outlier.all <- abs(r) > residual.cutoff
  outlier <- if ("outlier" %in% flag) outlier.all else rep(FALSE, n)
  influential <- if ("influential" %in% flag) cook > cook.cutoff else rep(FALSE, n)
  flagged <- which((high.lev | outlier | influential) %in% TRUE)
  flagged <- flagged[order(-cook[flagged])]
  n.flagged <- length(flagged)
  if (!is.null(n.max) && n.flagged > n.max) flagged <- flagged[seq_len(n.max)]

  # ---- labels ---------------------------------------------------------------
  labels <- NULL
  if (!is.null(id)) {
    if (is.null(data)) {
      data <- tryCatch(eval(model$call$data, environment(stats::formula(model))),
                       error = function(e) NULL)
    }
    if (is.character(id) && length(id) == 1L) {
      if (!is.data.frame(data) || !id %in% names(data)) {
        stop("Could not find column `", id, "`; pass the data with `data =`.", call. = FALSE)
      }
      labels <- as.character(data[[id]])
      names(labels) <- rownames(data)
    } else {
      labels <- as.character(id)
      names(labels) <- if (is.data.frame(data) && length(labels) == nrow(data)) {
        rownames(data)
      } else if (length(labels) == length(obs)) {
        obs
      } else {
        stop("`id` must have one label per row of the data.", call. = FALSE)
      }
    }
  }

  codes <- vapply(seq_len(n), function(i) {
    paste(c(
      if (isTRUE(high.lev[i]) && isTRUE(outlier[i])) "B" else if (isTRUE(high.lev[i])) "L",
      if (isTRUE(outlier[i]) && !isTRUE(high.lev[i])) "O",
      if (isTRUE(influential[i])) "I"
    ), collapse = " ")
  }, character(1))

  flags <- vapply(seq_len(n), function(i) {
    f <- c(
      if (isTRUE(high.lev[i]) && isTRUE(outlier[i])) "bad leverage"
      else if (isTRUE(high.lev[i])) "high leverage",
      if (isTRUE(outlier[i]) && !isTRUE(high.lev[i])) "outlier",
      if (isTRUE(influential[i])) "influential"
    )
    paste(f, collapse = ", ")
  }, character(1))

  out <- data.frame(
    Obs = obs[flagged],
    check.names = FALSE, stringsAsFactors = FALSE
  )
  # Skip the ID column when it would just repeat the row names.
  if (!is.null(labels) && identical(unname(labels[obs]), obs)) labels <- NULL
  if (!is.null(labels)) out$ID <- unname(labels[obs[flagged]])
  out$Observed <- unname(y[flagged])
  out$Fitted <- unname(fit[flagged])
  out$Leverage <- unname(h[flagged])
  out$`Std. Resid.` <- unname(r[flagged])
  out$`Cook's D` <- unname(cook[flagged])
  out$Flags <- flags[flagged]
  rownames(out) <- NULL

  cutoffs <- c(leverage = leverage.cutoff, residual = residual.cutoff, cook = cook.cutoff)
  attr(out, "cutoffs") <- cutoffs
  attr(out, "n.flagged") <- n.flagged

  expected <- n * 2 * stats::pnorm(-residual.cutoff)
  n.out <- sum(outlier.all, na.rm = TRUE)
  lev.txt <- format_num(leverage.cutoff, 3)
  # With the default cutoff, show where it comes from: 2(p+1)/n.
  lev.plain <- if (lev.default) sprintf("%s = 2(%d)/%d = 2(p+1)/n", lev.txt, k, n) else lev.txt
  lev.tex <- if (lev.default) {
    sprintf("%s = \\frac{2(%d)}{%d} = \\frac{2(p+1)}{n}", lev.txt, k, n)
  } else {
    lev.txt
  }
  res.txt <- format_num(residual.cutoff, 3)
  cook.txt <- format_num(cook.cutoff, 3)
  both <- all(c("leverage", "outlier") %in% flag)
  shown.txt <- if (length(flagged) < n.flagged) {
    sprintf("Showing the %d with the largest Cook's D of %d flagged observations.", length(flagged), n.flagged)
  }
  outlier.txt <- sprintf("%d of %d observations have |std. resid.| > %s; about %.1f would be expected by chance.",
                         n.out, n, res.txt, expected)
  notes <- c(
    paste0("Flags: ", paste(c(
      if ("leverage" %in% flag) sprintf("high leverage = h > %s", lev.plain),
      if ("outlier" %in% flag) sprintf("outlier = |std. resid.| > %s", res.txt),
      if ("influential" %in% flag) sprintf("influential = Cook's D > %s", cook.txt),
      if (both) "bad leverage = both"
    ), collapse = ";  "), "."),
    paste("Outliers:", outlier.txt),
    shown.txt
  )

  # Formatted copy for display
  shown <- out
  num.cols <- c("Observed", "Fitted", "Leverage", "Std. Resid.", "Cook's D")
  for (col in num.cols) shown[[col]] <- format_num(shown[[col]], digits)
  if (!nrow(shown)) {
    shown <- data.frame(Result = "No observations exceed the cutoffs.")
  }

  if (latex) {
    if (nrow(out)) {
      tex <- data.frame(Obs = latex_escape(out$Obs), check.names = FALSE, stringsAsFactors = FALSE)
      if (!is.null(labels)) tex$ID <- latex_escape(out$ID)
      for (col in num.cols) tex[[col]] <- shown[[col]]
      tex$Flags <- codes[flagged]
      names(tex) <- c("Obs", if (!is.null(labels)) "ID",
                      "$y$", "$\\hat{y}$", "$h_{ii}$", "$r_i$", "$D_i$", "Flags")
      align <- c("l", if (!is.null(labels)) "l", rep("r", length(num.cols)), "c")
    } else {
      tex <- shown
      align <- "l"
    }
    # Legend: the flags on one line (shrunk to fit if needed), then the outlier count.
    flag.line <- paste(c(
      if ("leverage" %in% flag) sprintf("L = high leverage ($h_{ii} > %s$)", lev.tex),
      if ("outlier" %in% flag) sprintf("O = outlier ($|r_i| > %s$)", res.txt),
      if ("influential" %in% flag) sprintf("I = influential ($D_i > %s$)", cook.txt),
      if (both) "B = bad leverage (L and O)"
    ), collapse = "\\quad ")
    tex.notes <- c(
      paste0("\\resizebox{\\ifdim\\width>\\linewidth\\linewidth\\else\\width\\fi}{!}{\\textbf{Flags:}\\enspace ",
             flag.line, "}"),
      sprintf("\\textbf{Outliers:}\\enspace %d of %d observations have $|r_i| > %s$; about %.1f expected by chance.",
              n.out, n, res.txt, expected),
      if (!is.null(shown.txt)) {
        sprintf("\\textbf{Shown:}\\enspace the %d with the largest $D_i$ of %d flagged observations.",
                length(flagged), n.flagged)
      }
    )
    latex.table <- knitr::kable(
      tex,
      format = "latex",
      caption = caption_placeholder,
      align = align,
      row.names = FALSE,
      escape = FALSE
    ) |>
      kableExtra::row_spec(0, bold = TRUE) |>
      kableExtra::column_spec(1, border_left = TRUE, bold = TRUE) |>
      kableExtra::column_spec(ncol(tex), border_right = TRUE) |>
      kableExtra::kable_styling(latex_options = c("HOLD_position", "scale_down"), font_size = 9)
    latex.table <- append_latex_notes(latex.table, tex.notes)
    latex.table <- set_latex_caption(latex.table, paste0("\\textbf{", title, "}"))
    snazzieR_wrap(latex.table, list(preview_table(shown, caption = title, notes = notes, row.names = FALSE)))
  } else {
    cat(paste0("== ", title, " ==\n"))
    print(knitr::kable(shown, format = "simple", row.names = FALSE))
    cat("\n", paste(notes, collapse = "\n"), "\n", sep = "")
    invisible(out)
  }
}

# Format numbers to `digits` significant digits without scientific notation
# for ordinary magnitudes.
format_num <- function(x, digits = 4) {
  out <- formatC(signif(x, digits), format = "fg", digits = digits, big.mark = "")
  small <- !is.na(x) & x != 0 & abs(x) < 1e-4
  out[small] <- formatC(x[small], format = "e", digits = digits - 1)
  trimws(out)
}

# Escape text for use in a LaTeX table cell.
latex_escape <- function(x) {
  x <- gsub("\\", "\001", x, fixed = TRUE) # placeholder so its braces are not escaped
  x <- gsub("([&%$#_{}])", "\\\\\\1", x)
  x <- gsub("~", "\\textasciitilde{}", x, fixed = TRUE)
  x <- gsub("^", "\\textasciicircum{}", x, fixed = TRUE)
  # < and > print as inverted punctuation under the default OT1 font encoding
  x <- gsub("<", "\\textless{}", x, fixed = TRUE)
  x <- gsub(">", "\\textgreater{}", x, fixed = TRUE)
  gsub("\001", "\\textbackslash{}", x, fixed = TRUE)
}

# Put notes under a LaTeX table in their own page-width block (not a
# threeparttable) so they wrap even when a wide table is scaled down to fit.
append_latex_notes <- function(latex.table, notes) {
  notes.tex <- paste0(
    "\\par\\smallskip\n\\begin{minipage}{\\linewidth}\\centering\\footnotesize\n",
    paste(notes, collapse = "\\\\[2pt]\n"),
    "\n\\end{minipage}\n"
  )
  pos <- regexpr("\\\\end\\{table\\}", latex.table)
  if (pos < 0) return(latex.table)
  attrs <- attributes(latex.table)
  out <- paste0(substr(latex.table, 1, pos - 1), notes.tex, substring(latex.table, pos))
  attributes(out) <- attrs
  out
}
