import puppy/common

when defined(nimdoc):
  # Used to work around the doc generator.
  proc internalFetch(req: Request): Response {.raises: [PuppyError].} =
    discard
elif defined(windows) and not defined(puppyLibcurl):
  # WinHTTP Windows
  import puppy/platforms/win32/platform
elif defined(macosx) and not defined(puppyLibcurl):
  # AppKit macOS
  import puppy/platforms/macos/platform
else:
  # LIBCURL Linux
  import puppy/platforms/linux/platform

export common

proc addDefaultHeaders(req: Request) =
  if req.headers["user-agent"] == "":
    req.headers["user-agent"] = "Puppy"
  if req.headers["accept-encoding"] == "":
    # If there isn't a specific accept-encoding specified, enable gzip
    req.headers["accept-encoding"] = "gzip"

proc fetch*(req: Request): Response {.raises: [PuppyError].} =
  if req.url.scheme notin ["http", "https"]:
    raise newException(
      PuppyError, "Unsupported request scheme: " & req.url.scheme
    )

  req.addDefaultHeaders()

  if req.timeout == 0:
    req.timeout = 60

  return internalFetch(req)

proc newRequest*(
  url: string,
  verb = "get",
  headers = emptyHttpHeaders(),
  timeout: float32 = 60,
  ident = (cert: "", key: "")
): Request =
  ## Allocates a new request object with defaults.
  result = Request()
  result.url = parseUrl(url)
  result.verb = verb
  result.headers = headers
  result.timeout = timeout
  result.ident = ident

proc get*(
  url: string,
  headers = emptyHttpHeaders(),
  timeout: float32 = 60,
  ident = (cert: "", key: "")
): Response =
  fetch(newRequest(url, "GET", headers, timeout, ident))

proc post*(
  url: string,
  headers = emptyHttpHeaders(),
  body: sink string = "",
  timeout: float32 = 60,
  ident = (cert: "", key: "")
): Response =
  let request = newRequest(url, "POST", headers, timeout, ident)
  request.body = body
  fetch(request)

proc put*(
  url: string,
  headers = emptyHttpHeaders(),
  body: sink string = "",
  timeout: float32 = 60,
  ident = (cert: "", key: "")
): Response =
  let request = newRequest(url, "PUT", headers, timeout, ident)
  request.body = body
  fetch(request)

proc patch*(
  url: string,
  headers = emptyHttpHeaders(),
  body: sink string = "",
  timeout: float32 = 60,
  ident = (cert: "", key: "")
): Response =
  let request = newRequest(url, "PATCH", headers, timeout, ident)
  request.body = body
  fetch(request)

proc delete*(
  url: string,
  headers = emptyHttpHeaders(),
  timeout: float32 = 60,
  ident = (cert: "", key: "")
): Response =
  fetch(newRequest(url, "DELETE", headers, timeout, ident))

proc head*(
  url: string,
  headers = emptyHttpHeaders(),
  timeout: float32 = 60,
  ident = (cert: "", key: "")
): Response =
  fetch(newRequest(url, "HEAD", headers, timeout, ident))

proc fetch*(
  url: string,
  headers = emptyHttpHeaders(),
  ident = (cert: "", key: "")
): string =
  ## Simple fetch that directly returns the GET response body.
  ## Raises an exception if anything goes wrong or if the response code
  ## is not 200. See get, post, put etc for similar calls that return
  ## a response object.
  let res = get(url, headers, ident = ident)
  if res.code == 200:
    return res.body
  raise newException(PuppyError,
    "Non 200 response code: " & $res.code & "\n" & res.body
  )
