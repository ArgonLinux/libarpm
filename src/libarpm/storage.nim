import std/[os, options], ./io, helpers

const
  BASE_STORAGE {.strdefine.} = "/etc/arpm.d"

proc existsOrCreateStorageDir*(subdirectories: seq[string]) =
  root:
    if not dirExists("/etc/arpm.d"):
      info "Creating storage directory (" & BASE_STORAGE & ")"
      createDir(BASE_STORAGE)
  
    for sub in subdirectories:
      if not dirExists(sub):
        info "Creating sub-directory in storage directory (" & BASE_STORAGE & '/' & sub & ')'
        createDir(BASE_STORAGE / sub)

proc writePackageList*(name: string, data: string) {.inline.} =
  root:
    existsOrCreateStorageDir(@["repos"])
    writeFile(BASE_STORAGE / "repos" / name & ".argon", data)

proc getPackageList*(
  name: string
): Option[string] =
  info "Fetching pre-saved repository: " & name & ".argon"

  let path = BASE_STORAGE / "repos" / name & ".argon"
  
  if not fileExists(path):
    warn "Pre-saved repository not found: " & path
    return none(string)
  
  some(readFile(path))
