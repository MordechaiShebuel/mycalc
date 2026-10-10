import strutils
import nimgl/[opengl, glfw]
import imguin/[glfw_opengl, cimgui, simple]

# Reuse the original calculation logic
proc calculate(a, b: float, op: string): float =
  case op
  of "+": a + b
  of "-": a - b
  of "*": a * b
  of "/":
    if b == 0.0:
      raise newException(ValueError, "Division by zero")
    a / b
  else:
    raise newException(ValueError, "Unknown operator: " & op)

proc main() =
  # --- Window + OpenGL + ImGui setup ---
  doAssert glfwInit()
  defer: glfwTerminate()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE.cint)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE.cint)

  let window = glfwCreateWindow(420, 380, "Nim Calculator (ImGui)")
  if window == nil:
    quit("Failed to create GLFW window")
  defer: window.destroyWindow()

  window.makeContextCurrent()
  glfwSwapInterval(1)          # VSync

  doAssert glInit()

  let ctx = igCreateContext(nil)
  defer: igDestroyContext(ctx)

  doAssert ImGui_ImplGlfw_InitForOpenGL(cast[ptr impl_glfw.Glfwwindow](window), true)
  defer: ImGui_ImplGlfw_Shutdown()

  doAssert ImGui_ImplOpenGL3_Init("#version 330")
  defer: ImGui_ImplOpenGL3_Shutdown()

  igStyleColorsDark(igGetStyle())          # or igStyleColorsLight() / igStyleColorsClassic()

  # --- Calculator state ---
  var
    num1Str: array[64, char] = default(array[64, char])
    num2Str: array[64, char] = default(array[64, char])
    resultStr = "sum: 0"
    currentOp = "+"
    errorMsg = ""

  # pre-fill with defaults
  num1Str[0] = '5'
  num1Str[1] = '\0'
  num2Str[0] = '3'
  num2Str[1] = '\0'

  # --- Main loop ---
  while not window.windowShouldClose:
    glfwPollEvents()

    ImGui_ImplOpenGL3_NewFrame()
    ImGui_ImplGlfw_NewFrame()
    igNewFrame()

    # ===== Calculator Window =====
    igSetNextWindowPos(ImVec2(x: 20, y: 20), cint(1), ImVec2(x: 0.0, y: 0.0))
    igSetNextWindowSize(ImVec2(x: 380, y: 320), cint(1))

    if igBegin("Calculator", nil, cint(16)):
      igText("Simple Nim Calculator")
      igSeparator()

      # Number 1
      igText("Number 1:")
      igSetNextItemWidth(200)
      discard igInputText("##num1", cast[cstring](addr num1Str[0]), uint(256), cint(0), nil, nil)

      # Operator buttons
      igText("Operator:")
      if igButton("+", ImVec2(x: 50, y: 0)): currentOp = "+"
      igSameLine()
      if igButton("-", ImVec2(x: 50, y: 0)): currentOp = "-"
      igSameLine()
      if igButton("*", ImVec2(x: 50, y: 0)): currentOp = "*"
      igSameLine()
      if igButton("/", ImVec2(x: 50, y: 0)): currentOp = "/"
      igSameLine()
      igText("  Current: %s", currentOp.cstring)

      # Number 2
      igText("Number 2:")
      igSetNextItemWidth(200)
      discard igInputText("##num2", cast[cstring](addr num2Str[0]), uint(256), cint(0), nil, nil)

      igSpacing()
      igSeparator()

      # Calculate button
      if igButton("Calculate", ImVec2(x: 200, y: 40)):
        errorMsg = ""
        try:
          let a = parseFloat(($cstring(addr num1Str[0])).strip())
          let b = parseFloat(($cstring(addr num2Str[0])).strip())
          let res = calculate(a, b, currentOp)
          resultStr = "sum: " & $res
        except ValueError as e:
          errorMsg = e.msg
          resultStr = "Error"

      igSpacing()

      # Result
      igTextColored(ImVec4(x: 0.4, y: 0.9, z: 0.4, w: 1.0), "%s", resultStr.cstring)

      if errorMsg.len > 0:
        igTextColored(ImVec4(x: 1.0, y: 0.3, z: 0.3, w: 1.0), "Error: %s", errorMsg.cstring)

      igEnd()

    # ===== Rendering =====
    igRender()
    glViewport(0, 0, 420, 380)   # will be updated by GLFW on resize in real apps
    glClearColor(0.15, 0.15, 0.18, 1.0)
    glClear(GL_COLOR_BUFFER_BIT)
    ImGui_ImplOpenGL3_RenderDrawData(igGetDrawData())
    window.swapBuffers()

when isMainModule:
  main()
