import std/[json], ./[storage, io, helpers]

proc uninstall*(package: Package, force, refresh: bool = false) =
  # TODO: should we reeaaaallly provide an option to force deletion of a package, even if it means breaking the system? o_O
  
  if not isPackageInstalled(package.name) and not force:
    error("Package not installed: " & package.name)
    error("If you believe that this is a bug, use `--force` to bypass this check.")
  
  for file in package.files:
    if not fileExists(file):
      warn("File not found: " & file & "; ignoring.")
    
    root:
      removeFile(file)
