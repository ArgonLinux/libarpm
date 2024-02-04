import std/options, ./[package, package_list, io]

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
    
    let subpkg = get(pkg)
    deps.add(
      subpkg
    )

    info(package.name & " -> " & subpkg.name)

    let subdeps = solveDependencies(subpkg, list)

    deps &= subdeps

  deps
