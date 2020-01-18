import asynchttpserver, asyncdispatch, uri, httpcore, httpclient

import tables, strutils, strformat, macros

type
  NativeRequest = asynchttpserver.Request
  PrologueError* = object of Exception
  RouteError* = object of PrologueError
  RouteResetError* = object of PrologueError

  Settings* = object
    port: Port
    address: string
    debug: bool

  Request* = ref object
    nativeRequest: NativeRequest
    params*: Table[string, string]
    settings: Settings

  Response* = ref object
    httpVersion*: HttpVersion
    status*: HttpCode
    httpHeaders*: HttpHeaders
    body*: string

  Handler* = proc(request: Request): Future[void]

  Router* = ref object
    callable*: Table[string, Handler]
    httpMethod*: HttpMethod

  Prologue* = object
    server: AsyncHttpServer
    settings: Settings
    router: Router

proc initResponse*(): Response =
  Response(httpVersion: HttpVer11, httpHeaders: newHttpHeaders())

proc abortWith*(status = Http404, body = ""): Response =
  result.status = status
  result.body = body

proc redirectTo*(status = Http301, url: string,
    body = "", delay = 0): Response =
  result.status = status
  if delay == 0:
    result.httpHeaders.add("Location", url)
  else:
    result.httpHeaders.add("refresh", fmt"""{delay};url="{url}"""")

proc error*(status = Http404, body = "404 Not Found!"): Response =
  result.status = status
  result.body = body

proc newRouter*(): Router =
  Router(callable: initTable[string, Handler]())

proc addRoute*(app: Prologue, route: string, handler: Handler,
    httpMethod = HttpGet) =
  app.router.callable[route] = handler
  app.router.httpMethod = httpMethod

proc findHandler*(app: Prologue, request: Request): bool =
  discard

proc handle*(request: Request, response: Response) {.async.} =
  await request.nativeRequest.respond(response.status, response.body,
      response.httpHeaders)

macro resp*(params: untyped) =
  let request = ident"request"
  let response = ident"response"
  result = quote do:
    handle(request, response)

proc initSettings*(port = Port(8080), address = "127.0.0.1",
    debug = false): Settings =
  Settings(port: port, address: address, debug: debug)

proc initApp*(settings: Settings): Prologue =
  Prologue(server: newAsyncHttpServer(true, true), settings: settings,
      router: newRouter())

proc run*(app: Prologue) =
  proc handleRequest(nativeRequest: NativeRequest) {.async.} =
    # await handle(nativeRequest, response)
    var request = Request(nativeRequest: nativeRequest, params: initTable[
        string, string](), settings: app.settings)
    if app.findHandler(request):
      discard
    else:
      var response = error()
      await request.nativeRequest.respond(response.status, response.body,
          response.httpHeaders)

  waitFor app.server.serve(app.settings.port, handleRequest)
# proc hello(request: Request) =
#   resp "<h1>Hello, Nim</h1>"



# macro callHandler(s: string): untyped =
#   result = newIdentNode(strVal(s))

# var server = newAsyncHttpServer()
# proc cb(req: Request) {.async, gcsafe.} =
#   var router = newRouter()
#   router.addRoute("/hello", "hello")
#   router.addRoute("/hello/<name>", "hello")
#   if req.url.path in router.callable:
#     let call = router.callable[req.url.path]
#     let response = callHandler(call)
#     echo response
#     # await req.respond(Http200, call)

#   await req.respond(Http200, "It's ok")



# waitFor server.serve(Port(5000), cb)
