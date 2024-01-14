import std/options, libarpm/[install, package_list]

let list = packageList()

let pkg = list.getPackage("trayfetch").get()

pkg.install()
