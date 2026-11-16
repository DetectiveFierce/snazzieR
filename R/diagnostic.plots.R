#' Snazzy Regression Diagnostic Plots
#'
#' Draws the four standard diagnostic plots for a linear model (the same
#' panels as \code{plot(model)} for an \code{lm} fit) as a 2 x 2 grid of
#' \pkg{ggplot2} plots styled with \code{\link{snazzieR.theme}()}.
#'
#' @details
#' The panels reproduce \code{\link[stats]{plot.lm}} with its default
#' \code{which = c(1, 2, 3, 5)}:
#' \enumerate{
#'   \item \strong{Residuals vs Fitted}: residuals against fitted values with a
#'     \code{\link[stats]{lowess}} smooth (\code{f = 2/3}, \code{iter = 3}) and
#'     a reference line at zero.
#'   \item \strong{Q-Q Residuals}: standardized residuals against theoretical
#'     normal quantiles (\code{\link[stats]{ppoints}}) with the line through the
#'     first and third quartiles, as drawn by \code{\link[stats]{qqline}}.
#'   \item \strong{Scale-Location}: \eqn{\sqrt{|\textrm{standardized residuals}|}}
#'     against fitted values with a lowess smooth.
#'   \item \strong{Residuals vs Leverage}: standardized residuals against
#'     leverage (hat values), with Cook's distance contours at
#'     \code{cook.levels}.
#' }
#' As in \code{plot.lm}, the \code{id.n} most extreme observations in each
#' panel are labelled with their observation numbers (placed so that labels do
#' not overlap), observations with zero weight are
#' dropped, and observations with leverage one are omitted from the
#' standardized-residual panels.
#'
#' @param model A fitted \code{lm} object.
#' @param id.n Number of extreme points to label in each panel (default 3).
#' @param cook.levels Cook's distance levels drawn as contours in the
#'   leverage panel (default \code{c(0.5, 1)}).
#'
#' @return An object of class \code{"snazzieR_plot_grid"}: a list whose
#'   \code{plots} element holds the four \code{ggplot} objects (named
#'   \code{residuals.fitted}, \code{qq}, \code{scale.location} and
#'   \code{residuals.leverage}). Printing it draws the 2 x 2 grid; individual
#'   panels can be printed or modified on their own.
#'
#' @seealso \code{\link[stats]{plot.lm}}, \code{\link{marginal.model.plots}}
#' @export
#'
#' @examples
#' model <- lm(mpg ~ wt + hp, data = mtcars)
#' diagnostics.plots(model)
#'
#' # A single panel
#' diagnostics.plots(model)$plots$qq
diagnostics.plots <- function(model, id.n = 3, cook.levels = c(0.5, 1)) {
  if (!inherits(model, "lm") || inherits(model, "glm")) {
    stop("`model` must be a linear model fitted with lm().", call. = FALSE)
  }

  # ---- quantities, computed exactly as stats:::plot.lm does ---------------
  r <- stats::residuals(model)
  yh <- stats::predict(model)
  w <- stats::weights(model)
  labels.id <- as.character(seq_along(r)) # observation numbers
  if (!is.null(w)) {
    keep <- w != 0
    r <- r[keep]
    yh <- yh[keep]
    w <- w[keep]
    labels.id <- labels.id[keep]
  }
  n <- length(r)
  id.n <- as.integer(id.n)
  if (id.n < 0L || id.n > n) stop(sprintf("'id.n' must be in {0,..,%d}", n), call. = FALSE)

  s <- sqrt(stats::deviance(model) / stats::df.residual(model))
  hii <- stats::influence(model, do.coef = FALSE)$hat
  cook <- stats::cooks.distance(model) # already excludes zero-weight cases
  rs <- (if (is.null(w)) r else sqrt(w) * r) / (s * sqrt(1 - hii))
  rs[is.infinite(rs) | hii >= 1] <- NaN

  top <- function(x) if (id.n > 0) order(-abs(x))[seq_len(id.n)] else integer(0)
  show.r <- top(r)
  show.rs <- top(rs)
  show.cook <- if (id.n > 0) order(-cook)[seq_len(id.n)] else integer(0)

  smooth <- function(x, y) {
    ok <- is.finite(x) & is.finite(y)
    if (!any(ok)) return(data.frame(x = numeric(0), y = numeric(0)))
    as.data.frame(stats::lowess(x[ok], y[ok], f = 2 / 3, iter = 3))
  }
  # Place id labels next to their points without covering other labels or
  # data points. Work in panel-relative units (0-1) so spacing is the same
  # whatever the data scale; `xlim`/`ylim` are the panel's data limits.
  labels <- function(x, y, ind, xlim = range(x, na.rm = TRUE), ylim = range(y, na.rm = TRUE)) {
    empty <- data.frame(x = numeric(0), y = numeric(0), label = character(0),
                        hjust = numeric(0), vjust = numeric(0))
    if (!length(ind)) return(empty)
    expand <- function(lim) lim + c(-1, 1) * 0.05 * diff(lim) # ggplot's default expansion
    xl <- expand(xlim)
    yl <- expand(ylim)
    nx <- (x - xl[1L]) / diff(xl)
    ny <- (y - yl[1L]) / diff(yl)
    keep <- is.finite(nx) & is.finite(ny)
    gap <- 0.022 # space between a point and its label
    h <- 0.05 # label height
    r.pt <- 0.012 # point radius
    boxes <- matrix(numeric(0), ncol = 4) # x0, x1, y0, y1 of placed labels
    out <- empty

    for (i in ind) {
      lab <- labels.id[i]
      w <- 0.015 * nchar(lab) + 0.008
      px <- nx[i]
      py <- ny[i]
      # Candidates: plot.lm's side first (left of points in the right half),
      # then the other side, then above and below.
      sides <- if (px > 0.5) c("left", "right") else c("right", "left")
      cand <- lapply(c(sides, "above", "below"), function(side) {
        switch(side,
          left = c(px - gap - w, px - gap, py - h / 2, py + h / 2, px - gap, py, 1, 0.5),
          right = c(px + gap, px + gap + w, py - h / 2, py + h / 2, px + gap, py, 0, 0.5),
          above = c(px - w / 2, px + w / 2, py + gap, py + gap + h, px, py + gap, 0.5, 0),
          below = c(px - w / 2, px + w / 2, py - gap - h, py - gap, px, py - gap, 0.5, 1)
        )
      })
      cost <- vapply(cand, function(b) {
        outside <- b[1] < 0 || b[2] > 1 || b[3] < 0 || b[4] > 1
        hits.lab <- if (nrow(boxes)) {
          sum(b[1] < boxes[, 2] & boxes[, 1] < b[2] & b[3] < boxes[, 4] & boxes[, 3] < b[4])
        } else 0
        others <- keep & seq_along(nx) != i
        hits.pt <- sum(others & nx > b[1] - r.pt & nx < b[2] + r.pt & ny > b[3] - r.pt & ny < b[4] + r.pt)
        100 * outside + 10 * hits.lab + hits.pt
      }, numeric(1))
      best <- cand[[which.min(cost)]] # ties keep plot.lm's preferred side
      boxes <- rbind(boxes, best[1:4])
      out <- rbind(out, data.frame(
        x = xl[1L] + best[5] * diff(xl), y = yl[1L] + best[6] * diff(yl),
        label = lab, hjust = best[7], vjust = best[8]
      ))
    }
    attr(out, "boxes") <- boxes
    out
  }

  point.col <- Deep.Grey
  smooth.col <- Red
  ref.col <- Light.Grey
  cook.col <- Dark.Orange

  base <- function(points, title, xlab, ylab) {
    ggplot2::ggplot(points, ggplot2::aes(x = .data$x, y = .data$y)) +
      ggplot2::geom_point(shape = 1, color = point.col, size = 1.6) +
      ggplot2::labs(title = title, x = xlab, y = ylab) +
      snazzieR.theme() +
      ggplot2::theme(plot.title = ggplot2::element_text(size = 14))
  }
  add_labels <- function(lab) {
    ggplot2::geom_text(
      data = lab,
      ggplot2::aes(x = .data$x, y = .data$y, label = .data$label, hjust = .data$hjust, vjust = .data$vjust),
      size = 3, family = "Times", color = point.col
    )
  }
  add_smooth <- function(sm) {
    ggplot2::geom_path(data = sm, ggplot2::aes(x = .data$x, y = .data$y), color = smooth.col, linewidth = 0.8)
  }

  # ---- 1. Residuals vs Fitted ----------------------------------------------
  d1 <- data.frame(x = yh, y = r)
  ylim1 <- range(r, na.rm = TRUE)
  if (id.n > 0) ylim1 <- grDevices::extendrange(r = ylim1, f = 0.08)
  p1 <- base(d1, "Residuals vs Fitted", "Fitted values", "Residuals") +
    ggplot2::geom_hline(yintercept = 0, linetype = "dotted", color = ref.col) +
    add_smooth(smooth(yh, r)) +
    add_labels(labels(yh, r, show.r, ylim = ylim1)) +
    ggplot2::coord_cartesian(ylim = ylim1)

  # ---- 2. Normal Q-Q of standardized residuals -----------------------------
  ok <- !is.na(rs)
  theo <- rep(NA_real_, n)
  theo[ok][order(rs[ok])] <- stats::qnorm(stats::ppoints(sum(ok)))
  d2 <- data.frame(x = theo, y = rs)
  qy <- stats::quantile(rs[ok], c(0.25, 0.75), names = FALSE, type = 7)
  qx <- stats::qnorm(c(0.25, 0.75))
  slope <- diff(qy) / diff(qx)
  ylim2 <- range(rs, na.rm = TRUE)
  ylim2[2L] <- ylim2[2L] + diff(ylim2) * 0.075
  p2 <- base(d2[ok, ], "Q-Q Residuals", "Theoretical Quantiles", "Standardized residuals") +
    ggplot2::geom_abline(intercept = qy[1L] - slope * qx[1L], slope = slope,
                         linetype = "dotted", color = ref.col, linewidth = 0.7) +
    add_labels(labels(theo, rs, show.rs, ylim = ylim2)) +
    ggplot2::coord_cartesian(ylim = ylim2)

  # ---- 3. Scale-Location ---------------------------------------------------
  sqrtabsr <- sqrt(abs(rs))
  d3 <- data.frame(x = yh, y = sqrtabsr)
  p3 <- base(d3[ok, ], "Scale-Location", "Fitted values",
             expression(sqrt(abs("Standardized residuals")))) +
    add_smooth(smooth(yh, sqrtabsr)) +
    add_labels(labels(yh, sqrtabsr, show.rs, ylim = c(0, max(sqrtabsr, na.rm = TRUE)))) +
    ggplot2::coord_cartesian(ylim = c(0, max(sqrtabsr, na.rm = TRUE)))

  # ---- 4. Residuals vs Leverage with Cook's distance contours ---------------
  xx <- hii
  xx[xx >= 1] <- NA
  ylim4 <- range(rs, na.rm = TRUE)
  if (id.n > 0) ylim4 <- grDevices::extendrange(r = ylim4, f = 0.08)
  xmax.data <- max(xx, na.rm = TRUE)
  xmax.plot <- xmax.data * 1.05 # right edge of the panel (ggplot's default expansion)
  d4 <- data.frame(x = xx, y = rs)
  p4 <- base(d4[!is.na(xx) & ok, ], "Residuals vs Leverage", "Leverage", "Standardized residuals") +
    ggplot2::geom_hline(yintercept = 0, linetype = "dotted", color = ref.col) +
    ggplot2::geom_vline(xintercept = 0, linetype = "dotted", color = ref.col)
  lab4 <- labels(xx, rs, show.cook, xlim = c(0, xmax.data), ylim = ylim4)
  if (length(cook.levels)) {
    p <- model$rank
    r.hat <- range(hii, na.rm = TRUE)
    hh <- seq(min(r.hat[1L], r.hat[2L] / 100), xmax.plot, length.out = 101)
    contours <- do.call(rbind, lapply(cook.levels, function(crit) {
      cl.h <- sqrt(crit * p * (1 - hh) / hh)
      rbind(
        data.frame(x = hh, y = cl.h, group = paste0(crit, "+")),
        data.frame(x = hh, y = -cl.h, group = paste0(crit, "-"))
      )
    }))
    xmax <- min(0.99, xmax.plot)
    aty <- sqrt(cook.levels) * sqrt(p * (1 - xmax) / xmax)
    cook.labs <- data.frame(x = xmax.plot, y = c(-rev(aty), aty),
                            label = paste(c(rev(cook.levels), cook.levels)))
    cook.labs <- cook.labs[cook.labs$y >= ylim4[1L] & cook.labs$y <= ylim4[2L], ]
    p4 <- p4 +
      ggplot2::geom_line(
        data = contours, ggplot2::aes(x = .data$x, y = .data$y, group = .data$group, linetype = "Cook's D."),
        color = cook.col, linewidth = 0.6
      ) +
      # The panel title doubles as the legend title, so the Cook's D.
      # key sits to the right of "Residuals vs Leverage" instead of in the plot.
      ggplot2::scale_linetype_manual(name = "Residuals vs Leverage", values = c("Cook's D." = "dashed")) +
      ggplot2::labs(title = NULL) +
      ggplot2::geom_text(data = cook.labs, ggplot2::aes(x = .data$x, y = .data$y, label = .data$label),
                         hjust = 1.2, size = 3, family = "Times", color = cook.col) +
      ggplot2::theme(
        # one line, centered over the panel like the other panel titles
        legend.position = "top",
        legend.location = "panel",
        legend.justification = "center",
        legend.direction = "horizontal",
        legend.title.position = "left",
        legend.title = ggplot2::element_text(
          face = "bold", color = "#83B02F", size = 14, family = "Times",
          margin = ggplot2::margin(r = 6, unit = "pt")
        ),
        legend.margin = ggplot2::margin(0, 0, 0, 0),
        legend.box.spacing = ggplot2::unit(2, "pt"),
        legend.key = ggplot2::element_blank(),
        legend.key.width = ggplot2::unit(0.65, "cm"),
        legend.key.spacing.x = ggplot2::unit(2, "pt"),
        legend.text = ggplot2::element_text(color = cook.col, family = "Times", size = 9,
                                            margin = ggplot2::margin(l = 2, unit = "pt"))
      )
  }
  p4 <- p4 +
    add_labels(lab4) +
    ggplot2::coord_cartesian(xlim = c(0, xmax.data), ylim = ylim4)

  structure(
    list(
      plots = list(residuals.fitted = p1, qq = p2, scale.location = p3, residuals.leverage = p4),
      nrow = 2L, ncol = 2L
    ),
    class = "snazzieR_plot_grid"
  )
}

