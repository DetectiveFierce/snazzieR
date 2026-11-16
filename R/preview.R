#' Interactive Previews for snazzieR Tables
#'
#' @description
#' The LaTeX tables returned by \code{\link{model.summary.table}},
#' \code{\link{ANOVA.summary.table}}, \code{\link{eigen.summary}},
#' \code{\link{pls.summary}}, \code{\link{ridge.summary}} and
#' \code{\link{format.pls}} carry the class \code{"snazzieR_table"}.
#' This lets them show a readable preview when a chunk is run interactively
#' (for example with the play button in the RStudio or Positron editor),
#' while knitting produces exactly the same LaTeX as before.
#'
#' @details
#' When a document is being knitted, printing is handed straight to the
#' underlying \pkg{knitr}/\pkg{kableExtra} method, so compiled output does
#' not change. Outside of knitting, the preview style is controlled by the
#' option \code{snazzieR.preview}:
#' \describe{
#'   \item{\code{"auto"}}{(default) An HTML preview in RStudio or Positron,
#'     a plain-text preview in other interactive sessions, and the raw LaTeX
#'     in non-interactive sessions.}
#'   \item{\code{"html"}}{Always render an HTML preview.}
#'   \item{\code{"text"}}{Always print a plain-text preview.}
#'   \item{\code{"latex"}}{Always print the raw LaTeX source.}
#' }
#'
#' @param x A \code{"snazzieR_table"} object.
#' @param ... Further arguments passed to the underlying print method.
#'
#' @return \code{x}, invisibly.
#'
#' @examples
#' model <- lm(mpg ~ wt + hp, data = mtcars)
#' tbl <- model.summary.table(model, title = "Fuel Economy")
#'
#' # Force a plain-text preview
#' old <- options(snazzieR.preview = "text")
#' print(tbl)
#' options(old)
#'
#' @name snazzieR_table
#' @export
print.snazzieR_table <- function(x, ...) {
  mode <- snazzieR_preview_mode()
  if (mode == "latex") {
    print(snazzieR_unwrap(x), ...)
  } else if (mode == "html") {
    print(snazzieR_preview_html(x))
  } else {
    snazzieR_preview_text(x)
  }
  invisible(x)
}

#' @rdname snazzieR_table
#' @param options Chunk options, passed on by \pkg{knitr}.
#' @exportS3Method knitr::knit_print
knit_print.snazzieR_table <- function(x, options = list(), ...) {
  if (isTRUE(getOption("knitr.in.progress"))) {
    knitr::knit_print(snazzieR_unwrap(x), options = options, ...)
  } else {
    print.snazzieR_table(x)
  }
}

# ---- internal helpers --------------------------------------------------------

# Attach preview information to a LaTeX table without touching its content.
# `tables` is a list of list(data = <data.frame>, caption = <chr>, notes = <chr>).
snazzieR_wrap <- function(x, tables) {
  attr(x, "snazzieR.preview") <- tables
  class(x) <- unique(c("snazzieR_table", class(x)))
  x
}

snazzieR_unwrap <- function(x) {
  attr(x, "snazzieR.preview") <- NULL
  class(x) <- setdiff(class(x), "snazzieR_table")
  x
}

# `row.names` mirrors knitr::kable(): NA shows non-automatic row names
# (e.g. predictor names), FALSE never shows them.
# Insert LaTeX on its own line just before the tabular material of a kable
# (after the caption and \\centering), keeping the object's attributes.
insert_before_table <- function(x, latex) {
  pos <- regexpr("\\\\begin\\{(threeparttable|tabular)", x)
  if (pos < 0) return(x)
  out <- paste0(substr(x, 1, pos - 1), latex, "\n", substring(x, pos))
  attributes(out) <- attributes(x)
  out
}

preview_table <- function(data, caption = NULL, notes = NULL, row.names = NA) {
  data <- as.data.frame(data, check.names = FALSE, stringsAsFactors = FALSE)
  if (isTRUE(row.names) || (is.na(row.names) && .row_names_info(data) > 0)) {
    data <- cbind(stats::setNames(data.frame(rownames(data)), " "), data)
    rownames(data) <- NULL
  }
  colnames(data) <- strip_latex(colnames(data))
  for (j in seq_along(data)) {
    if (is.character(data[[j]])) data[[j]] <- strip_latex(data[[j]])
  }
  list(data = data, caption = caption, notes = notes)
}

# Undo the small bits of LaTeX markup some tables carry in their cells.
strip_latex <- function(x) {
  x <- gsub("\\%", "%", x, fixed = TRUE)
  x <- gsub("~", " ", x, fixed = TRUE)
  x
}

snazzieR_preview_mode <- function() {
  mode <- getOption("snazzieR.preview", "auto")
  mode <- match.arg(mode, c("auto", "html", "text", "latex"))
  if (mode != "auto") {
    return(mode)
  }
  if (isTRUE(getOption("knitr.in.progress")) || !interactive()) {
    return("latex")
  }
  if (nzchar(Sys.getenv("RSTUDIO")) || nzchar(Sys.getenv("POSITRON"))) {
    return("html")
  }
  "text"
}

snazzieR_preview_css <- "
.snazzier-preview { font-family: 'Times New Roman', Times, serif; color: #151315;
  background: #FFFFFF; padding: 8px 4px; }
.snazzier-preview table { border-collapse: collapse; margin: 0 auto 18px auto;
  font-size: 14px; }
.snazzier-preview caption { caption-side: top; font-weight: bold; color: #304011;
  padding-bottom: 6px; text-align: center; }
.snazzier-preview th { border-top: 2px solid #151315; border-bottom: 1px solid #151315;
  padding: 4px 10px; font-weight: bold; }
.snazzier-preview td { padding: 3px 10px; }
.snazzier-preview tbody tr:last-child td { border-bottom: 2px solid #151315; }
.snazzier-preview tbody tr:nth-child(even) { background: #FFF8DC; }
.snazzier-preview .snazzier-note { text-align: center; font-size: 12px; color: #403A3F;
  margin: -12px 0 18px 0; }
"

snazzieR_preview_html <- function(x) {
  tables <- attr(x, "snazzieR.preview")
  pieces <- vapply(tables, function(tbl) {
    caption <- if (is.null(tbl$caption)) NULL else html_escape(tbl$caption)
    body <- knitr::kable(
      tbl$data,
      format = "html",
      caption = caption,
      row.names = FALSE,
      escape = TRUE
    )
    notes <- if (length(tbl$notes)) {
      paste0("<div class=\"snazzier-note\">", html_escape(paste(tbl$notes, collapse = " &middot; ")), "</div>")
    } else {
      ""
    }
    paste0(as.character(body), notes)
  }, character(1))

  htmltools::browsable(htmltools::tagList(
    htmltools::tags$style(htmltools::HTML(snazzieR_preview_css)),
    htmltools::div(class = "snazzier-preview", htmltools::HTML(paste(pieces, collapse = "\n")))
  ))
}

snazzieR_preview_text <- function(x) {
  tables <- attr(x, "snazzieR.preview")
  for (tbl in tables) {
    if (!is.null(tbl$caption)) cat("== ", tbl$caption, " ==\n", sep = "")
    print(knitr::kable(tbl$data, format = "simple", row.names = FALSE))
    if (length(tbl$notes)) cat(paste(tbl$notes, collapse = "\n"), "\n", sep = "")
    cat("\n")
  }
}

html_escape <- function(x) {
  x <- gsub("&(?!middot;)", "&amp;", x, perl = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}
