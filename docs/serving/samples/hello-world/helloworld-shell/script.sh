#!/bin/sh

# Welcome message to show, evaluation TARGET env but fallback to "World"
message="Hello ${TARGET:=World}!"

# Set the configuration to server the index file
echo "I:index.txt" > httpd.conf

# Prepare index file that should be served
echo $message > index.txt

# Start up busybox's httpd service, listen on port 8080 and
# stay in the foreground. Prints out verbose logs, too.
# See https://git.busybox.net/busybox/tree/networking/httpd.c for
# details
httpd -vv -p 8080 -f
