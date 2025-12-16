# Optimized R settings for faster package development and checking

# Set number of cores for parallel processing
options(mc.cores = parallel::detectCores())

# Optimize memory usage
options(max.print = 1000)
options(width = 120)

# Enable byte compilation for faster execution
options(bytecode = TRUE)

# Optimize BLAS/LAPACK if available
if (requireNamespace("RhpcBLASctl", quietly = TRUE)) {
    tryCatch(
        {
            RhpcBLASctl::blas_set_num_threads(parallel::detectCores())
            RhpcBLASctl::omp_set_num_threads(parallel::detectCores())
        },
        error = function(e) {
            # Silently fail if not available
        }
    )
}

# Set faster random number generator
RNGkind("Mersenne-Twister")

# Optimize for package development
if (interactive()) {
    # Load devtools if available
    if (requireNamespace("devtools", quietly = TRUE)) {
        devtools::load_all(".")
    }

    # Set faster test options
    Sys.setenv("R_TESTS" = "")
    Sys.setenv("R_CHECK_TESTS_NLINES" = "0")
    Sys.setenv("R_CHECK_CRAN_INCOMING" = "FALSE")
    Sys.setenv("R_CHECK_CRAN_INCOMING_REMOTE" = "FALSE")
}

# Optimize for CRAN checks
if (!interactive()) {
    # Disable vignettes during checks for speed
    Sys.setenv("R_CHECK_DONTTEST_EXAMPLES" = "TRUE")
    Sys.setenv("R_CHECK_DONTTEST_INSTALL" = "TRUE")
}
