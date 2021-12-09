#!/bin/Rscript
TARGET <- Sys.getenv("TARGET", "World")

message = paste("Hello ", TARGET, "!", sep = "")
print(message)