#' @rdname diagnostics.plots
#' @param x A \code{"snazzieR_plot_grid"} object.
#' @param ... Unused.
#' @export
print.snazzieR_plot_grid <- function(x, ...) {
  grid::grid.newpage()
  cell.width <- grid::convertWidth(grid::unit(1 / x$ncol, "npc"), "in", valueOnly = TRUE)
  grobs <- lapply(x$plots, fit_title_legend, width = cell.width)

  # Line up the panels within each row: pad the top (and bottom) of each plot
  # so the plotting regions start and end at the same height, even when one
  # plot has a legend in its title row or longer axis labels.
  extent <- function(g, above) {
    panel.rows <- g$layout[grepl("^panel", g$layout$name), c("t", "b")]
    rows <- if (above) seq_len(min(panel.rows$t) - 1L) else seq.int(max(panel.rows$b) + 1L, length(g$heights))
    grid::convertHeight(sum(g$heights[rows]), "in", valueOnly = TRUE)
  }
  top <- vapply(grobs, extent, numeric(1), above = TRUE)
  bottom <- vapply(grobs, extent, numeric(1), above = FALSE)
  row <- (seq_along(grobs) - 1L) %/% x$ncol
  for (i in seq_along(grobs)) {
    same <- row == row[i]
    nh <- length(grobs[[i]]$heights)
    grobs[[i]]$heights[1L] <- grobs[[i]]$heights[1L] + grid::unit(max(top[same]) - top[i], "in")
    grobs[[i]]$heights[nh] <- grobs[[i]]$heights[nh] + grid::unit(max(bottom[same]) - bottom[i], "in")
  }

  grid::pushViewport(grid::viewport(layout = grid::grid.layout(x$nrow, x$ncol)))
  for (i in seq_along(grobs)) {
    grid::pushViewport(grid::viewport(
      layout.pos.row = row[i] + 1L,
      layout.pos.col = (i - 1L) %% x$ncol + 1L
    ))
    grid::grid.draw(grobs[[i]])
    grid::popViewport()
  }
  grid::popViewport()
  invisible(x)
}

