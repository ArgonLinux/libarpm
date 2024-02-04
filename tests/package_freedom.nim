# RAHHHHH WHAT IS A KILOMETER!?!?!?
import libarpm

var
  pkg =
    package(
      "epic_gamer_package", "1.33.7", "Trayambak Rai (mail:trayambakrai@proton.me)",
      "GPL3"
    )

assert pkg.isLibre()

pkg.license = parseLicense "MIT"

assert pkg.isOss()

pkg.license = parseLicense "Proprietary"

assert pkg.isProprietary()

pkg.license = parseLicense "BSD3"

# this will crash as this is an OSS license, not a libre one.

assert pkg.isLibre(), "BSD isn't libre, you nincompoop!"
