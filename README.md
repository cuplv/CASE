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
