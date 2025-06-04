#' Linear Model Testing for Grouped, Nested, or Ungrouped Data
#'
#' Applies a linear model (`lm`) to a data frame and returns tidy model summaries.
#' Supports ungrouped, grouped (dplyr::group_by()), and nested (tidyr::nest_by()) input data.
#'
#' @param input_data A data frame or tibble. Can be ungrouped, grouped, or nested.
#' @param formula A model formula, either quoted or unquoted (e.g., y ~ x * z , or "y ~ x * z").
#'
#' @return A tibble with tidy model output sorted by p value, including:
#' \describe{
#'   \item{term}{Model term (e.g., intercept, predictors, interactions)}
#'   \item{estimate}{Estimated coefficient / beta}
#'   \item{std.error}{Standard error of the estimate}
#'   \item{statistic}{t-statistic}
#'   \item{p.value}{p-value for the hypothesis test}
#' }
#' If the input is grouped or nested, group identifiers are retained in the output.
#' In the nested case, nested terms are relocated to the left-most column of the tibble.
#'
#' @details
#' Compatible with ungrouped, grouped or nested input. Compatible with native and magrittr pipe.
#' Uses broom::tidy() to extract model summaries.
#'
#' @examples
#' library(ggplot2)
#' library(dplyr)
#'
#' # Ungrouped
#' lm_test(mpg, cty ~ hwy * cyl)
#'
#' # Grouped
#' mpg |> group_by(class) |>  lm_test(cty ~ hwy * cyl)
#'
#' # Nested
#' mpg  |>  nest_by(class) |>  lm_test(cty ~ hwy * cyl)
#'

#' @importFrom purrr map_lgl pmap_dfr
#' @importFrom glue glue
#' @importFrom stats lm

#' @export
lm_test <- function(input_data, formula) {

  # Capture formula for message
  formula_quo <- rlang::enquo(formula)
  formula_expr <- rlang::get_expr(formula_quo)
  formula_str <- rlang::expr_text(formula_expr)
  formula_str <- dplyr::if_else(
    stringr::str_detect(formula_str, '"'),
    stringr::str_remove_all(formula_str, '"'),
    formula_str
  )
  message(glue::glue("Results for linear model: {formula_str}"))

  is_grouped <- dplyr::is_grouped_df(input_data)
  is_nested <- "data" %in% names(input_data) && all(purrr::map_lgl(input_data$data, is.data.frame))

  if (is_nested) {
    group_vars <- setdiff(names(input_data), "data")

    res <- purrr::pmap_dfr(input_data, function(..., data) {
      group_vals <- list(...)
      model <- tryCatch(stats::lm(formula, data = data), error = function(e) NULL)
      if (is.null(model)) return(NULL)
      broom::tidy(model) |>
        dplyr::mutate(term = ifelse(term == "(Intercept)", "intercept", term)) |>
        dplyr::bind_cols(as.data.frame(group_vals))
    }) |>
      dplyr::arrange(p.value) |>
      dplyr::relocate(term:p.value, .after = dplyr::last_col())

  } else {
    res <- input_data |>
      dplyr::do(broom::tidy(stats::lm(formula, data = .))) |>
      dplyr::mutate(term = ifelse(term == "(Intercept)", "intercept", term)) |>
      dplyr::ungroup() |>
      dplyr::arrange(p.value)
  }

  return(res)
}
