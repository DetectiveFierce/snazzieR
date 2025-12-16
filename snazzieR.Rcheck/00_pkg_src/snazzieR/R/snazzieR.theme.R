#' A Custom ggplot2 Theme for Publication-Ready Plots
#'
#' This theme provides a clean, polished look for ggplot2 plots, with a focus on
#' readability and aesthetics. It includes a custom color palette and formatting
#' for titles, axes, and legends.
#'
#' @return A ggplot2 theme object.
#' @export
#' @seealso \code{\link{color.list}}, \code{\link{color.ref}}
#' @examples
#' library(ggplot2)
#' set.seed(123)
#' chains.df <- data.frame(
#'   Iteration = 1:500,
#'   alpha.1 = cumsum(rnorm(500, mean = 0.01, sd = 0.2)) + rnorm(1, 5, 0.2),
#'   alpha.2 = cumsum(rnorm(500, mean = 0.005, sd = 0.2)) + rnorm(1, 5, 0.2),
#'   alpha.3 = cumsum(rnorm(500, mean = 0.000, sd = 0.2)) + rnorm(1, 5, 0.2),
#'   alpha.4 = cumsum(rnorm(500, mean = -0.005, sd = 0.2)) + rnorm(1, 5, 0.2),
#'   alpha.5 = cumsum(rnorm(500, mean = -0.01, sd = 0.2)) + rnorm(1, 5, 0.2)
#' )
#' chain.colors <- c("Chain 1" = Red, "Chain 2" = Orange, "Chain 3" = Yellow,
#'                   "Chain 4" = Green, "Chain 5" = Blue)
#' ggplot(chains.df, aes(x = Iteration)) +
#'   geom_line(aes(y = alpha.1, color = "Chain 1"), linewidth = 1.2) +
#'   geom_line(aes(y = alpha.2, color = "Chain 2"), linewidth = 1.2) +
#'   geom_line(aes(y = alpha.3, color = "Chain 3"), linewidth = 1.2) +
#'   geom_line(aes(y = alpha.4, color = "Chain 4"), linewidth = 1.2) +
#'   geom_line(aes(y = alpha.5, color = "Chain 5"), linewidth = 1.2) +
#'   labs(x = "Iteration", y = expression(alpha),
#'        title = expression("Traceplot for " ~ alpha)) +
#'   scale_color_manual(values = chain.colors, name = "Chains") +
#'   snazzieR.theme()

snazzieR.theme <- function() {
  ggplot2::theme_minimal(base_size = 14, base_family = "Times") +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = "cornsilk1", color = NA),
      panel.grid = ggplot2::element_blank(),
      panel.border = ggplot2::element_rect(color = "black", fill = NA, linewidth = 0),
      axis.line = ggplot2::element_line(color = "black", linewidth = 0.5),
      axis.ticks = ggplot2::element_line(color = "black", linewidth = 0.5),
      axis.ticks.length = ggplot2::unit(0.25, "cm"),
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold", color = "#83B02F", size = 18, family = "Times"),
      plot.subtitle = ggplot2::element_text(hjust = 0.5, color = "#83B02F", size = 14, family = "Times"),
      axis.title = ggplot2::element_text(color = "black", size = 12, face = "bold", family = "Times"),
      axis.text = ggplot2::element_text(color = "black", size = 12, family = "Times"),
      legend.key.height = ggplot2::unit(0.6, "cm")
    )
}
