import semver

type
  InstallationReason* = enum
    Direct                             ## This package was installed directly by the user.
    Indirect                           ## This package was installed as a dependency of another package.

  ComparisonResult* = enum
    Older
    Newer
    Same

  Package* = ref object
    name*: string                      ## The package's name
    version*: Version                  ## The package's semantic version
    maintainer*: string                ## The package's maintainer on Argon
    license*: string                   ## The package's license
    
    depends*, provides*: seq[string]   ## What packages this depends upon and provides to
    reason*: InstallationReason        ## Why was this package installed?

proc compare*(package: Package, against: Package): ComparisonResult =
  ## Compare a package against another one, and get the result.

  # Confirm that we're comparing the same packages other than the version.
  assert package.name == against.name, "Attempt to compare packages with different names."
  assert package.maintainer == against.maintainer, "Attempt to compare packages with different maintainers."
  assert package.license == against.license, "Attempt to compare packages with different licenses."
  assert package.depends == against.depends, "Attempt to compare packages with different dependencies."
  assert package.provides == against.provides, "Attempt to compare packages with different dependents."

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
    name: name, version: version.parseVersion(), maintainer: maintainer, license: license,
    depends: depends, provides: provides
  )
