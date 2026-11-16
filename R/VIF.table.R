#' Variance Inflation Factor Table
#'
#' Computes variance inflation factors (VIFs) for the terms of a regression to
#' diagnose multicollinearity, and returns them as a LaTeX table (for PDF
#' reports) or plain text (for the console), like the other snazzieR summary
#' tables. \pkg{car} is not required.
#'
#' @details
#' VIFs are computed from the correlation matrix of the estimated coefficients,
#' exactly as \code{car::vif()} does, so they are valid for weighted
#' \code{lm} fits and for \code{glm} fits. For a numeric predictor,
#' \eqn{\mathrm{VIF}_j = 1/(1 - R^2_j)}, where \eqn{R^2_j} is from regressing
#' that predictor on all the others.
#'
#' The available columns are:
#' \describe{
#'   \item{VIF}{The variance inflation factor. Terms with more than one
#'     coefficient (factors, \code{poly()}, splines) have no ordinary VIF, so
#'     their VIF is reported as \eqn{(\textrm{adj. GVIF})^2}, which is on the
#'     same scale and equals the ordinary VIF for one-df terms.}
#'   \item{1/VIF}{The tolerance, \eqn{1 - R^2_j}.}
#'   \item{GVIF}{The generalized VIF of Fox and Monette (1992); equal to the
#'     VIF for one-df terms.}
#'   \item{adj. GVIF}{\eqn{\mathrm{GVIF}^{1/(2\,\mathrm{Df})}}, comparable
#'     across terms with different degrees of freedom. Each cell also shows the
#'     term's degrees of freedom, e.g. \code{1.547 (df = 2)}.}
#' }
#' The \code{Term} and \code{Flag} columns are always shown. Terms are flagged
#' \emph{moderate} when the VIF exceeds \code{moderate} (default 5) and
#' \emph{severe} when it exceeds \code{severe} (default 10). Rows are sorted
#' from the highest VIF to the lowest. Aliased (perfectly collinear)
#' coefficients are dropped and listed in the notes under the table.
#'
#' @param model A fitted \code{lm} or \code{glm} object with at least two
#'   terms.
#' @param title Table title (its LaTeX caption). Defaults to
#'   \code{"Variance Inflation Factors"}.
#' @param latex Logical; if \code{TRUE} (default) returns a LaTeX table. If
#'   \code{FALSE}, prints a plain-text table and returns the underlying data
#'   frame invisibly.
#' @param cols Columns to show: \code{"all"} (default) or any combination of
#'   \code{"VIF"}, \code{"1/VIF"}, \code{"GVIF"} and \code{"adj. GVIF"}.
#'   \code{Term} and \code{Flag} are always included.
#' @param moderate,severe VIF cutoffs for flagging moderate and severe
#'   multicollinearity. Default 5 and 10.
#' @param digits Number of significant digits shown. Defaults to 4.
#'
#' @return If \code{latex = TRUE}, a LaTeX table of class
#'   \code{"snazzieR_table"} (see \code{\link{snazzieR_table}} for interactive
#'   previews). If \code{latex = FALSE}, the table is printed and a data frame
#'   of the shown columns, one row per term, is returned invisibly.
#'
#' @references Fox, J. and Monette, G. (1992). Generalized collinearity
#'   diagnostics. \emph{Journal of the American Statistical Association},
#'   87, 178--183.
#'
#' @seealso \code{\link{unusual.points.table}}, \code{\link{model.summary.table}}
#' @export
#'
#' @examples
#' model <- lm(mpg ~ wt + hp + disp + qsec, data = mtcars)
#' VIF.table(model, latex = FALSE)
#'
#' # Factors get generalized VIFs
#' VIF.table(lm(mpg ~ wt + hp + factor(cyl), data = mtcars), latex = FALSE)
#'
#' # Only some columns
#' VIF.table(model, latex = FALSE, cols = c("VIF", "1/VIF"))
#'
#' # LaTeX table for a PDF report
#' tbl <- VIF.table(model, title = "Collinearity Check")
VIF.table <- function(model,
                      title = "Variance Inflation Factors",
                      latex = TRUE,
                      cols = "all",
                      moderate = 5,
                      severe = 10,
                      digits = 4) {
  if (!inherits(model, "lm")) {
    stop("`model` must be a regression fitted with lm() or glm().", call. = FALSE)
  }
  all.cols <- c("VIF", "1/VIF", "GVIF", "adj. GVIF")
  if (identical(cols, "all")) cols <- all.cols
  bad <- setdiff(cols, all.cols)
  if (length(bad) || !length(cols)) {
    stop("`cols` must be \"all\" or any of: ", paste0('"', all.cols, '"', collapse = ", "),
         ". Unknown: ", paste0('"', bad, '"', collapse = ", "), call. = FALSE)
  }
  cols <- all.cols[all.cols %in% cols] # keep a fixed column order

  b <- stats::coef(model)
  ok <- !is.na(b) # drop aliased coefficients
  mm.full <- stats::model.matrix(model)
  V <- stats::vcov(model)[ok, ok, drop = FALSE]
  mm <- mm.full[, ok, drop = FALSE]
  assign <- attr(mm.full, "assign")[ok]
  term.labels <- attr(stats::terms(model), "term.labels")
  has.intercept <- colnames(mm)[1L] == "(Intercept)"
  if (has.intercept) {
    V <- V[-1L, -1L, drop = FALSE]
    assign <- assign[-1L]
  }
  if (any(!is.finite(V))) stop("The coefficient covariance matrix contains non-finite values.", call. = FALSE)
  terms.used <- unique(assign)
  if (length(terms.used) < 2L) {
    stop("The model needs at least two terms to compute VIFs.", call. = FALSE)
  }

  R <- stats::cov2cor(V)
  det.R <- det(R)
  rows <- lapply(terms.used, function(t) {
    sub <- which(assign == t)
    gvif <- det(R[sub, sub, drop = FALSE]) * det(R[-sub, -sub, drop = FALSE]) / det.R
    data.frame(Term = term.labels[t], Df = length(sub), GVIF = gvif)
  })
  out <- do.call(rbind, rows)
  out$Adjusted <- out$GVIF^(1 / (2 * out$Df))
  multi.df <- any(out$Df > 1)

  # ---- severity --------------------------------------------------------------
  comparable <- out$Adjusted^2 # equals the VIF for one-df terms
  out$Flag <- ifelse(comparable > severe, "severe", ifelse(comparable > moderate, "moderate", ""))

  # Highest VIF first (multi-df terms ranked by (GVIF^(1/(2 Df)))^2).
  ord <- order(comparable, decreasing = TRUE)
  out <- out[ord, , drop = FALSE]
  comparable <- comparable[ord]

  out$VIF <- comparable # ordinary VIF for one-df terms, (adj. GVIF)^2 otherwise
  out$`1/VIF` <- 1 / out$VIF
  names(out)[names(out) == "Adjusted"] <- "adj. GVIF"
  term.df <- out$Df
  out <- out[, c("Term", cols, "Flag"), drop = FALSE]
  rownames(out) <- NULL

  # ---- notes -----------------------------------------------------------------
  mean.vif <- mean(comparable)
  rule <- sprintf("Moderate: VIF > %s.  Severe: VIF > %s.  Mean VIF = %s.",
                  format_num(moderate, 3), format_num(severe, 3), format_num(mean.vif, 3))
  extra <- c(
    if ("adj. GVIF" %in% cols) "adj. GVIF = GVIF^(1/(2 Df)).",
    if (multi.df && "VIF" %in% cols) "For multi-df terms, VIF = (adj. GVIF)^2."
  )
  cautions <- c(
    if (any(attr(stats::terms(model), "order") > 1)) {
      "The model has interaction terms; VIFs of terms involved in interactions are hard to interpret."
    },
    if (!has.intercept) "The model has no intercept; VIFs may not be sensible.",
    if (any(!ok)) {
      sprintf("Aliased (perfectly collinear) coefficients were dropped: %s.",
              paste(names(b)[!ok], collapse = ", "))
    }
  )
  notes <- c(rule, if (length(extra)) paste(extra, collapse = "  "), cautions)

  shown <- out
  for (col in intersect(names(shown), c("VIF", "1/VIF", "GVIF", "adj. GVIF"))) {
    shown[[col]] <- format_num(shown[[col]], digits)
  }
  if ("adj. GVIF" %in% names(shown)) {
    shown$`adj. GVIF` <- sprintf("%s (df = %d)", shown$`adj. GVIF`, term.df)
  }

  if (latex) {
    tex <- shown
    tex$Term <- latex_escape(tex$Term)
    tex.extra <- c(
      if ("adj. GVIF" %in% cols) "adj. GVIF $= \\mathrm{GVIF}^{1/(2\\,\\mathrm{Df})}$.",
      if (multi.df && "VIF" %in% cols) "For multi-df terms, VIF $= (\\textrm{adj. GVIF})^2$."
    )
    tex.notes <- c(latex_escape(rule),
                   if (length(tex.extra)) paste(tex.extra, collapse = "\\quad "),
                   latex_escape(cautions))
    align <- c("l", rep("r", ncol(tex) - 2L), "l")
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
      kableExtra::kable_styling(latex_options = c("HOLD_position", "scale_down"))
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
