import std/options, ./[package, package_list, helpers, io]

proc solveDependencies*(
  package: Package,
  list: PackageList = packageList()
): seq[Package] =
  var deps: seq[Package] = @[]

  for dep in package.depends:
    let pkg = list.getPackage(dep)
    if not pkg.isSome:
      error("Dependency unfullfilled for package \"" & package.name & "\": " & dep)
      error("If this is a package from the official repositories, report it to arpm developers!", true)
    
    let package = get(pkg)
    deps.add(
      package
    )

    let subdeps = solveDependencies(package, list)

    deps &= subdeps

  deps
