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

## Docker

- if you want to build with docker running the following commands will put our interpreters in the `./out/` directory where they can be executed from the command line
    + `./out/concrete <file.json>`
        + the json files are python asts build with `./astDump.py`
    + `./out/symsmtrunner <file.py>`
        + requires python3 and z3 installed locally
- the docker commands to build the interpreters

```sh
# build container which installs effekt
docker build -t build .
# build interpreters and put them in ./out/
docker run --rm -v $(pwd)/out:/app/out build
```

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

## Contribution Bullets

- implement he ideas of CAS to produce several analyses for the same source language, with one evaluation function and set of effects
- demonstrate increased reusability of semantic fragments accross analyses
- Show the performance of effect oriented CAS framework is not a bottleneck

or

- We present a CAS framework, leveraging algebraic effect handlers to decouple AST traversal, control flow, and domain semantics, enabling modular reuse across interpreters without monad transformers.
- We refactor a monolithic interpreter for a small imperative language into CAS style, reusing one generic effectful evaluation function for both concrete forward and backward symbolic analyses.
- Shared elimination handlers for forward control flow reduces code duplication for new, forward analyses by roughly 50% compared to separate monolithic implementations.
- Evaluation on programs with 1M loop iterations shows a 34% overhead compared with monolithic baselines, demonstrating CAS as a practical toolkit.

# Related Works

- we have a good 1/4 page on **effect based interpretation**
- need at least one more paragraph on **monadic interpreters**
    - **MOPSA / Sturdy**
        + can reuse parts from other related works
- what do these other frameworks have that we don't and vice versa
    + do we have overlapping goals
    + how are our goals different
