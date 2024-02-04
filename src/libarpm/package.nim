import std/[strutils, json], parsers/[licenses, maintainer], ./helpers

import semver except `$`

type
  InstallationReason* = enum
    Direct ## This package was installed directly by the user.
    Indirect ## This package was installed as a dependency of another package.

  PackageMetadata* = object
    reason*: InstallationReason ## Why was this package installed?
    freedom*: FreedomType ## What freedom does this package give you?

  Package* = object
    name*: string ## The package's name
    version*: Version ## The package's semantic version
    maintainer*: Maintainer ## The package's maintainer on Argon
    license*: License ## The package's license

    depends*, provides*: seq[string] ## What packages this depends upon and provides to
    optional_depends*: seq[string] ## What does this package optionally depend upon

    metadata*: PackageMetadata ## Other information
    files*: seq[string] ## Files belonging to this package.

proc toJson*(package: Package): string =
  pretty (%*package)

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
  ## Check if this package is libre (or as the FSF calls it, free as in freedom, not as in free beer).
  ##
  ## **See also:**
  ## * `isOss proc`_
  ## * `isProprietary proc`_
  isLibre package.license

proc isOss*(package: Package): bool {.inline.} =
  ## Check if this package is open source software (there is a clear distinction between OSS and libre, go check it out.)
  ##
  ## **See also:**
  ## * `isProprietary proc`_
  ## * `isLibre proc`_
  isOss package.license

proc isProprietary*(package: Package): bool {.inline.} =
  ## Check if this package is proprietary (i.e, it was not compiled by Argon developers and only the authors have the source code and 
  ## they reserve certain rights to it.)
  ##
  ## **See also:**
  ## * `isLibre proc`_
  ## * `isOss proc`_
  isProprietary package.license

proc `>`*(package: Package, against: Package): bool {.inline.} =
  package.version > against.version

proc `<`*(package: Package, against: Package): bool {.inline.} =
  package.version < against.version

proc `>=`*(package: Package, against: Package): bool {.inline.} =
  package.version >= against.version

proc `<=`*(package: Package, against: Package): bool {.inline.} =
  package.version <= against.version

proc `==`*(package: Package, against: Package): bool {.inline.} =
  package.version == against.version

proc package*(
    name, version, maintainer, license: string,
    depends, optionalDepends, provides, files: seq[string] = @[],
): Package =
  ## Create a new `Package`
  ##
  ## **See also:**
  ## * `package proc`_ to create a `Package` from a `JsonNode`
  Package(
    name: name,
    version: version.parseVersion(),
    maintainer: maintainer.parseMaintainer(),
    license: license.parseLicense(),
    depends: depends,
    provides: provides,
    files: files,
    optionalDepends: optionalDepends,
  )

proc package*(node: JsonNode): Package =
  ## Create a new `Package` from a `JsonNode`, given that it has all the elements needed.
  ## If those elements are not present, an error will be raised.
  ##
  ## **See also:**
  ## * `package proc`_ to create a `Package` from a bunch of strings and string sequences
  var
    rawDepends = node["depends"].getElems()
    rawProvides = node["provides"].getElems()
    rawOptionalDepends: seq[JsonNode]
    rawFiles = node["files"].getElems()

    rawVersion = node["version"]
    version: Version

    depends, provides, optionalDepends, files: seq[string]

  try:
    version = rawVersion.getStr().parseVersion()
  except ParseError:
    version = rawVersion.version()

  if "optional_depends" in node:
    rawOptionalDepends = node["optional_depends"].getElems()
  elif "optionalDepends" in node:
    rawOptionalDepends = node["optionalDepends"].getElems()

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
    version: version,
    maintainer: node["maintainer"].getStr().parseMaintainer(),
    license: node["license"].getStr().parseLicense(),
    depends: depends,
    provides: provides,
    optionalDepends: optionalDepends,
    files: files,
  )
