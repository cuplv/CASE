# effekt exe path
effekt := "./node_modules/@effekt-lang/effekt/bin/effekt"

# is effekt installed
installed := path_exists("./node_modules/@effekt-lang/effekt/bin/effekt")

# is concrete eval built
conc_built := path_exists("./out/concrete")

# os dependent extension
os_ext := if os() == "windows" {".bat"} else {""}

# file to run
file := ""

# effekt backend
backend := "js"

# python test files
pyfiles := `cd pylang/tests && echo *.py`

# argument for backend
arg := if backend == "js" {
  'js'
} else if backend == "llvm" {
  'llvm'
} else {
  'chez-callcc'
}

help:
  @echo 'init             := install `effekt` language'
  @echo 'build-json       := build json ast of python test files'
  @echo 'run-concrete     := run concrete evaluation on given json file'
  @echo 'run-concrete-all := run concrete evaluation on all json test file and save'
  @echo 'build-concrete   := build concrete evaluator, change backend with'
  @echo '                  backend=js|llvm|chez'

init:
  npm i @effekt-lang/effekt

[working-directory: 'pylang/tests']
build-json:
  python3 astDump.py -f {{pyfiles}}

build-concrete:
  @if {{installed}}; then \
    echo "> building 'concrete.effekt'..."; \
    {{effekt}} -b --backend={{arg}} concrete.effekt; \
  else \
    echo "> effekt not installed, run 'just init'"; \
  fi

run-concrete *FILE:
  @if {{conc_built}}; then \
    echo ">"{{FILE}}".py:"; \
    echo "---------"; \
    cat pylang/tests/{{FILE}}.py; \
    echo "---------\n"; \
    echo "> end state:"; \
    ./out/concrete{{os_ext}} pylang/tests/{{FILE}}.json; \
  else \
    echo "> concrete evaluation not built, run 'just build-concrete'"; \
  fi

run-concrete-all:
  ./out/concrete `echo pylang/tests/*.json` > concrete_output.txt
