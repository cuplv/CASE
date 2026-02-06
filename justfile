# os dependent extension
os_ext := if os() == "windows" {".bat"} else {""}

# effekt exe path
effekt := "./node_modules/@effekt-lang/effekt/bin/effekt"

# is effekt installed
installed := path_exists("./node_modules/@effekt-lang/effekt/bin/effekt")

# is concrete eval built
conc_built := path_exists("./out/concrete"+os_ext)

# is type eval built
type_built := path_exists("./out/typecheck"+os_ext)

# file to run
file := ""

# effekt backend
backend := "js"

# python test files
pyfiles := replace(`cd pylang/tests && find * -maxdepth 0 -name "*.py" ! -name "astDump*"`, "\n", " ")

astfiles := `echo pylang/tests/*.json` 

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
  @echo 'build-concrete   := build concrete evaluator, change backend with'
  @echo '                  backend=js|llvm|chez'
  @echo 'build-type       := build typecheck evaluator, change backend with'
  @echo '                  backend=js|llvm|chez'
  @echo 'run-concrete     := run concrete evaluation on given json file'
  @echo 'run-concrete-all := run concrete evaluation on all json test file and save'
  @echo 'run-type         := run type evaluation on given json file'
  @echo 'parser-test-all  := run parser on JSON ast test files'
  @echo 'parser-test      := run parser on input'

init:
  npm i @effekt-lang/effekt

[working-directory: 'pylang/tests']
build-json:
  @python3 astDump.py -f {{pyfiles}}

build-concrete:
  @if {{installed}}; then \
    echo "> building 'concrete.effekt'..."; \
    {{effekt}} -b --backend={{arg}} concrete.effekt; \
  else \
    echo "> effekt not installed, run 'just init'"; \
  fi

build-type:
  @if {{installed}}; then \
    echo "> building 'typecheck.effekt'..."; \
    {{effekt}} -b --backend={{arg}} typecheck.effekt; \
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

run-type *FILE:
  @if {{type_built}}; then \
    echo ">"{{FILE}}".py:"; \
    echo "---------"; \
    cat pylang/tests/{{FILE}}.py; \
    echo "---------\n"; \
    echo "> end state:"; \
    ./out/typecheck{{os_ext}} pylang/tests/{{FILE}}.json; \
  else \
    echo "> type evaluation not built, run 'just build-type'"; \
  fi

run-concrete-all:
  @if {{conc_built}}; then \
    ./out/concrete{{os_ext}} {{astfiles}} > concrete_output.txt; \
  else \
    echo "> concrete evaluation not built, run 'just build-concrete'"; \
  fi

parser-test-all:
  ./out/pyconv{{os_ext}}

parser-test:
  @python3 pylang/tests/astDump.py -i | ./out/pyconv{{os_ext}} -i 

