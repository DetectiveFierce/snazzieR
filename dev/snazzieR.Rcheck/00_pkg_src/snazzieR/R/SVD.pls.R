#' @title Partial Least Squares Regression via SVD (Internal)
#'
#' @description
#' This function is called internally by \code{\link{pls.regression}} and is not intended
#' to be used directly. Use \code{pls.regression(..., calc.method = "SVD")} instead.
#'
#' Performs Partial Least Squares (PLS) regression using the Singular Value Decomposition (SVD)
#' of the cross-covariance matrix. This method estimates the latent components by identifying directions
#' in the predictor and response spaces that maximize their covariance, using the leading singular vectors
#' of the matrix \eqn{R = X^\top Y}.
#'
#' @param x A numeric matrix or data frame of predictors (X). Should have dimensions n × p.
#' @param y A numeric matrix or data frame of response variables (Y). Should have dimensions n × q.
#' @param n.components Integer specifying the number of PLS components to extract. If NULL, defaults to \code{qr(x)$rank}.
#'
#' @details
#' The algorithm begins by z-scoring both \code{x} and \code{y} (centering and scaling to unit variance).
#' The initial residual matrices are set to the scaled values: \code{E = X_scaled}, \code{F = Y_scaled}.
#'
#' For each component h = 1, ..., H:
#' \enumerate{
#'   \item Compute the cross-covariance matrix \eqn{R = E^\top F}.
#'   \item Perform SVD on \eqn{R = U D V^\top}.
#'   \item Extract the first singular vectors: \eqn{w = U[,1]}, \eqn{q = V[,1]}.
#'   \item Compute scores: \eqn{t = E w} (normalized), \eqn{u = F q}.
#'   \item Compute loadings: \eqn{p = E^\top t}, regression scalar \eqn{b = t^\top u}.
#'   \item Deflate residuals: \eqn{E \gets E - t p^\top}, \eqn{F \gets F - b t q^\top}.
#' }
#'
#' After all components are extracted, a post-processing step removes components with zero regression
#' weight. The scaled regression coefficients are computed using the Moore–Penrose pseudoinverse of the
#' loading matrix \eqn{P}, and then rescaled to the original variable units.
#'
#' @return A list containing:
#' \describe{
#'   \item{model.type}{Character string indicating the model type ("PLS Regression").}
#'   \item{T}{Matrix of predictor scores (n × H).}
#'   \item{U}{Matrix of response scores (n × H).}
#'   \item{W}{Matrix of predictor weights (p × H).}
#'   \item{C}{Matrix of normalized response weights (q × H).}
#'   \item{P_loadings}{Matrix of predictor loadings (p × H).}
#'   \item{Q_loadings}{Matrix of response loadings (q × H).}
#'   \item{B_vector}{Vector of scalar regression weights (length H).}
#'   \item{coefficients}{Matrix of final regression coefficients in the original scale (p × q).}
#'   \item{intercept}{Vector of intercepts (length q). All zeros due to centering.}
#'   \item{X_explained}{Percent of total X variance explained by each component.}
#'   \item{Y_explained}{Percent of total Y variance explained by each component.}
#'   \item{X_cum_explained}{Cumulative X variance explained.}
#'   \item{Y_cum_explained}{Cumulative Y variance explained.}
#' }
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
#' model <- pls.regression(X, Y, n.components = 3, calc.method = "SVD")
#' model$coefficients
#' }
#'
#' @keywords internal
#' @export




