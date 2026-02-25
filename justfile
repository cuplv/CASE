set unstable

# os dependent extension
os_ext := if os() == "windows" {".bat"} else {""}

java_exe := if which("java") == "" {"java not installed..."} else {which("java")}
npm_exe := if which("npm") == "" {"npm not installed..."} else {which("npm")}
z3_exe := if which("z3") == "" {"z3 not installed..."} else {which("z3")}
python3_exe := if which("python3") == "" {"python3 not installed..."} else {which("python3")}

# effekt exe path
effekt := "./node_modules/@effekt-lang/effekt/bin/effekt"

# is effekt installed
installed := path_exists("./node_modules/@effekt-lang/effekt/bin/effekt")

# is concrete eval built
conc_built := path_exists("./out/concrete"+os_ext)

# is type eval built
type_built := path_exists("./out/typecheck"+os_ext)

# is SMT runner built
smt_built := path_exists("./out/symsmtrunner"+os_ext)

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
  @echo 'check            := check required dependencies'
  @echo 'init             := install `effekt` language'
  @echo 'clean            := remove build/output artifacts'
  @echo 'build-json       := build json ast of python test files'
  @echo 'build-concrete   := build concrete evaluator, change backend with'
  @echo '                  backend=js|llvm|chez'
  @echo 'build-type       := build typecheck evaluator, change backend with'
  @echo '                  backend=js|llvm|chez'
  @echo 'build-smt        := build SMT runner for symbolic evaluator'
  @echo 'run-concrete     := run concrete evaluation on given json file'
  @echo 'run-concrete-all := run concrete evaluation on all json test file and save'
  @echo 'run-type         := run type evaluation on given json file'
  @echo 'run-smt          := run SMT evaluation on given json file'
  @echo 'run-smt-all      := run SMT evaluation on all json test files'
  @echo 'parser-test-all  := run parser on JSON ast test files'
  @echo 'parser-test      := run parser on input'

check:
  @echo "> checking java..."
  @echo '{{java_exe}}'
  @echo "> checking npm..."
  @echo '{{npm_exe}}'
  @echo "> checking python..."
  @echo '{{python3_exe}}'
  @echo "> checking z3..."
  @echo '{{z3_exe}}'

list-tests:
  @ls pylang/tests/*.py

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

build-smt:
  @if {{installed}}; then \
    echo "> building 'symbolic/symsmtrunner.effekt'..."; \
    {{effekt}} -b --backend={{arg}} symbolic/symsmtrunner.effekt; \
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

comp-conc FILE:
  echo ">"{{FILE}}".py:"; \
  echo "---------"; \
  cat pylang/tests/{{FILE}}.py; \
  echo "---------"; \
  echo "> eff conc end state:"; \
  ./out/concrete{{os_ext}} pylang/tests/{{FILE}}.json; \
  echo "---------"; \
  echo "> mono conc end state:"; \
  ./out/concmono{{os_ext}} pylang/tests/{{FILE}}.json; \
  echo "---------"; \

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

run-smt *FILE:
  @if {{smt_built}}; then \
    echo ">"{{FILE}}":"; \
    echo "---------"; \
    cat pylang/tests/{{FILE}}; \
    echo "---------"; \
    ./out/symsmtrunner{{os_ext}} pylang/tests/{{FILE}}; \
  else \
    echo "> SMT runner not built, run 'just build-smt'"; \
  fi

comp-smt FILE:
  echo ">"{{FILE}}":"; \
  echo "------------"; \
  cat pylang/tests/{{FILE}}; \
  echo "----eff-----"; \
  ./out/symsmtrunner{{os_ext}} pylang/tests/{{FILE}}; \
  echo "----mono----"; \
  ./out/smtmono{{os_ext}} pylang/tests/{{FILE}}; \

run-concrete-all:
  @if {{conc_built}}; then \
    ./out/concrete{{os_ext}} {{astfiles}} > concrete_output.txt; \
  else \
    echo "> concrete evaluation not built, run 'just build-concrete'"; \
  fi

run-smt-all:
  @if ! {{smt_built}}; then \
    just build-smt; \
  fi; \
  if {{smt_built}}; then \
    just build-json; \
    rm -f smt_output.txt; \
    for f in pylang/tests/*.json; do \
      file="$(basename "$f" .json)"; \
      { \
        echo ">""$file"".py:"; \
        echo "---------"; \
        cat pylang/tests/$file.py; \
        echo "---------"; \
        ./out/symsmtrunner{{os_ext}} "$f"; \
        echo ""; \
      } >> smt_output.txt; \
    done; \
    echo "Output saved at: smt_output.txt"; \
  else \
    echo "> SMT runner not built, run 'just build-smt'"; \
  fi

parser-test-all:
  ./out/pyconv{{os_ext}}

parser-test:
  @python3 pylang/tests/astDump.py -i | ./out/pyconv{{os_ext}} -i 

clean:
  @rm -rf out
  @rm -f concrete_output.txt
  @rm -f pylang/tests/*.json

