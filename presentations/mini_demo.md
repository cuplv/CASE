---
title: "Algebraic Effects and Modular Interpreters"
theme:
    name: gruvbox-dark
---

Algebraic Effects
===

# side effects are tracked at the type level
# handlers give semantics to an effect
## remove the effect from the type signature
## a function with effects cannot be run (executed) until it's effects are handled

<!-- end_slide -->

Effects in Interpreters
===

```scala
type Expr {
  Cst(i: Int)
  Plus(e1: Expr, e2: Expr)
  //...
}

// plus takes two Expressions and returns generic type D
effect plus[D](e1: Exp, e2: Exp): D

// eval : Exp -> D \ {effects}
// includes effects for operations denoted with `\ {}`
def eval[D](e : Exp) : D / {plus, ...} = {
    e match {
        //...
        case Plus(e1, e2) => do plus(eval(e1), eval(e2)) // effect invocation
    }
}
```

<!-- end_slide -->

Making Evaluation Executable
===

```scala
// run has no effects as they are handled
def run(e: Exp): Val = {
    try { // call effectful function
        eval(e)
    } with plus(v1, v2) = { // provide semantics for effects
        resume(v1 + v2) // resume at effect invocation with `v1 + v2`
    }
}

// can redefine our executable `run` for different domains
def run(e: Exp): Interval = {
    try { // call effectful function
        eval(e)
    } with plus(v1, v2) = { // provide semantics for effects
        l1 = v1.low
        l2 = v2.low
        h1 = v1.high
        h2 = v2.high
        resume(Interval(l1 + l2, h1 + h2))
    }
}
```

<!-- end_slide -->

Modulating Control Flow
===

# moving recursive `eval` calls outside of the effect invocation

```scala
// unsubstantiated eval
def eval[D](prog: (Prog, State[D])): (D, State[D]) / { Elimination[D] } = 
  val (e, st) = prog
  e match {
    case E(e) => e match  {
      //...
      case Plus(e1, e2) => eval(do plusE(st, e1, e2)) // <---[here]
      //...
    }
  }

def eval_forwards[D]
  { prog: => (D, State[D]) / {Elimination[D]} } : (D, State[D]) /
  {
    //...
    plusI[D],
    //...
  } =
{
  try {
    prog()
  }
  with Elimination[D] {
    //...
    def plusE(st, e1, e2) = {
      val (v1, st1) = resume((E(e1), st))
      val (v2, st2) = resume((E(e2), st1))
      do plusI(st2, v1, v2)
    }
    //...
  }
}
```

<!-- end_slide -->

Demo
===

```scala
def run(prog: Prog, init: State[Val]): (Val, State[Val]) = {
  try {
    with eval_forwards[Val, State[Val]]
    eval((prog, init))
  }
  //...
```

```bash +exec
just run-concrete testIfType
```

<!-- end_slide -->

Demo
===

```py
x = 0

while x < 1_000_000:
    x = x + 1

if x == 1_000_000:
    x = True
```

```bash +exec
time ../out/concrete ../pylang/tests/testPerf.json
```

<!-- end_slide -->

Demo
===

```scala
def run(prog: Prog, init: State[Set[Type]]): (Set[Type], State[Set[Type]])
= {
  try {
    with eval_forwards[Set[Type], State[Set[Type]]]
    eval((prog, init))
  }
```

```bash +exec
just run-type testIfType
```

<!-- end_slide -->

Demo
===

```bash +exec
just run-type testIfTypeError
```

<!-- end_slide -->

Demo
===

```scala
def run(prog:Prog, init: SymStore) : (SymStore, SymStore) = {
  try {
    with symbolicElim()
    eval((prog, init))
  }
```

```bash +exec
just run-smt testDeepIf.py
```

<!-- end_slide -->

Demo
===

```bash +exec
just run-smt testAssgnx_2.py
```

<!-- end_slide -->

## Thank you
