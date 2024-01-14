## Helpful functions

import std/[os, times, options, httpclient, streams, strutils, json], ./io, semver

const 
  NimblePkgVersion {.strdefine.} = "???"
  LibarpmVersion* = NimblePkgVersion

proc `$`*(ver: Version): string =
  ## Convert a semantic version into a nice looking string

  result = GREEN & $ver.major & RESET & BOLD & '.' & RESET & GREEN & $ver.minor & RESET & BOLD & '.' & RESET & GREEN & $ver.patch & RESET

  if ver.build.len > 0:
    result &= BOLD & '-' & RESET & YELLOW & ver.build & RESET

  if ver.metadata.len > 0:
    result &= BOLD & ':' & RESET & YELLOW & ver.metadata & RESET

proc httpGet*(url: string): Option[string] =
  ## Get HTTP content from a URL.
  let start = cpuTime()
  info "Sending HTTP/GET request: " & url
  let httpClient = newHttpClient(userAgent = "libarpm/" & NimblePkgVersion)

  let resp = httpClient.get(url)

  if resp.code.int != 200:
    error "Server responded with non-200 response code: " & $resp.code.int
    return none(string)

  info "Request succeeded in " & $((cpuTime()-start)) & " ms!"
  return some(resp.bodyStream.readAll())

proc urlExists*(url: string): bool =
  ## Check if an endpoint returns 200
  let httpClient = newHttpClient(userAgent="libarpm/" & NimblePkgVersion)

  let resp = httpClient.get(url)
  
  echo resp.code.int
  resp.code.int == 200

proc validateJson*(jstr: string): bool {.inline.} =
  ## Find out if a JSON string is valid, or not. This just works by catching a `JsonParsingError`

  try:
    discard parseJson(jstr)
    return true
  except JsonParsingError as exc:
    warn "validateJson(): caught a JsonParsingError: " & exc.msg
    return false

proc version*(data: JsonNode): Version =
  ## Create a semantic version from a JSON Node

  let
    major = data["major"].getStr().parseInt()
    minor = data["minor"].getStr().parseInt()
    patch = data["patch"].getStr().parseInt()

    build = data["build"].getStr()
    metadata = data["metadata"].getStr()

  newVersion(
    major,
    minor,
    patch,
    build, metadata
  )

template root*(body: untyped) =
  ## This pragma ensures that any function it is attached to will not run, unless the process is privileged.
  ##
  ## .. code-block:: Nim
  ## proc adminStuff {.root.} =
  ##   removeFile("/etc/some/file/that/requires/root/to/modify")
  ## 
  ## # This will crash gracefully if we're not running as root :^)
  ## adminStuff()
  if not isAdmin():
    error("Function requires root privileges. Run with `sudo`, `doas` or another privilege escalation program to continue.", true)

  body
