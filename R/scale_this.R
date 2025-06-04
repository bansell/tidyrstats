#' Scale a numeric vector without converting to a matrix
#'
#' This function scales and centres a numeric vector by subtracting the mean and dividing by the standard deviation.
#' Unlike `scale()`, it returns a numeric vector, not a matrix. Note this function does not allow control over centering or scaling.
#'
#'
#' @param x A numeric vector.
#' @return A numeric vector of scaled values.

#' @importFrom stats sd mean

#' @examples
#' iris_dat <- head(iris)
#' scale_this(iris_dat$Sepal.Length)
#' scale_this(c(iris_dat$Sepal.Length, NA))

#' @export
scale_this <- function(x) {
  if (!is.numeric(x)) {
    stop("Input must be a numeric vector.")
  }

  if (any(is.na(x))) {
    message("Input contains NA values. Consider resolving these before scaling.")
  }

  mu <- mean(x, na.rm = TRUE)
  sigma <- sd(x, na.rm = TRUE)

  (x - mu) / sigma
}
