# Requires `pretty` from Nimble!

import libarpm/package_list, pretty

echo prettyString(prettyWalk(newPackageList(readFile("tests/test_package_list.json"))))
