built <- function(p, i) ggplot2::ggplot_build(p)$data[[i]]

test_that("diagnostics.plots reproduces plot.lm's quantities", {
  m <- lm(mpg ~ wt + hp, data = mtcars)
  g <- diagnostics.plots(m)
  expect_s3_class(g, "snazzieR_plot_grid")
  expect_named(g$plots, c("residuals.fitted", "qq", "scale.location", "residuals.leverage"))

  # Residuals vs Fitted: lowess smooth and the three largest |residuals|
  lw <- lowess(fitted(m), residuals(m), f = 2 / 3, iter = 3)
  expect_equal(built(g$plots$residuals.fitted, 3)$y, lw$y)
  r <- residuals(m)
  expect_setequal(built(g$plots$residuals.fitted, 4)$label, as.character(order(-abs(r))[1:3]))

  # Q-Q: same points as qqnorm() on standardized residuals
  qq <- qqnorm(rstandard(m), plot.it = FALSE)
  pts <- built(g$plots$qq, 1)
  expect_equal(sort(pts$x), sort(qq$x))
  expect_equal(sort(pts$y), sort(unname(qq$y)))

  # Residuals vs Leverage: labels are the largest Cook's distances
  ck <- cooks.distance(m)
  lev <- ggplot2::ggplot_build(g$plots$residuals.leverage)$data
  expect_setequal(lev[[length(lev)]]$label, as.character(order(-ck)[1:3]))

  pdf(NULL)
  on.exit(dev.off())
  expect_invisible(print(g))
})

test_that("diagnostics.plots handles zero weights like plot.lm", {
  m <- lm(mpg ~ wt + hp, data = mtcars, weights = rep(c(1, 2, 0, 1), 8))
  g <- diagnostics.plots(m)
  expect_equal(nrow(built(g$plots$qq, 1)), sum(weights(m) != 0))
  ck <- cooks.distance(m) # zero-weight cases are dropped, numbers are not
  lev <- ggplot2::ggplot_build(g$plots$residuals.leverage)$data
  expect_setequal(lev[[length(lev)]]$label, as.character(which(weights(m) != 0)[order(-ck)[1:3]]))
})

test_that("marginal.model.plots picks car's panels and smooths", {
  m <- lm(mpg ~ poly(disp, 2) + factor(cyl) + wt + wt:hp, data = mtcars)
  expect_warning(p <- marginal.model.plots(m), "replaced by a fitted linear combination")
  b <- ggplot2::ggplot_build(p)
  expect_equal(as.character(b$layout$layout$panel), c("poly(disp, 2)", "wt", "Fitted values"))

  m2 <- lm(mpg ~ wt + hp, data = mtcars)
  b2 <- ggplot2::ggplot_build(marginal.model.plots(m2))
  smooth <- b2$data[[2]]
  wt.data <- smooth[smooth$PANEL == 1 & smooth$linetype == "solid", ]
  x.eval <- seq(min(mtcars$wt), max(mtcars$wt), length.out = 50)
  fit <- loess(mpg ~ wt, data = mtcars, span = 2 / 3, degree = 1, family = "symmetric",
               control = loess.control(iterations = 4))
  expect_equal(wt.data$y, unname(predict(fit, data.frame(wt = x.eval))))
  expect_equal(p$labels$y, "mpg")
})

test_that("plot helpers reject non-lm models", {
  expect_error(diagnostics.plots(glm(am ~ wt, data = mtcars, family = binomial)), "lm")
  expect_error(marginal.model.plots(list()), "lm")
})

test_that("id labels do not overlap each other", {
  m <- lm(mpg ~ wt + hp, data = mtcars)
  for (panel in diagnostics.plots(m, id.n = 6)$plots) {
    b <- ggplot2::ggplot_build(panel)
    lab <- b$data[[length(b$data)]]
    xr <- b$layout$panel_params[[1]]$x.range
    yr <- b$layout$panel_params[[1]]$y.range
    nx <- (lab$x - xr[1]) / diff(xr)
    ny <- (lab$y - yr[1]) / diff(yr)
    w <- 0.015 * nchar(lab$label) + 0.008
    x0 <- nx - lab$hjust * w
    y0 <- ny - lab$vjust * 0.05
    for (a in seq_len(nrow(lab) - 1)) for (z in (a + 1):nrow(lab)) {
      clash <- x0[a] < x0[z] + w[z] && x0[z] < x0[a] + w[a] &&
        y0[a] < y0[z] + 0.05 - 1e-9 && y0[z] < y0[a] + 0.05 - 1e-9
      expect_false(clash)
    }
  }
})

test_that("marginal.model.plots accepts a custom title", {
  p <- marginal.model.plots(lm(mpg ~ wt + hp, data = mtcars), title = "Cars")
  expect_equal(p$scales$get_scales("colour")$name, "Cars")
})
