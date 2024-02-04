# Package

version       = "0.1.2"
author        = "xTrayambak"
description   = "The underlying core of Argon's package manager"
license       = "GPL-2.0-only"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.0"
requires "semver >= 1.2.0"
requires "zippy >= 0.10.11"
requires "toml_serialization >= 0.2.10"
requires "crunchy >= 0.1.9"
requires "nph >= 0.3.0"

task fmt, "format scheisse":
  exec "nph src/"
  exec "nph tests/"
