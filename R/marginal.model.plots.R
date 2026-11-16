#' Snazzy Marginal Model Plots
#'
#' Draws marginal model plots for a linear model, the same plots as
#' \code{car::mmps(model)}, as a single faceted \pkg{ggplot2} plot styled with
#' \code{\link{snazzieR.theme}()}. Only \pkg{ggplot2} is required; \pkg{car} is
#' not needed.
#'
#' @details
#' For each eligible term in the model, and for the fitted values, the
#' response is plotted against that variable together with two smooths:
#' \describe{
#'   \item{Data}{(solid) a loess smooth of the response on the variable;}
#'   \item{Model}{(dashed) a loess smooth of the model's fitted values on the
#'     variable.}
#' }
#' If the model is adequate the two smooths should agree. The smooths match
#' those drawn by \pkg{car}: \code{\link[stats]{loess}} with
#' \code{span = 2/3}, \code{degree = 1}, \code{family = "symmetric"} and four
#' robustness iterations, evaluated at 50 equally spaced points.
#'
#' As in \code{car::mmps()}, factors and interaction terms are skipped, and
#' matrix terms such as \code{poly()} or spline bases are replaced by their
#' fitted linear combination (\code{predict(model, type = "terms")}). The
#' panel layout follows \pkg{car}'s defaults (e.g. 3 x 3 for 7 to 9 panels).
#'
#' @param model A fitted \code{lm} object.
#' @param fitted Logical; include the panel against the fitted values
#'   (default \code{TRUE}).
#' @param ncol Number of panel columns. Defaults to \pkg{car}'s layout.
#' @param title Plot title. Defaults to \code{"Marginal Model Plots"} (or
#'   \code{"Marginal Model Plot"} for a single panel), as in \pkg{car}.
#'
#' @return A \code{ggplot} object. Its title is drawn as the legend title,
#'   so the Data/Model key sits to the right of it.
#'
#' @seealso \code{\link{diagnostics.plots}}
#' @export
#'
#' @examples
#' model <- lm(mpg ~ wt + hp + qsec, data = mtcars)
#' marginal.model.plots(model)
#'
#' # Label which model the plots belong to
#' marginal.model.plots(model, title = "Marginal Model Plots: Fuel Economy")
marginal.model.plots <- function(model, fitted = TRUE, ncol = NULL, title = NULL) {
  if (!inherits(model, "lm") || inherits(model, "glm")) {
    stop("`model` must be a linear model fitted with lm().", call. = FALSE)
  }

  mf <- stats::model.frame(model)
  resp <- stats::model.response(mf)
  ylab <- names(mf)[1L]
  yhat <- stats::predict(model)

  tt <- stats::terms(model)
  term.labels <- attr(tt, "term.labels")
  term.order <- attr(tt, "order")

  panels <- list()
  term.contrib <- NULL
  for (j in seq_along(term.labels)) {
    lab <- term.labels[j]
    if (term.order[j] > 1 || !lab %in% names(mf)) next
    v <- mf[[lab]]
    if (is.factor(v) || is.character(v) || is.logical(v)) next
    if (is.matrix(v)) {
      if (is.null(term.contrib)) {
        term.contrib <- tryCatch(stats::predict(model, type = "terms"), error = function(e) FALSE)
        if (!isFALSE(term.contrib)) {
          warning("Splines and/or polynomials replaced by a fitted linear combination", call. = FALSE)
        }
      }
      if (isFALSE(term.contrib)) next
      v <- term.contrib[, lab]
    }
    panels[[lab]] <- as.numeric(v)
  }
  if (isTRUE(fitted)) panels[["Fitted values"]] <- as.numeric(stats::fitted(model))
  nt <- length(panels)
  if (nt == 0) stop("No plots specified", call. = FALSE)

  loess_line <- function(x, y) {
    ok <- stats::complete.cases(x, y)
    x <- x[ok]
    y <- y[ok]
    x.eval <- seq(min(x), max(x), length.out = 50)
    fit <- tryCatch(
      suppressWarnings(stats::loess(
        y ~ x, span = 2 / 3, degree = 1, family = "symmetric",
        control = stats::loess.control(iterations = 4)
      )),
      error = function(e) NULL
    )
    if (is.null(fit)) {
      warning("could not fit smooth", call. = FALSE)
      return(NULL)
    }
    data.frame(x = x.eval, y = as.numeric(stats::predict(fit, newdata = data.frame(x = x.eval))))
  }

  levels <- names(panels)
  points <- do.call(rbind, lapply(levels, function(nm) {
    data.frame(panel = nm, x = panels[[nm]], y = as.numeric(resp))
  }))
  smooths <- do.call(rbind, lapply(levels, function(nm) {
    data.line <- loess_line(panels[[nm]], as.numeric(resp))
    model.line <- loess_line(panels[[nm]], as.numeric(yhat))
    rbind(
      if (!is.null(data.line)) cbind(panel = nm, source = "Data", data.line),
      if (!is.null(model.line)) cbind(panel = nm, source = "Model", model.line)
    )
  }))
  points$panel <- factor(points$panel, levels = levels)
  smooths$panel <- factor(smooths$panel, levels = levels)
  smooths$source <- factor(smooths$source, levels = c("Data", "Model"))

  main <- if (!is.null(title)) title else if (nt == 1) "Marginal Model Plot" else "Marginal Model Plots"

  if (is.null(ncol)) {
    layout <- if (nt <= 9) {
      list(c(1, 1), c(1, 2), c(2, 2), c(2, 2), c(3, 2), c(3, 2), c(3, 3), c(3, 3), c(3, 3))[[nt]]
    } else {
      rows <- round(sqrt(nt))
      c(rows, ceiling(nt / rows))
    }
    ncol <- layout[2L]
  }

  ggplot2::ggplot() +
    ggplot2::geom_point(
      data = points, ggplot2::aes(x = .data$x, y = .data$y),
      shape = 1, color = Deep.Grey, size = 1.4
    ) +
    ggplot2::geom_line(
      data = smooths,
      ggplot2::aes(x = .data$x, y = .data$y, color = .data$source, linetype = .data$source),
      linewidth = 0.9
    ) +
    # The title doubles as the legend title so the key sits to its right.
    ggplot2::scale_color_manual(name = main, values = c(Data = Blue, Model = Red)) +
    ggplot2::scale_linetype_manual(name = main, values = c(Data = "solid", Model = "dashed")) +
    ggplot2::facet_wrap(~panel, scales = "free_x", ncol = ncol, strip.position = "bottom") +
    ggplot2::labs(x = NULL, y = ylab) +
    snazzieR.theme() +
    ggplot2::theme(
      strip.placement = "outside",
      strip.background = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(color = "black", size = 12, face = "bold", family = "Times"),
      legend.position = "top",
      legend.justification = "center",
      legend.direction = "horizontal",
      legend.title.position = "left",
      legend.title = ggplot2::element_text(
        face = "bold", color = "#83B02F", size = 18, family = "Times",
        margin = ggplot2::margin(r = 18, unit = "pt")
      ),
      legend.text = ggplot2::element_text(family = "Times", size = 11),
      legend.key.width = ggplot2::unit(1.4, "cm"),
      panel.spacing = ggplot2::unit(0.6, "cm")
    )
}
