import std/[strutils, times, json], package

const PKG_LIST_MIRROR {.strdefine.} = ""

type
  PackageList* = ref object
    name*: string
    revisionDate*, revisionTime*: DateTime
    packages*: seq[Package]

proc newPackageList*(node: JsonNode): PackageList =
  var revDate, revTime: DateTime

  let splittedRev = node["revision_date"].getStr().split(' ')
  
  revDate = splittedRev[0].parse("d/M/YYYY")
  revTime = splittedRev[1].parse("H:m:ss")

  let jPackages = node["packages"].getElems()
  var packages: seq[Package]

  for pkg in jPackages:
    packages.add package(pkg)
  
  PackageList(
    name: node["name"].getStr(),
    revisionDate: revDate,
    revisionTime: revTime,
    packages: packages
  )

proc newPackageList*(jstr: string): PackageList {.inline.} =
  newPackageList(parseJson(jstr))
