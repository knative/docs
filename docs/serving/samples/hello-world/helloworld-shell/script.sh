#!/bin/sh

# Set the configuration to serve the index file plain/text
echo "I:index.txt" > httpd.conf

# Prepare this index file with a nice welcome message
# Use environment variable TARGET or "World" if not set
echo "Hello ${TARGET:=World}!" > index.txt

# Start up busybox's httpd service, listen on port 8080 and
# stay in the foreground. Prints out verbose logs, too.
# See https://git.busybox.net/busybox/tree/networking/httpd.c for
# details
httpd -vv -p 8080 -f
