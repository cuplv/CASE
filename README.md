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

# passing results to z3

- `| z3 -in -smt2`
    + pipes the results into z3


# Type Checking

- tag unions
- sets of potential types to determine if there is a type error
- forwards analysis

# Main Contributions

+ what have we accomplished (sofar)
    - concrete evaluation
    - type evaluation
    - backward symbolic analysis
        + outputs to smt
    - Forwards and Backwards interpretation with the same generic eval
    - reuse of forwards elimination handler for type and concrete
    - end to end tool (parsing, interpretation, displaying results)
    - good performance
+ what do we want to say
    - we can build a toolkit of reusable components
    - easier than monads, ie usable and easy to modify
    - we accumulate semantics that "stick" to one evaluation function
    - these semantics are not constrained by flow directionality or domain
    - algebraic effects are performant enough that we can achieve this "direct style" without performance costs
    - for SOAP it seems like we want to show this is **viable**
        + this isn't **theoretical theatre** it is the foundations of what could become a large framework for analysis

# Related Works

- we have a good 1/4 page on **effect based interpretation**
- need at least one more paragraph on **monadic interpreters**
    - **MOPSA / Sturdy**
        + can reuse parts from other related works
- what do these other frameworks have that we don't and vice versa
    + do we have overlapping goals
    + how are our goals different
