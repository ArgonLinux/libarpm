import std/json, semver, 
       parsers/[licenses, maintainer]

type
  InstallationReason* = enum
    Direct                             ## This package was installed directly by the user.
    Indirect                           ## This package was installed as a dependency of another package.

  ComparisonResult* = enum
    Older
    Newer
    Same

  PackageMetadata* = object
    reason*: InstallationReason        ## Why was this package installed?
    freedom*: FreedomType              ## What freedom does this package give you?

  Package* = object
    name*: string                      ## The package's name
    version*: Version                  ## The package's semantic version
    maintainer*: Maintainer            ## The package's maintainer on Argon
    license*: License                  ## The package's license
 
    depends*, provides*: seq[string]   ## What packages this depends upon and provides to
    optionalDepends*: seq[string]      ## What does this package optionally depend upon

    metadata*: PackageMetadata         ## Other information
    files*: seq[string]                ## Files belonging to this package.

proc `=destroy`*(package: Package) =
  `=destroy`(package.name)
  `=destroy`(package.maintainer)
  `=destroy`(package.depends)
  `=destroy`(package.provides)
  `=destroy`(package.optionalDepends)
  `=destroy`(package.files)

proc `=sink`*(dest: var PackageMetadata, src: PackageMetadata) =
  wasMoved(dest)
  dest.reason = src.reason
  dest.freedom = src.freedom

proc `=sink`*(dest: var Package, src: Package) =
  wasMoved(dest)

  dest.name = src.name
  dest.version = src.version
  dest.maintainer = src.maintainer
  dest.license = src.license

  dest.depends = src.depends
  dest.provides = src.provides
  dest.metadata = src.metadata
  dest.optionalDepends = src.optionalDepends
  dest.files = src.files

  `=sink`(dest.metadata, src.metadata)
  `=destroy`(src)

proc isLibre*(package: Package): bool {.inline.} =
  isLibre package.license

proc isOss*(package: Package): bool {.inline.} =
  isOss package.license

proc isProprietary*(package: Package): bool {.inline.} =
  isProprietary package.license

proc compare*(package: Package, against: Package): ComparisonResult =
  ## Compare a package against another one, and get the result.

  if package.version == against.version:
    return Same
  elif package.version > against.version:
    return Newer
  else:
    return Older

proc package*(
  name, version, maintainer, license: string, 
  depends, optionalDepends, provides, files: seq[string] = @[]
): Package =
  Package(
    name: name, 
    version: version.parseVersion(), 
    maintainer: maintainer.parseMaintainer(), 
    license: license.parseLicense(),
    depends: depends, provides: provides, 
    files: files, optionalDepends: optionalDepends
  )

proc package*(node: JsonNode): Package =
  var
    rawDepends = node["depends"].getElems()
    rawProvides = node["provides"].getElems()
    rawOptionalDepends = node["optional_depends"].getElems()
    rawFiles = node["files"].getElems()

    depends, provides, optionalDepends, files: seq[string]

  for d in rawDepends:
    depends.add getStr(d)

  for p in rawProvides:
    depends.add getStr(p)

  for od in rawOptionalDepends:
    optionalDepends.add getStr(od)

  for f in rawFiles:
    files.add getStr(f)

  Package(
    name: node["name"].getStr(),
    version: node["version"].getStr().parseVersion(),
    maintainer: node["maintainer"].getStr().parseMaintainer(),
    license: node["license"].getStr().parseLicense(),
    depends: depends,
    provides: provides,
    optionalDepends: optionalDepends,
    files: files
  )
