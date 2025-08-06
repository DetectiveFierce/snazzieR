#' @title Partial Least Squares Regression via NIPALS (Internal)
#'
#' @description
#' This function is called internally by \code{\link{pls.regression}} and is not intended
#' to be used directly. Use \code{pls.regression(..., calc.method = "NIPALS")} instead.
#'
#' Performs Partial Least Squares (PLS) regression using the NIPALS (Nonlinear Iterative Partial Least Squares) algorithm.
#' This method estimates the latent components (scores, loadings, weights) by iteratively updating the X and Y score directions
#' until convergence. It is suitable for cases where the number of predictors is large or predictors are highly collinear.
#'
#' @param x A numeric matrix or data frame of predictors (X). Should have dimensions n × p.
#' @param y A numeric matrix or data frame of response variables (Y). Should have dimensions n × q.
#' @param n.components Integer specifying the number of PLS components to extract. If NULL, it defaults to \code{qr(x)$rank}.
#'
#' @details
#' The algorithm standardizes both \code{x} and \code{y} using z-score normalization. It then performs the following for each
#' of the \code{n.components} latent variables:
#' \enumerate{
#'   \item Initializes a random response score vector \eqn{u}.
#'   \item Iteratively:
#'     \itemize{
#'       \item Updates the X weight vector \eqn{w = E^\top u}, normalized.
#'       \item Computes the X score \eqn{t = E w}, normalized.
#'       \item Updates the Y loading \eqn{q = F^\top t}, normalized.
#'       \item Updates the response score \eqn{u = F q}.
#'       \item Repeats until \eqn{t} converges below a tolerance threshold.
#'     }
#'   \item Computes scalar regression coefficient \eqn{b = t^\top u}.
#'   \item Deflates residual matrices \eqn{E} and \eqn{F} to remove current component contribution.
#' }
#'
#' After component extraction, the final regression coefficient matrix \eqn{B_{original}} is computed and rescaled to the original
#' data units. Explained variance is also computed component-wise and cumulatively.
#'
#' @return A list with the following elements:
#' \describe{
#'   \item{model.type}{Character string indicating the model type ("PLS Regression").}
#'   \item{T}{Matrix of X scores (n × H).}
#'   \item{U}{Matrix of Y scores (n × H).}
#'   \item{W}{Matrix of X weights (p × H).}
#'   \item{C}{Matrix of normalized Y weights (q × H).}
#'   \item{P_loadings}{Matrix of X loadings (p × H).}
#'   \item{Q_loadings}{Matrix of Y loadings (q × H).}
#'   \item{B_vector}{Vector of regression scalars (length H), one for each component.}
#'   \item{coefficients}{Matrix of regression coefficients in original data scale (p × q).}
#'   \item{intercept}{Vector of intercepts (length q). Always zero here due to centering.}
#'   \item{X_explained}{Percent of total X variance explained by each component.}
#'   \item{Y_explained}{Percent of total Y variance explained by each component.}
#'   \item{X_cum_explained}{Cumulative X variance explained.}
#'   \item{Y_cum_explained}{Cumulative Y variance explained.}
#' }
#'
#' @references
#' Wold, H., & Lyttkens, E. (1969). Nonlinear iterative partial least squares (NIPALS) estimation procedures. \emph{Bulletin of the International Statistical Institute}, 43, 29–51.
#'
#' @importFrom stats rnorm
#' @examples
#' \dontrun{
#' X <- matrix(rnorm(100 * 10), 100, 10)
#' Y <- matrix(rnorm(100 * 2), 100, 2)
#' model <- pls.regression(X, Y, n.components = 3, calc.method = "NIPALS")
#' model$coefficients
#' }
#'
#' @keywords internal
#' @export



