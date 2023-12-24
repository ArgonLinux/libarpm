import semver, 
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
    metadata*: PackageMetadata         ## Other information

proc `=destroy`*(package: Package) =
  `=destroy`(package.name)
  `=destroy`(package.maintainer)
  `=destroy`(package.depends)
  `=destroy`(package.provides)

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
  depends, provides: seq[string] = @[]
): Package =
  Package(
    name: name, 
    version: version.parseVersion(), 
    maintainer: maintainer.parseMaintainer(), 
    license: license.parseLicense(),
    depends: depends, provides: provides
  )
