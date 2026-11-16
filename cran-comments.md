## Resubmission

The first submission of 0.1.3 failed the incoming pre-tests with one test
failure on Windows and Debian:

    Failure ('test-tables.R:39:3'): title is the caption and the equation
    sits on its own line

knitr 1.52 escapes LaTeX special characters in table captions, so the bold
title was printed as literal source. The package now inserts the caption
after the table is built, which gives the same output under knitr 1.51 and
1.52. A new test covers every table function.

## Submission

This is an update of snazzieR from 0.1.2 to 0.1.3.

* Four new functions for regression diagnostics: `diagnostics.plots()`,
  `marginal.model.plots()`, `unusual.points.table()` and `VIF.table()`.
* LaTeX tables now print an HTML or plain-text preview in interactive
  sessions. Knitted output still goes through knitr.
* The `caption` argument of three table functions is renamed `title`. The old
  name is kept as an alias, so existing code runs unchanged.
* dplyr is no longer imported.
* Bug fixes, listed in NEWS.md.

## Test environments

* Local: Arch Linux, R 4.6.2, `R CMD check --as-cran` on the built tarball,
  once with every dependency at its current CRAN version (knitr 1.52,
  kableExtra 1.4.1, ggplot2 4.0.4) and once with knitr 1.51

## R CMD check results

0 errors | 0 warnings | 1 note

The note is specific to the local machine:

    checking HTML version of manual ... NOTE
    Skipping checking math rendering: package 'V8' unavailable

## Reverse dependencies

snazzieR has no reverse dependencies on CRAN.
