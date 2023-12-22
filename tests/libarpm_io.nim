import libarpm/io

info("Doing some stuff.")
warn("Could not find xyz in pqr. Continuing with using abc instead.")
error("Failed to use abc.")

if confirm("Do you want to continue?"):
  info("Continuing anyways.")

  let favourite = ask("What is your favourite language?", ["Nim", "Rust"])
  if favourite == 1:
    error("You are not a true gigachad. Go away!")
  else:
    info("You are a true gigachad! Congrats or something.")
else:
  error("Won't go further.")
