import libarpm/[io, package]

let 
  installed = package("glibc", "2.34.4", "trayambakrai@proton.me", "GPL3")
  new = package("glibc", "2.31.2", "trayambakrai@proton.me", "GPL3")

if installed.compare(new) == Older:
  info "We have an older package installed, replacing it with new one."
