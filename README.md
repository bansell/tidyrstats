## Description

This package contains helper functions for implementing common
statistical functions in R, within tidy workflows.

## Install

    if (!requireNamespace("devtools", quietly = TRUE)) {
      install.packages("devtools")
    }
    devtools::install_github("bansell/tidyrstats")

    library(tidyrstats)

## neg\_log()

This function computes the negative logarithm of a numeric input using
base 10 by default. This function returns the negative logarithm of `x`.
By default, it uses base 10, but you can specify a different base using
the `base` argument. Designed for quickly transforming p values for
statistical analysis.

Say we have summary statistics results for an RNAseq differential
expression experiment

    head(toptags)
    #> # A tibble: 6 × 7
    #>   geneID logFC AveExpr     t  P.Value    adj.P.Val     B
    #>   <chr>  <dbl>   <dbl> <dbl>    <dbl>        <dbl> <dbl>
    #> 1 gene_1 -4.10    7.07 -35.5 3.38e-12 0.0000000466  18.4
    #> 2 gene_2 -4.35    5.66 -32.4 8.66e-12 0.0000000466  17.4
    #> 3 gene_3 -4.72    6.46 -30.8 1.45e-11 0.0000000466  17.1
    #> 4 gene_4 -3.77    6.29 -30.0 1.93e-11 0.0000000466  16.9
    #> 5 gene_5 -5.22    4.93 -30.9 1.42e-11 0.0000000466  16.8
    #> 6 gene_6 -5.31    8.86 -29.6 2.22e-11 0.0000000466  16.7

    toptags |> mutate(neg_logP = neg_log(P.Value)) |> 
      ggplot(aes(x=logFC,y=neg_logP)) + 
      geom_point(size=0.5)

![](/Users/ansell.b/Library/CloudStorage/Dropbox/bioinf/tidyrstats/README_files/figure-markdown_strict/unnamed-chunk-6-1.png)

## scale\_this()

This function scales and centres a numeric vector by subtracting the
mean and dividing by the standard deviation.

Unlike `base::scale()`, it returns a numeric vector, not a matrix,
making it play well with tidy data structures and dplyr chained code.
Note this function does not allow control over centering or scaling at
present.

`` scale_this` `` will drop NA values before scaling, by default (as is
the case for `base::scale()`). However the function will include
original NA values in the output, and generate a warning message.


    iris_dat <- c(head(iris$Sepal.Length),NA)

    iris_dat |>  as_tibble() |> mutate(scaled = scale_this(value))
    #> Input contains NA values. These are removed before scaling.
    #> # A tibble: 7 × 2
    #>   value scaled
    #>   <dbl>  <dbl>
    #> 1   5.1  0.521
    #> 2   4.9 -0.174
    #> 3   4.7 -0.868
    #> 4   4.6 -1.21 
    #> 5   5    0.174
    #> 6   5.4  1.56 
    #> 7  NA   NA

`scale_this()` will also work with a simple numeric vector:

    scale_this(iris_dat)
    #> Input contains NA values. These are removed before scaling.
    #> [1]  0.5206576 -0.1735525 -0.8677627 -1.2148677  0.1735525  1.5619728         NA

## lm\_test()

This function provides a wrapper around
`do(broom::tidy(lm(... , data = .))` which is very difficult to teach in
a tidyverse-focused workshop; difficult for students to understand, as
well as annoying to code!

`lm_test()` is compatible with grouped or nested input, and compatible
with the native R pipe `|>` or magrittr pipe `%>%`. It accepts a quoted
or unquoted model formula.

`lm_test()` returns a tibble containing the tidied output of `lm()`,
sorted by p-value, which includes the following columns:

-   **term**: The name of the model term (such as the intercept,
    predictors, or interaction terms).

-   **estimate**: The estimated coefficient (also known as the beta
    value).

-   **std.error**: The standard error associated with the estimate.

-   **statistic**: The t-statistic used in hypothesis testing.

-   **p.value**: The p-value indicating the significance of the term.

If the input data is grouped or nested, the output will retain the group
identifiers. In both cases, the grouping/nesting identifiers will appear
in the left-most columns of the tibble.

For ungrouped input:


    mpg %>% lm_test( cty ~ hwy )
    #> Results for linear model: cty ~ hwy
    #> # A tibble: 2 × 5
    #>   term      estimate std.error statistic   p.value
    #>   <chr>        <dbl>     <dbl>     <dbl>     <dbl>
    #> 1 hwy          0.683    0.0138     49.6  1.87e-125
    #> 2 intercept    0.844    0.333       2.53 1.19e-  2

For grouped input:


    mpg %>% group_by(class) %>%  lm_test(cty ~ hwy * cyl + 0)
    #> Results for linear model: cty ~ hwy * cyl + 0
    #> # A tibble: 21 × 6
    #>    class      term    estimate std.error statistic  p.value
    #>    <chr>      <chr>      <dbl>     <dbl>     <dbl>    <dbl>
    #>  1 suv        hwy       0.878     0.0329     26.7  1.26e-34
    #>  2 compact    hwy       0.818     0.0396     20.6  3.03e-24
    #>  3 midsize    hwy       0.799     0.0423     18.9  6.64e-21
    #>  4 pickup     hwy       0.863     0.0399     21.6  7.46e-20
    #>  5 subcompact hwy       0.817     0.0548     14.9  5.87e-16
    #>  6 minivan    hwy       0.826     0.0510     16.2  2.13e- 7
    #>  7 suv        hwy:cyl  -0.0437    0.0120     -3.65 5.59e- 4
    #>  8 suv        cyl       0.424     0.150       2.83 6.37e- 3
    #>  9 midsize    hwy:cyl  -0.0579    0.0295     -1.96 5.72e- 2
    #> 10 2seater    hwy       0.353     0.132       2.68 7.48e- 2
    #> # ℹ 11 more rows

For nested input with a quoted model formula:

    mpg |>  nest_by(class) |>  lm_test("cty ~ hwy * cyl + 0")
    #> Results for linear model: cty ~ hwy * cyl + 0
    #> # A tibble: 21 × 6
    #>    class      term    estimate std.error statistic  p.value
    #>    <chr>      <chr>      <dbl>     <dbl>     <dbl>    <dbl>
    #>  1 suv        hwy       0.878     0.0329     26.7  1.26e-34
    #>  2 compact    hwy       0.818     0.0396     20.6  3.03e-24
    #>  3 midsize    hwy       0.799     0.0423     18.9  6.64e-21
    #>  4 pickup     hwy       0.863     0.0399     21.6  7.46e-20
    #>  5 subcompact hwy       0.817     0.0548     14.9  5.87e-16
    #>  6 minivan    hwy       0.826     0.0510     16.2  2.13e- 7
    #>  7 suv        hwy:cyl  -0.0437    0.0120     -3.65 5.59e- 4
    #>  8 suv        cyl       0.424     0.150       2.83 6.37e- 3
    #>  9 midsize    hwy:cyl  -0.0579    0.0295     -1.96 5.72e- 2
    #> 10 2seater    hwy       0.353     0.132       2.68 7.48e- 2
    #> # ℹ 11 more rows
