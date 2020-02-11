import httpcore, cookies
import times, json, strformat


type
  Response* = object
    httpVersion*: HttpVersion
    status*: HttpCode
    httpHeaders*: HttpHeaders
    cookies*: string
    body*: string


proc `$`*(response: Response): string =
  fmt"{response.status} {response.httpHeaders}"

proc initResponse*(httpVersion: HttpVersion, status: HttpCode, httpHeaders =
    {"Content-Type": "text/html; charset=UTF-8"}.newHttpHeaders,
        body = ""): Response =
  Response(httpVersion: httpVersion, status: status, httpHeaders: httpHeaders, body: body)

proc setHeader*(response: var Response; key, value: string) =
  response.httpHeaders[key] = value

proc addHeader*(response: var Response; key, value: string) =
  response.httpHeaders.add(key, value)

proc setCookie*(response: var Response; key, value: string; expires: DateTime |
    Time; domain = ""; path = ""; noName = false; secure = false;
        httpOnly = false): string =
  response.cookies = setCookie(key, value, expires, domain, path, noName,
      secure, httpOnly)

proc abort*(status = Http401, body = "", headers = newHttpHeaders(),
    version = HttpVer11): Response {.inline.} =
  result = initResponse(version, status = status, body = body,
      httpHeaders = headers)

proc redirect*(url: string, status = Http301,
    body = "", delay = 0, headers = newHttpHeaders(),
        version = HttpVer11): Response {.inline.} =
  ## redirect to new url.
  var headers = headers
  if delay == 0:
    headers.add("Location", url)
  else:
    headers.add("refresh", fmt"""{delay};url="{url}"""")
  result = initResponse(version, status = status, httpHeaders = headers, body = body)

proc error404*(status = Http404,
    body = "<h1>404 Not Found!</h1>", headers = newHttpHeaders(),
        version = HttpVer11): Response {.inline.} =
  result = initResponse(version, status = status, body = body,
      httpHeaders = headers)

proc htmlResponse*(text: string, status = Http200, headers = newHttpHeaders(),
    version = HttpVer11): Response {.inline.} =
  ## Content-Type": "text/html; charset=UTF-8
  var headers = headers
  headers["Content-Type"] = "text/html; charset=UTF-8"
  result = initResponse(version, status, headers,
      body = text)

proc plainTextResponse*(text: string, status = Http200,
    headers = newHttpHeaders(), version = HttpVer11): Response {.inline.} =
  ## Content-Type": "text/plain
  var headers = headers
  headers["Content-Type"] = "text/plain"
  initResponse(version, status, headers,
      body = text)

proc jsonResponse*(text: JsonNode, status = Http200, headers = newHttpHeaders(),
    version = HttpVer11): Response {.inline.} =
  ## Content-Type": "application/json
  var headers = headers
  headers["Content-Type"] = "text/json"
  initResponse(version, status, headers,
      body = $text)
