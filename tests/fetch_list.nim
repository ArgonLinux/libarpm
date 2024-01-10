## requires: pretty

import libarpm/package_list, pretty

let list = packageList(refresh=true)

print list
