import std/[os, options, strutils, tempfiles, posix], ./[io, storage, package_list, package, helpers], zippy/ziparchives

const
  BASE_BINPKG_REPO {.strdefine.} = "https://raw.githubusercontent.com/ArgonLinux/bin-packages/master/gen-bin/"

proc install*(package: Package, force: bool = false) =
  let url = BASE_BINPKG_REPO & package.name & ".zip"

  if isPackageInstalled(package.name) and not force:
    info "Package is already installed. Use `--force` if you want to reinstall it."
    return

  let data = httpGet(url)

  if not data.isSome:
    error "Package \"" & package.name & "\" was not found in the binary package repository."
    error("If this package is real, then this means that the package list repository and the binary package repository are de-synchronized. Please report this!", true)

  let file = get data

  if file.len < 1:
    error("Package \"" & package.name & "\" payload is empty!", true)

  let dir = createTempDir("libarpm_", '_' & package.name)
  let path = dir / package.name & ".zip"

  info "Saving zipfile to: " & path

  writeFile(
    path,
    file
  )
  
  info "Extracting contents of zipfile: " & path
  extractAll(path, dir / "files")

  let prefix = dir / "files" / "build"
  
  for file in package.files:
    let
      splitted = file.split('/')
      real = splitted[splitted.len-1]

    if not fileExists(prefix / real):
      error("Could not find file: \"" & real & "\" inside package data! Please report this!", true)

    root:
      info("Copying file: \"" & prefix / real & "\" to \"" & file & '\"')
      copyFile(prefix / real, file)

      # TODO: this is incredibly stupid, but it works.
      if chmod(file, (S_IRUSR or S_IWUSR or S_IXUSR or S_IRGRP or S_IWGRP or S_IXGRP or S_IROTH or S_IWOTH or S_IXOTH).Mode) != 0:
        error("Failed to modify permissions for package file: " & file, true)

  markAsInstalled(package)
