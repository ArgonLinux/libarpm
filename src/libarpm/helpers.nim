## Helpful functions

import std/[os, times, options, httpclient, streams, json], ./io

const NimblePkgVersion {.strdefine.} = "???"

proc httpGet*(url: string): Option[string] =
  ## Get HTTP content from a URL.
  let start = cpuTime()
  info "Sending HTTP/GET request: " & url
  let httpClient = newHttpClient(userAgent = "libarpm/" & NimblePkgVersion)

  let resp = httpClient.get(url)

  if resp.code.int != 200:
    error "Server responded with non-200 response code: " & $resp.code.int
    return none(string)

  info "Request succeeded in " & $((start - cpuTime())) & " ms!"
  return some(resp.bodyStream.readAll())

proc validateJson*(jstr: string): bool {.inline.} =
  ## Find out if a JSON string is valid, or not. This just works by catching a `JsonParsingError`

  try:
    discard parseJson(jstr)
    return true
  except JsonParsingError as exc:
    warn "validateJson(): caught a JsonParsingError: " & exc.msg
    return false

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
