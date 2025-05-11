#' Display a Color Reference Palette
#'
#' This function generates a plot displaying a predefined color palette with
#' color codes for easy reference. The palette includes shades of Red, Orange,
#' Yellow, Green, Blue, Purple, and Grey.
#'
#' \if{html}{\figure{color.ref.png}{options: width=45 alt="Light Grey color swatch"}}
#' \if{latex}{\figure{color.ref.png}{options: width=4.5in}}
#'
#' @return A plot displaying the color palette.
#' @importFrom graphics par rect text axis
#' @export
#'
#' @examples
#' color.ref()
color.ref <- function() {
  # Define color palette
  colors <- matrix(c(
    "#590d21", "#9f193d", "#C31E4A", "#e66084", "#f1a7bb",
    "#6F4B0B", "#A77011", "#E99F1F", "#F0BF6A", "#F4CF90",
    "#9d7f06", "#CEA708", "#e8d206", "#ffe373", "#FFF8DC",
    "#304011", "#54711E", "#83B02F", "#ABD45E", "#C4E18E",
    "#002429", "#004852", "#008C9E", "#1FE5FF", "#85F1FF",
    "#271041", "#4E2183", "#743496", "#A06CDA", "#CAADEB",
    "#151315", "#403A3F", "#6F646C", "#9E949B", "#CFC9CD"
  ), nrow = 7, byrow = TRUE)

  # Labels for rows and columns
  row_labels <- c("Red", "Orange", "Yellow", "Green", "Blue", "Purple", "Grey")
  col_labels <- c("Deep", "Dark", "Regular", "Light", "Pale")

  # Adjust margins & move axis labels closer
  par(mar = c(3, 3, 0, 0), mgp = c(1.5, 0.4, 0))  # Reduced mgp[2] (axis label spacing)

  # Plot setup
  plot(1, 1, type = "n", xlim = c(0.5, 5.5), ylim = c(0.5, 7.5),
       xaxt = "n", yaxt = "n", xlab = "", ylab = "", bty = "n")

  # Add color squares
  for (i in 1:7) {
    for (j in 1:5) {
      rect(j - 0.5, 8.5 - i, j + 0.5, 7.5 - i, col = colors[i, j], border = NA)

      # Use off-white text for first two columns, black otherwise
      text_color <- ifelse(j <= 2, "#FFF8DC", "black")
      text(j, 8 - i, colors[i, j], cex = 0.7, col = text_color)
    }
  }

  # Add labels closer to the plot
  axis(1, at = 1:5, labels = col_labels, tick = FALSE, cex.axis = 0.8, font = 2)
  axis(2, at = 1:7, labels = rev(row_labels), tick = FALSE, las = 1, cex.axis = 0.8, font = 2)
}
