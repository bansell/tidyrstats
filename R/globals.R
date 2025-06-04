#utils::globalVariables() is evaluated at build time, not when the package is loaded.

#It tells R CMD check to suppress NOTES about variables that are used in NSE (non-standard evaluation), like 'term', 'p.value', and . '.'

#It does not affect your package's runtime behavior or require namespace imports.

utils::globalVariables(c("term", "p.value", "."))