SVD.pls <- function(x, y, n.components = NULL) {
  # Step 1: Center and scale X and Y
  X <- scale(x, center = TRUE, scale = TRUE)
  Y <- scale(y, center = TRUE, scale = TRUE)

  x.mean <- attr(X, "scaled:center")
  x.sd <- attr(X, "scaled:scale")
  y.mean <- attr(Y, "scaled:center")
  y.sd <- attr(Y, "scaled:scale")

  n <- nrow(X)
  p <- ncol(X)
  q <- ncol(Y)

  # Determine number of components
  rank_X <- qr(X)$rank
  if (is.null(n.components)) {
    n.components <- rank_X
  } else {
    n.components <- min(n.components, rank_X)
  }

  # Preallocate matrices
  T <- matrix(0, n, n.components)  # X scores
  U <- matrix(0, n, n.components)  # Y scores
  P_loadings <- matrix(0, p, n.components)  # X loadings
  W <- matrix(0, p, n.components)  # X weights
  Q_loadings <- matrix(0, q, n.components)  # Y loadings (reference)
  B_vector <- numeric(n.components)

  # Initial total sum of squares
  SSX_total <- sum(X^2)
  SSY_total <- sum(Y^2)

  X_explained <- numeric(n.components)
  Y_explained <- numeric(n.components)

  # Store initial X and Y
  E <- X
  F <- Y

  for (h in seq_len(n.components)) {
    # Step 1: Cross-covariance matrix
    R <- t(E) %*% F

    # Step 2: SVD of R
    svd_R <- svd(R)
    w <- svd_R$u[, 1, drop = FALSE]
    c <- svd_R$v[, 1, drop = FALSE]

    # Step 3: Scores
    t <- E %*% w
    t <- t / sqrt(sum(t^2))  # normalize t
    u <- F %*% c

    # Step 4: Loadings
    p <- t(E) %*% t

    # Step 5: Regression scalar b
    b <- drop(t(t) %*% u)

    # Step 6: Deflation
    E <- E - t %*% t(p)
    F <- F - b * t %*% t(c)

    # Store results
    T[, h] <- t
    U[, h] <- u
    P_loadings[, h] <- p
    W[, h] <- w
    Q_loadings[, h] <- c
    B_vector[h] <- b

    # Explained variance
    X_explained[h] <- sum(p^2) / SSX_total * 100
    Y_explained[h] <- (b^2) / SSY_total * 100
  }

  # Cumulative variance explained
  X_cum_explained <- cumsum(X_explained)
  Y_cum_explained <- cumsum(Y_explained)

  # Clean up effective components
  effective_components <- sum(B_vector != 0)

  P_loadings <- P_loadings[, seq_len(effective_components), drop = FALSE]
  Q_loadings <- Q_loadings[, seq_len(effective_components), drop = FALSE]
  W <- W[, seq_len(effective_components), drop = FALSE]
  T <- T[, seq_len(effective_components), drop = FALSE]
  U <- U[, seq_len(effective_components), drop = FALSE]
  B_vector <- B_vector[seq_len(effective_components)]
  X_explained <- X_explained[seq_len(effective_components)]
  Y_explained <- Y_explained[seq_len(effective_components)]
  X_cum_explained <- X_cum_explained[seq_len(effective_components)]
  Y_cum_explained <- Y_cum_explained[seq_len(effective_components)]

  # Normalize C (Y weights)
  C <- apply(Q_loadings, 2, function(c) c / sqrt(sum(c^2)))

  # Pseudo-inverse of P_loadings
  svd_P <- svd(P_loadings)
  d_inv <- ifelse(svd_P$d > .Machine$double.eps, 1 / svd_P$d, 0)
  P_pinv <- t(svd_P$v %*% diag(d_inv) %*% t(svd_P$u))
  P_pinv <- P_pinv[, seq_len(effective_components), drop = FALSE]

  # Final scaled coefficients
  B_scaled <- P_pinv %*% diag(B_vector) %*% t(Q_loadings)

  # Rescale to original units
  B_original <- sweep(B_scaled, 2, y.sd, "*")
  B_original <- sweep(B_original, 1, x.sd, "/")

  rownames(B_original) <- colnames(x)
  colnames(B_original) <- colnames(y)

  intercept <- rep(0, length(y.mean))
  names(intercept) <- colnames(y)

  list(
    model.type = "PLS Regression",
    T = T,  # X scores
    U = U,  # Y scores
    W = W,  # X weights
    C = C,  # Y weights (normalized)
    P_loadings = P_loadings,  # X loadings (reference)
    Q_loadings = Q_loadings,  # Y loadings (reference)
    B_vector = B_vector,
    coefficients = B_original,
    intercept = intercept,
    X_explained = X_explained,
    Y_explained = Y_explained,
    X_cum_explained = X_cum_explained,
    Y_cum_explained = Y_cum_explained
  )
}
