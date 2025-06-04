#' Negative Logarithm (Base 10 by Default)
#'
#' Computes the negative logarithm of a numeric input using base 10 by default.
#'
#' This function returns the negative logarithm of `x`. By default, it uses base 10, but you can specify a different base using the `base` argument. Designed for quickly transforming p values for statistical analysis.
#'
#' @param x A numeric vector. Values must be positive.
#' @param base A numeric value specifying the base of the logarithm. Default is 10.
#'
#' @return A numeric vector of negative logarithmic values.
#' @export
#'
#' @examples
#' neg_log(10)           # -log10(10)
#' neg_log(100, base=2)  # -log2(100)
#' neg_log(c(1, 10, 100))
neg_log <- function(x, base = 10) {
  if (any(x <= 0, na.rm = TRUE)) {
    stop("All elements of 'x' must be positive.")
  }
  -log(x, base = base)
}

#' @rdname neg_log
#' @export
neglog <- neg_log
