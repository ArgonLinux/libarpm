## Requires `pretty` from Nimble!

import libarpm/parsers/maintainer, pretty

print parseMaintainer(
  "Trayambak Rai (mail:trayambakrai@proton.me,gh:xTrayambak,mstdn:xtrayambak@fosstodon.org)"
)

print parseMaintainer("Abhiraj Rik (mail:sontaimnt@gmail.com,gh:abrik1,gl:abrik1)")
