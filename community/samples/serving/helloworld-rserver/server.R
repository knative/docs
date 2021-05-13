library(plumber) # https://www.rplumber.io/

# Translate the HelloWorld file into a Plumber API
r <- plumb("HelloWorld.R")
# Get the PORT env var
PORT <- strtoi(Sys.getenv("PORT", 8080))
# Run the API
r$run(port=PORT, host="0.0.0.0")
