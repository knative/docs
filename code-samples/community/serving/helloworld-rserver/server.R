library(plumber) # https://www.rplumber.io/

# Validate PORT before opening a listener; Knative supplies this variable.
port_value <- Sys.getenv("PORT", "8080")
PORT <- suppressWarnings(as.integer(port_value))
if (!grepl("^[0-9]+$", port_value) || is.na(PORT) || PORT < 1L || PORT > 65535L) {
  stop("PORT must be an integer between 1 and 65535")
}

# Translate the HelloWorld file into a Plumber API and listen on all interfaces.
r <- plumb("HelloWorld.R")
r$run(port = PORT, host = "0.0.0.0")
