#' A Custom ggplot2 Theme for Publication-Ready Plots
#'
#' This theme provides a clean, polished look for ggplot2 plots, with a focus on
#' readability and aesthetics. It includes a custom color palette and formatting
#' for titles, axes, and legends.
#'
#' @return A ggplot2 theme object.
#' @export
#'
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
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
