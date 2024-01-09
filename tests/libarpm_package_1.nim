import libarpm/[io, package]

let 
  installed = package("glibc", "2.34.4", "Trayambak Rai (mail:trayambakrai@proton.me)", "GPL3")
  new = package("glibc", "2.34.5", "Trayambak Rai (mail:trayambakrai@proton.me)", "GPL3")

if installed.compare(new) == Older:
  info "We have an older package installed, replacing it with new one."
