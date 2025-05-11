# Load devtools to load the local development version
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}
devtools::load_all()

# Define response matrix Y
y.wine <- data.frame(
  Hedonic = c(14, 10, 8, 2, 6),
  Goes_with_meat = c(7, 7, 5, 4, 2),
  Goes_with_dessert = c(8, 6, 5, 7, 4)
)
rownames(y.wine) <- paste0("Wine", 1:5)

# Define predictor matrix X
x.wine <- data.frame(
  Price = c(7, 4, 10, 16, 13),
  Sugar = c(7, 3, 5, 7, 3),
  Alcohol = c(13, 14, 12, 11, 10),
  Acidity = c(7, 7, 5, 3, 3)
)
rownames(x.wine) <- paste0("Wine", 1:5)

# Convert to matrices
x.mat.wine <- as.matrix(x.wine)
y.mat.wine <- as.matrix(y.wine)

# Run PLS regression using default method (SVD)
wine.model <- pls.regression(x.mat.wine, y.mat.wine, n.components = 2)

# Format and print to console
format.pls(wine.model, latex = FALSE, include.scores = TRUE)


