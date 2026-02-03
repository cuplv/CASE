# CASE

- Cumulative Abstract Semantics via Effekt
- Python Abstract Analyzer written with [Effekt](https://effekt-lang.org/)

# Build Instructions

- for the specific Analyzer you with to build run the following depending on your backend of choice
    - for JS builds *(most portable)*
        - `effekt <analysis>.effekt`
    - for llvm builds *(most performant)*
        - `effekt --native --optimize --backend llvm  <analysis>.effekt`
    - for chez scheme builds *(mix of portability and performance)*
        - `effekt --backend chez-callcc <analysis>.effekt`

# Supported Python

## Type Checking

- Literals
    + int
    + bool
    + string
    + more complicated
        + list
        + tuple
        + dictionary

- functions (built in or not)
    + addition
    + concatenation
    + subtraction
    + multiplication
    + compound types
        + pop
        + append
        + push
        + remove
