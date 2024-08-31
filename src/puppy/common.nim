import std/strutils, webby

export webby

const CRLF* = "\r\n"

type
  Request* = ref object
    url*: Url
    headers*: HttpHeaders
    timeout*: float32
    verb*: string
    body*: string
    when defined(puppyLibcurl) or (defined(windows) or not defined(macosx)):
      # If you want to use this on Mac, please us -d:puppyLibcurl
      allowAnyHttpsCertificate*: bool
    ident*: tuple[cert, key: string]
    proxy*: string

  Response* = ref object
    headers*: HttpHeaders
    url*: string
    code*: int
    body*: string

  PuppyError* = object of IOError ## Raised if an operation fails.

  Header* = object
    key*: string
    value*: string

proc `$`*(req: Request): string =
  req.verb.toUpperAscii & " " & $req.url

converter toWebby*(headers: seq[Header]): HttpHeaders =
  cast[HttpHeaders](headers)

converter toWebby*(header: Header): (string, string) =
  (header.key, header.value)