NIPALS.pls <- function(x, y, n.components = NULL) {
  # Setup
  rank <- qr(x)$rank
  if (is.null(n.components)) {
    n.components <- rank
  } else {
    n.components <- min(n.components, rank)
  }

  tol <- 1e-12
  max.iter <- 1e6

  original.x.names <- colnames(x)
  original.y.names <- colnames(y)

  # Standardize data (Z-score: center and scale)
  X_scaled <- scale(x, center = TRUE, scale = TRUE)
  Y_scaled <- scale(y, center = TRUE, scale = TRUE)

  x.mean <- attr(X_scaled, "scaled:center")
  x.sd <- attr(X_scaled, "scaled:scale")
  y.mean <- attr(Y_scaled, "scaled:center")
  y.sd <- attr(Y_scaled, "scaled:scale")

  E <- X_scaled
  F <- Y_scaled

  n <- nrow(E)
  p <- ncol(E)
  q <- ncol(F)

  # Preallocate matrices
  T <- matrix(0, n, n.components) # X scores
  U <- matrix(0, n, n.components) # Y scores
  P_loadings <- matrix(0, p, n.components) # X loadings
  W <- matrix(0, p, n.components) # X weights
  Q_loadings <- matrix(0, q, n.components) # Y loadings
  B_vector <- numeric(n.components)

  # Initial sum of squares for explained variance tracking
  SSX_total <- sum(E^2)
  SSY_total <- sum(F^2)

  X_explained <- numeric(n.components)
  Y_explained <- numeric(n.components)

  for (h in seq_len(n.components)) {
    set.seed(h) # For reproducibility
    u <- rnorm(n)
    t.old <- rep(0, n)

    for (iter in seq_len(max.iter)) {
      # Step 1: w ∝ E' u
      w <- crossprod(E, u)
      w <- w / sqrt(sum(w^2))

      # Step 2: t ∝ E w
      t <- E %*% w
      t <- t / sqrt(sum(t^2))

      # Step 3: c ∝ F' t
      c <- crossprod(F, t)
      c <- c / sqrt(sum(c^2))

      # Step 4: u = F c
      u.new <- F %*% c

      # Check convergence on t
      if (sum((t - t.old)^2) / sum(t^2) < tol) {
        break
      }

      t.old <- t
      u <- u.new

      if (iter == max.iter) {
        warning(sprintf("Component %d did not converge after %d iterations", h, max.iter))
      }
    }

    # Step 5: b = t' u
    b <- drop(crossprod(t, u))

    # Step 6: p = E' t
    p <- drop(crossprod(E, t))

    # Step 7: deflation
    E <- E - t %*% t(p)
    F <- F - b * t %*% t(c)

    # Store results
    T[, h] <- t # X scores
    U[, h] <- u # Y scores
    P_loadings[, h] <- p
    W[, h] <- w
    Q_loadings[, h] <- c
    B_vector[h] <- b

    # Variance explained
    X_explained[h] <- sum(p^2) / SSX_total * 100
    Y_explained[h] <- b^2 / SSY_total * 100
  }

  # Cumulative explained variance
  X_cum_explained <- cumsum(X_explained)
  Y_cum_explained <- cumsum(Y_explained)

  # Final coefficients
  B_scaled <- W %*% solve(t(P_loadings) %*% W) %*% diag(B_vector) %*% t(Q_loadings)

  # Rescale coefficients to original data scale
  B_original <- sweep(B_scaled, 2, y.sd, "*")
  B_original <- sweep(B_original, 1, x.sd, "/")

  # Normalize C (Y weights) properly
  C <- apply(Q_loadings, 2, function(c) c / sqrt(sum(c^2)))

  # Set names for output clarity
  rownames(B_original) <- original.x.names
  colnames(B_original) <- original.y.names

  # Intercept (currently zero because of centering)
  intercept <- rep(0, length(y.mean))
  names(intercept) <- original.y.names

  list(
    model.type = "PLS Regression",
    T = T, # X scores
    U = U, # Y scores
    W = W, # X weights
    C = C, # Y weights (normalized)
    P_loadings = P_loadings, # X loadings (reference)
    Q_loadings = Q_loadings, # Y loadings (reference)
    B_vector = B_vector,
    coefficients = B_original,
    intercept = intercept,
    X_explained = X_explained,
    Y_explained = Y_explained,
    X_cum_explained = X_cum_explained,
    Y_cum_explained = Y_cum_explained
  )
}
