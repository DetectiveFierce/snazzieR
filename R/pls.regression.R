#' @title Partial Least Squares (PLS) Regression Interface
#'
#' @description
#' Performs Partial Least Squares (PLS) regression using either the NIPALS or SVD algorithm for component extraction.
#' This is the main user-facing function for computing PLS models. Internally, it delegates to either \code{NIPALS.pls()} or \code{SVD.pls()}.
#'
#' @param x A numeric matrix or data frame of predictor variables (X), with dimensions n × p.
#' @param y A numeric matrix or data frame of response variables (Y), with dimensions n × q.
#' @param n.components Integer specifying the number of latent components (H) to extract. If NULL, defaults to the rank of \code{x}.
#' @param calc.method Character string indicating the algorithm to use. Must be either \code{"SVD"} (default) or \code{"NIPALS"}.
#'
#' @details
#' This function provides a unified interface for Partial Least Squares regression. Based on the value of \code{calc.method},
#' it computes latent variables using either:
#' \itemize{
#'   \item \code{"SVD"} — A direct method using the singular value decomposition of the cross-covariance matrix (\eqn{X^\top Y}).
#'   \item \code{"NIPALS"} — An iterative method that alternately estimates predictor and response scores until convergence.
#' }
#' The outputs from both methods include scores, weights, loadings, regression coefficients, and explained variance.
#'
#' @return A list (from either \code{SVD.pls()} or \code{NIPALS.pls()}) containing:
#' \describe{
#'   \item{model.type}{Character string ("PLS Regression").}
#'   \item{T, U}{Score matrices for X and Y.}
#'   \item{W, C}{Weight matrices for X and Y.}
#'   \item{P_loadings, Q_loadings}{Loading matrices.}
#'   \item{B_vector}{Component-wise regression weights.}
#'   \item{coefficients}{Final regression coefficient matrix (rescaled).}
#'   \item{intercept}{Intercept vector (typically zero due to centering).}
#'   \item{X_explained, Y_explained}{Variance explained by each component.}
#'   \item{X_cum_explained, Y_cum_explained}{Cumulative variance explained.}
#' }
#'
#' @seealso
#' \code{\link{SVD.pls}}, \code{\link{NIPALS.pls}}
#'
#' @references
#' Abdi, H., & Williams, L. J. (2013). Partial least squares methods: Partial least squares correlation and partial least square regression. \emph{Methods in Molecular Biology (Clifton, N.J.)}, 930, 549–579. \doi{10.1007/978-1-62703-059-5_23}
#'
#' de Jong, S. (1993). SIMPLS: An alternative approach to partial least squares regression. \emph{Chemometrics and Intelligent Laboratory Systems}, 18(3), 251–263. \doi{10.1016/0169-7439(93)85002-X}
#'
#' @examples
#' \dontrun{
#' X <- matrix(rnorm(100 * 10), 100, 10)
#' Y <- matrix(rnorm(100 * 2), 100, 2)
#'
#' # Using SVD (default)
#' model1 <- pls.regression(X, Y, n.components = 3)
#'
#' # Using NIPALS
#' model2 <- pls.regression(X, Y, n.components = 3, calc.method = "NIPALS")
#' }
#'
#' @export


pls.regression <- function(x, y, n.components = NULL, calc.method = c("SVD", "NIPALS")) {
  calc.method <- match.arg(calc.method)

  if (calc.method == "SVD") {
    return(SVD.pls(x, y, n.components = n.components))
  } else if (calc.method == "NIPALS") {
    return(NIPALS.pls(x, y, n.components = n.components))
  }
}



