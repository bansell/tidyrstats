#' Scale a numeric vector without converting to a matrix
#'
#' This function scales and centres a numeric vector by subtracting the mean and dividing by the standard deviation.
#' Unlike `scale()`, it returns a numeric vector, not a matrix. Note this function does not allow control over centering or scaling.
#'
#'
#' @param x A numeric vector.
#' @return A numeric vector of scaled values.

#' @importFrom stats sd

#' @examples
#' iris_dat <- head(iris$Sepal.Length)
#' scale_this(iris_dat)
#' scale_this(c(iris_dat, NA))

#' @export
scale_this <- function(x) {
  if (!is.numeric(x)) {
    stop("Input must be a numeric vector.")
  }

  if (any(is.na(x))) {
    message("Input contains NA values. These are removed before scaling.")
  }

  mu <- mean(x, na.rm = TRUE)
  sigma <- sd(x, na.rm = TRUE)

  (x - mu) / sigma
}
