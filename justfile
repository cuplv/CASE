file := ""
backend := "js"
pyfiles := `cd pylang/tests && echo *.py`
arg := if backend == "js" {
  'js'
} else if backend == "llvm" {
  'llvm'
} else {
  'chez-callcc'
}

help:
  @echo 'build-json       := build json ast of python test files'
  @echo 'run-concrete     := run concrete evaluation on given json file'
  @echo 'run-concrete-all := run concrete evaluation on all json test file and save'
  @echo 'run-concrete-all := run python evaluation on all python test file and save'
  @echo 'build-concrete   := build concrete evaluator, change backend with'
  @echo '                  backend=js|llvm|chez'

[working-directory: 'pylang/tests']
build-json:
  python3 astDump.py -f {{pyfiles}}

build-concrete:
  effekt -b --backend={{arg}} concrete.effekt

run-concrete *FILE:
  ./out/concrete {{FILE}}

run-concrete-all:
  ./out/concrete `echo pylang/tests/*.json` > concrete_output.txt
