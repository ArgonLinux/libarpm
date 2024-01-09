import libarpm/helpers

proc doAdminStuff {.root.} =
  echo "if you see this when running as root; great!"
  echo "if you're seeing this when not root, then stuff has went horribly, horribly wrong"

doAdminStuff()
