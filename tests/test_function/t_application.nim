import ../../src/prologue

import unittest


proc hello*(ctx: Context) {.async.} =
  resp "<h1>Hello, Prologue!</h1>"

proc helloName*(ctx: Context) {.async.} =
  resp "<h1>Hello, " & ctx.getPathParams("name", "Prologue") & "</h1>"

proc articles*(ctx: Context) {.async.} =
  resp $ctx.getPathParams("num", 1)

proc go404*(ctx: Context) {.async.} =
  resp "Something wrong!"

proc go20x*(ctx: Context) {.async.} =
  resp "Ok!"

proc go30x*(ctx: Context) {.async.} =
  resp "EveryThing else?"


suite "Application Func Test":
  test "registErrorHandler can work":
    let settings = newSettings()
    var app = newApp(settings)
    app.registerErrorHandler(Http404, go404)
    app.registerErrorHandler({Http200 .. Http204}, go20x)
    app.registerErrorHandler(@[Http301, Http304, Http307], go30x)
    check:
      app.errorHandlerTable[Http404] == go404
      app.errorHandlerTable[Http202] == go20x
      app.errorHandlerTable[Http304] == go30x

  test "addRoute can work":
    let settings = newSettings()
    var app = newApp(settings)
    app.addRoute("/", hello)
    app.addRoute("/hello/{name}", helloName, @[HttpGet, HttpPost])
    app.addRoute(re"/post(?P<num>[\d]+)", articles, HttpGet)
    check:
      app.gScope.router[initPath("/", HttpGet)].handler == hello
      app.gScope.router[initPath("/", HttpHead)].handler == hello
      app.gScope.router[initPath("/hello/{name}", HttpPost)].handler == helloName
      app.gScope.reRouter.callable[0][1].handler == articles


suite "Restful Function Test":
  test "restful head can work":
    let settings = newSettings()
    var app = newApp(settings)
    app.head("/hi", hello)
    check app.gScope.router[initPath("/hi", HttpHead)].handler == hello

  test "restful get can work":
    let settings = newSettings()
    var app = newApp(settings)
    app.get("/hi", hello)
    check:
      app.gScope.router[initPath("/hi", HttpGet)].handler == hello
      app.gScope.router[initPath("/hi", HttpHead)].handler == hello

  test "restful post can work":
    let settings = newSettings()
    var app = newApp(settings)
    app.post("/hi", hello)
    check app.gScope.router[initPath("/hi", HttpPost)].handler == hello

  test "restful put can work":
    let settings = newSettings()
    var app = newApp(settings)
    app.put("/hi", hello)
    check app.gScope.router[initPath("/hi", HttpPut)].handler == hello

  test "restful delete can work":
    let settings = newSettings()
    var app = newApp(settings)
    app.delete("/hi", hello)
    check app.gScope.router[initPath("/hi", HttpDelete)].handler == hello

  test "restful trace can work":
    let settings = newSettings()
    var app = newApp(settings)
    app.trace("/hi", hello)
    check app.gScope.router[initPath("/hi", HttpTrace)].handler == hello

  test "restful options can work":
    let settings = newSettings()
    var app = newApp(settings)
    app.options("/hi", hello)
    check app.gScope.router[initPath("/hi", HttpOptions)].handler == hello

  test "restful connect can work":
    let settings = newSettings()
    var app = newApp(settings)
    app.connect("/hi", hello)
    check app.gScope.router[initPath("/hi", HttpConnect)].handler == hello

  test "restful patch can work":
    let settings = newSettings()
    var app = newApp(settings)
    app.patch("/hi", hello)
    check app.gScope.router[initPath("/hi", HttpPatch)].handler == hello

  test "restful all can work":
    let settings = newSettings()
    var app = newApp(settings)
    app.all("/hi", hello)
    check:
      app.gScope.router[initPath("/hi", HttpGet)].handler == hello
      app.gScope.router[initPath("/hi", HttpHead)].handler == hello
      app.gScope.router[initPath("/hi", HttpPost)].handler == hello
      app.gScope.router[initPath("/hi", HttpPut)].handler == hello
      app.gScope.router[initPath("/hi", HttpDelete)].handler == hello
      app.gScope.router[initPath("/hi", HttpTrace)].handler == hello
      app.gScope.router[initPath("/hi", HttpOptions)].handler == hello
      app.gScope.router[initPath("/hi", HttpConnect)].handler == hello
      app.gScope.router[initPath("/hi", HttpPatch)].handler == hello
