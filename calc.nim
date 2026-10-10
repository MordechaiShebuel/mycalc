import os, strutils

proc calculate(a, b: float, op: string): float =
  case op
  of "+": a + b
  of "-": a - b
  of "*": a * b
  of "/":
    if b == 0:
      raise newException(ValueError, "Division by zero")
    a / b
  else:
    raise newException(ValueError, "Unknown operator: " & op)

proc interactiveMode() =
  stdout.write "Number 1: "
  let a = parseFloat(stdin.readLine().strip())

  stdout.write "Function (+,-,/,*): "
  let op = stdin.readLine().strip()

  stdout.write "Number 2: "
  let b = parseFloat(stdin.readLine().strip())

  let result = calculate(a, b, op)
  echo "sum: ", result

proc cliMode() =
  if paramCount() != 3:
    echo "Usage: calc <number> <operator> <number>"
    echo "Example: calc 5 + 3"
    quit(1)

  let a = parseFloat(paramStr(1))
  let op = paramStr(2)
  let b = parseFloat(paramStr(3))

  let result = calculate(a, b, op)
  echo "sum: ", result

when isMainModule:
  if paramCount() == 0:
    interactiveMode()
  else:
    cliMode()