#' @importFrom ggplot2 .data
NULL

# Build a plot's grob, shrinking a title-row legend (e.g. "Residuals vs
# Leverage -- Cook's D.") just enough to fit on one line above the panel
# when the plot is drawn at width `width` (inches).
fit_title_legend <- function(plot, width) {
  g <- ggplot2::ggplotGrob(plot)
  idx <- which(g$layout$name == "guide-box-top")
  if (!length(idx)) return(g)
  title.size <- plot$theme$legend.title$size
  text.size <- plot$theme$legend.text$size
  if (is.null(title.size) || is.null(text.size)) return(g)
  for (attempt in 1:3) {
    box <- g$grobs[[idx]]
    need <- grid::convertWidth(sum(box$widths), "in", valueOnly = TRUE)
    panel.cols <- unique(unlist(g$layout[grepl("^panel", g$layout$name), c("l", "r")]))
    fixed <- grid::convertWidth(sum(g$widths[-panel.cols]), "in", valueOnly = TRUE)
    have <- width - fixed
    if (need <= have) break
    f <- max(0.5, have / need * 0.97)
    title.size <- title.size * f
    text.size <- text.size * f
    plot <- plot + ggplot2::theme(
      legend.title = ggplot2::element_text(size = title.size),
      legend.text = ggplot2::element_text(size = text.size),
      legend.key.width = ggplot2::unit(0.65 * f, "cm")
    )
    g <- ggplot2::ggplotGrob(plot)
    idx <- which(g$layout$name == "guide-box-top")
  }
  g
}
